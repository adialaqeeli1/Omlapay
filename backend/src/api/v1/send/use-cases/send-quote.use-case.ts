import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  UserEntity,
  UserKycEntity,
  CoinEntity,
  WalletEntity,
} from '@common/database/model';
import { KycStatus, KycProvider } from '@common/database/model';
import { RecipientType } from '@common/database/model';
import { PriceService } from '@common/services/binance/price.service';
import { SystemSettingsService } from '@common/services/system-settings/system-settings.service';
import { UserKycGuardService } from '@common/services/user-kyc-guard/user-kyc-guard.service';
import { successResponse, maskAddress } from '@common/utils';
import { ErrorCodes, COIN_TO_NETWORK_MAP } from '@common/constants';
import {
  MAX_TRANSFER_USD,
  MIN_TRANSFER_USD,
  MIN_ADDRESS_LENGTH,
  MAX_ADDRESS_LENGTH,
} from '../send.constants';

function isPhoneNumber(value: string): boolean {
  return /^\+[1-9]\d{1,14}$/.test(value.trim());
}

@Injectable()
export class SendQuoteUseCase {
  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(UserKycEntity)
    private userKycRepository: Repository<UserKycEntity>,
    @InjectRepository(CoinEntity)
    private coinRepository: Repository<CoinEntity>,
    @InjectRepository(WalletEntity)
    private walletRepository: Repository<WalletEntity>,
    private userKycGuardService: UserKycGuardService,
    private priceService: PriceService,
    private systemSettingsService: SystemSettingsService,
  ) {}

  async execute(
    userId: string,
    dto: { coin: string; recipient: string; amount: number },
  ) {
    const user = await this.userKycGuardService.assertUserCanPerformAction(
      userId,
      'send',
    );

    const coinSymbol = dto.coin.toUpperCase();
    const coin = await this.coinRepository.findOne({
      where: { symbol: coinSymbol, isActive: true },
    });
    if (!coin) {
      throw new BadRequestException({
        status: 'error',
        message: `Unsupported coin: ${coinSymbol}`,
      });
    }

    const amountStr = String(dto.amount);
    const amountNum = parseFloat(amountStr);
    if (isNaN(amountNum) || amountNum <= 0) {
      throw new BadRequestException({
        status: 'error',
        message: 'Please enter a valid amount.',
      });
    }

    const prices = await this.priceService.getCoinPrices([coinSymbol]);
    const usdValue = (prices[coinSymbol] ?? 1) * amountNum;
    if (usdValue < MIN_TRANSFER_USD) {
      throw new BadRequestException({
        status: 'error',
        message: `Minimum transfer amount is $${MIN_TRANSFER_USD} equivalent.`,
      });
    }
    if (usdValue > MAX_TRANSFER_USD) {
      throw new BadRequestException({
        status: 'error',
        message: `Maximum transfer amount per transaction is ${MAX_TRANSFER_USD.toLocaleString()} USD or its currency equivalent.`,
      });
    }

    const network = COIN_TO_NETWORK_MAP[coinSymbol] ?? coinSymbol;
    const senderWallet = await this.walletRepository.findOne({
      where: { userId, coinId: coin.id },
      relations: ['coin'],
    });

    const available = senderWallet
      ? parseFloat(senderWallet.balance) -
        parseFloat(senderWallet.lockedBalance || '0')
      : 0;

    if (amountNum > available) {
      throw new BadRequestException({
        status: 'error',
        message: 'Insufficient balance.',
      });
    }

    const recipient = dto.recipient.trim();
    let recipientType: RecipientType;
    let fee = '0';
    let recipientName: string | null = null;
    let isRegistered = true;

    if (isPhoneNumber(recipient)) {
      recipientType = RecipientType.INTERNAL;
      const recipientUser = await this.userRepository.findOne({
        where: { fullMobileNumber: recipient },
      });
      if (!recipientUser) {
        isRegistered = false;
      } else {
        const recipientKyc = await this.userKycRepository.findOne({
          where: { userId: recipientUser.id, provider: KycProvider.BINANCE },
        });
        if (
          !recipientKyc ||
          recipientKyc.status !== KycStatus.APPROVED
        ) {
          throw new BadRequestException({
            status: 'error',
            code: ErrorCodes.RECIPIENT_KYC_REQUIRED,
            message: `Sending failed! User has not completed the KYC yet.`,
          });
        }
        recipientName = recipientUser.fullMobileNumber;
      }
    } else {
      recipientType = RecipientType.EXTERNAL;
      if (
        recipient.length < MIN_ADDRESS_LENGTH ||
        recipient.length > MAX_ADDRESS_LENGTH
      ) {
        throw new BadRequestException({
          status: 'error',
          message:
            'Please enter the correct recipient address or phone number.',
        });
      }
      const externalFeePercent =
        await this.systemSettingsService.getExternalTransferFeePercent();
      fee =
        externalFeePercent > 0
          ? (amountNum * externalFeePercent).toFixed(coin.decimals)
          : '0';
    }

    return successResponse({
      coin: coinSymbol,
      network,
      amount: amountStr,
      amountUsd: usdValue.toFixed(2),
      fee,
      sentAmount: amountStr,
      available: available.toFixed(coin.decimals),
      recipientType,
      recipientName: recipientName ? maskAddress(recipientName) : null,
      isRegistered,
    });
  }
}
