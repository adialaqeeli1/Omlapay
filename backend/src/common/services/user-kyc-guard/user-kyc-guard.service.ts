import {
  Injectable,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity, UserKycEntity } from '@common/database/model';
import { KycStatus, KycProvider } from '@common/database/model';
import { ErrorCodes } from '@common/constants';

export type KycRequiredAction = 'send' | 'swap' | 'receive';

const ACTION_MESSAGES: Record<
  KycRequiredAction,
  { kyc: string; apiKeys: string }
> = {
  send: {
    kyc: 'Identity verification is required to send coins. Please complete your KYC profile to enable transfers.',
    apiKeys: 'Wallet not ready. Please complete KYC to generate wallet addresses.',
  },
  swap: {
    kyc: 'Complete KYC to continue.',
    apiKeys: 'Wallet not ready. Please complete KYC.',
  },
  receive: {
    kyc: 'Please complete KYC to receive funds',
    apiKeys: 'Wallet not ready. Please complete KYC to generate wallet addresses.',
  },
};

/**
 * Shared guard for KYC + API keys validation.
 * Used by Send, Swap, Receive services to avoid duplication.
 */
@Injectable()
export class UserKycGuardService {
  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(UserKycEntity)
    private userKycRepository: Repository<UserKycEntity>,
  ) {}

  /**
   * Assert user has completed Binance KYC and has API keys.
   * @returns UserEntity if valid
   * @throws ForbiddenException if KYC or API keys missing
   */
  async assertUserCanPerformAction(
    userId: string,
    action: KycRequiredAction,
  ): Promise<UserEntity> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new BadRequestException({
        status: 'error',
        message: 'User not found.',
      });
    }

    const kyc = await this.userKycRepository.findOne({
      where: { userId, provider: KycProvider.BINANCE },
    });

    if (!kyc || kyc.status !== KycStatus.APPROVED) {
      const msg = ACTION_MESSAGES[action].kyc;
      throw new ForbiddenException({
        status: 'error',
        code: ErrorCodes.KYC_REQUIRED,
        message: msg,
        ...(action === 'receive' && { cta: { cancel: true, goToKyc: true } }),
        ...(action === 'send' && { cta: { verifyNow: true } }),
      });
    }

    if (!user.binanceApiKey || !user.binanceSecretKey) {
      throw new ForbiddenException({
        status: 'error',
        code: ErrorCodes.API_KEYS_MISSING,
        message: ACTION_MESSAGES[action].apiKeys,
      });
    }

    return user;
  }
}
