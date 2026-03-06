import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity, UserKycEntity, CoinEntity } from '@common/database/model';
import { KycStatus, KycProvider } from '@common/database/model';
import { maskPhoneNumber, maskEmail } from '@common/utils';
import { successResponse } from '@common/utils/response.util';
import { DepositAddressService } from '@common/services/binance/deposit-address.service';
import { SUPPORTED_NETWORKS } from '@common/constants';

/**
 * Handles user account details (phone, email, wallet addresses).
 * Extracted from UserService for SRP.
 */
@Injectable()
export class UserAccountService {
  private readonly logger = new Logger(UserAccountService.name);

  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(UserKycEntity)
    private userKycRepository: Repository<UserKycEntity>,
    @InjectRepository(CoinEntity)
    private coinRepository: Repository<CoinEntity>,
    private depositAddressService: DepositAddressService,
  ) {}

  async getAccountDetails(userId: string) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new BadRequestException({
        status: 'error',
        message: 'User not found.',
      });
    }

    const phone = maskPhoneNumber(user.fullMobileNumber);
    const email = user.email ? maskEmail(user.email) : null;

    const kyc = await this.userKycRepository.findOne({
      where: { userId, provider: KycProvider.BINANCE },
    });

    const hasKycAndKeys =
      kyc?.status === KycStatus.APPROVED &&
      !!user.binanceApiKey &&
      !!user.binanceSecretKey;

    const wallets: Array<{
      network: string;
      networkDisplayName: string;
      coins: Array<{
        symbol: string;
        name: string;
        address: string;
        addressTag: string | null;
      }>;
    }> = [];

    if (hasKycAndKeys) {
      const coinCache = new Map<string, CoinEntity>();
      for (const net of SUPPORTED_NETWORKS) {
        const coins: Array<{
          symbol: string;
          name: string;
          address: string;
          addressTag: string | null;
        }> = [];

        for (const symbol of net.coins) {
          try {
            const result = await this.depositAddressService.getDepositAddress(
              user.binanceApiKey!,
              user.binanceSecretKey!,
              symbol,
              net.network,
            );

            let coin = coinCache.get(symbol);
            if (!coin) {
              const found = await this.coinRepository.findOne({
                where: { symbol, isActive: true },
              });
              if (found) {
                coin = found;
                coinCache.set(symbol, coin);
              }
            }

            coins.push({
              symbol,
              name: coin?.name ?? symbol,
              address: result.address,
              addressTag: result.tag || null,
            });
          } catch (err) {
            this.logger.warn(
              `[AccountDetails] Failed to fetch address for ${symbol}/${net.network}: ${err instanceof Error ? err.message : 'Unknown error'}`,
            );
          }
        }

        if (coins.length > 0) {
          wallets.push({
            network: net.network,
            networkDisplayName: net.displayName,
            coins,
          });
        }
      }
    }

    return successResponse({
      phone,
      email,
      wallets,
      walletsAvailable: hasKycAndKeys,
    });
  }
}
