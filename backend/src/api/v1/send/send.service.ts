import {
  Injectable,
  BadRequestException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import * as crypto from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import {
  UserEntity,
  UserKycEntity,
  CoinEntity,
  TransactionEntity,
  WalletEntity,
  OtpRequestEntity,
  SendPendingRequestEntity,
  NotificationEntity,
} from '@common/database/model';
import { KycStatus, KycProvider } from '@common/database/model';
import {
  TransactionDirection,
  TransactionType,
  TransactionStatus,
} from '@common/database/model';
import { RecipientType } from '@common/database/model';
import { OtpPurpose } from '@common/database/model';
import { WithdrawalService } from '@common/services/binance/withdrawal.service';
import { UserKycGuardService } from '@common/services/user-kyc-guard/user-kyc-guard.service';
import { SendQuoteUseCase } from './use-cases/send-quote.use-case';
import { SendHistoryUseCase } from './use-cases/send-history.use-case';
import { OtpService } from '@common/services/otp/otp.service';
import { successResponse, maskAddress } from '@common/utils';
import { generateOTP, generateHash } from '@common/filters';
import { COIN_TO_NETWORK_MAP } from '@common/constants';
import { SEND_ESTIMATED_COMPLETION_MS } from './send.constants';
import { NotificationType, NotificationReferenceType } from '@common/database/model';

/** Detect if recipient is phone (internal) or wallet address (external) */
function isPhoneNumber(value: string): boolean {
  return /^\+[1-9]\d{1,14}$/.test(value.trim());
}

/** Deterministic idempotency key for send confirmation retries. */
function generateSendIdempotencyKey(userId: string, pendingId: string, amount: number): string {
  const hash = crypto
    .createHash('sha256')
    .update(`${userId}-${pendingId}-${amount}`)
    .digest('hex')
    .substring(0, 16);
  return `send-${userId}-${pendingId}-${hash}`;
}

@Injectable()
export class SendService {
  private readonly logger = new Logger(SendService.name);

  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(UserKycEntity)
    private userKycRepository: Repository<UserKycEntity>,
    @InjectRepository(CoinEntity)
    private coinRepository: Repository<CoinEntity>,
    @InjectRepository(WalletEntity)
    private walletRepository: Repository<WalletEntity>,
    @InjectRepository(TransactionEntity)
    private transactionRepository: Repository<TransactionEntity>,
    @InjectRepository(OtpRequestEntity)
    private otpRepository: Repository<OtpRequestEntity>,
    @InjectRepository(SendPendingRequestEntity)
    private sendPendingRepository: Repository<SendPendingRequestEntity>,
    @InjectRepository(NotificationEntity)
    private notificationRepository: Repository<NotificationEntity>,
    private userKycGuardService: UserKycGuardService,
    private sendQuoteUseCase: SendQuoteUseCase,
    private sendHistoryUseCase: SendHistoryUseCase,
    private withdrawalService: WithdrawalService,
    private otpService: OtpService,
    private dataSource: DataSource,
  ) {}

  private assertBinanceKeys(user: { binanceApiKey?: string | null; binanceSecretKey?: string | null }): void {
    if (!user.binanceApiKey || !user.binanceSecretKey) {
      throw new BadRequestException({
        status: 'error',
        message: 'Binance API keys not configured. Please complete KYC.',
      });
    }
  }

  /**
   * Get send quote: validate recipient, return fees, balance, and USD value.
   * Delegates to SendQuoteUseCase.
   */
  async getQuote(
    userId: string,
    dto: { coin: string; recipient: string; amount: number },
  ) {
    return this.sendQuoteUseCase.execute(userId, dto);
  }

  /**
   * Initiate send: validate, create OTP, store pending request, return sendToken.
   */
  async initiate(userId: string, dto: { coin: string; recipient: string; amount: number; network?: string }) {
    const quote = await this.sendQuoteUseCase.execute(userId, dto);
    if (quote.status !== 'success' || !quote.data) {
      throw new BadRequestException(quote);
    }

    const user = await this.userRepository.findOneOrFail({ where: { id: userId } });
    const coin = await this.coinRepository.findOneOrFail({
      where: { symbol: dto.coin.toUpperCase(), isActive: true },
    });

    const recipient = dto.recipient.trim();
    const isInternal = isPhoneNumber(recipient);
    const network = dto.network ?? COIN_TO_NETWORK_MAP[coin.symbol] ?? coin.symbol;

    let recipientUserId: string | null = null;
    let recipientWalletId: string | null = null;
    let recipientAddress: string | null = null;
    let addressTag: string | null = null;

    if (isInternal) {
      const recipientUser = await this.userRepository.findOne({
        where: { fullMobileNumber: recipient },
      });
      if (!recipientUser) {
        throw new BadRequestException({
          status: 'error',
          code: 'RECIPIENT_NOT_REGISTERED',
          message: 'This number does not have an account on Omlapay. You can still complete the transaction to an external address.',
          canProceed: false,
        });
      }
      const recipientKyc = await this.userKycRepository.findOne({
        where: { userId: recipientUser.id, provider: KycProvider.BINANCE },
      });
      if (!recipientKyc || recipientKyc.status !== KycStatus.APPROVED) {
        throw new BadRequestException({
          status: 'error',
          message: 'Sending failed! User has not completed the KYC yet.',
        });
      }
      const rWallet = await this.walletRepository.findOne({
        where: { userId: recipientUser.id, coinId: coin.id },
      });
      if (!rWallet) {
        throw new BadRequestException({
          status: 'error',
          message: 'Recipient wallet not found.',
        });
      }
      recipientUserId = recipientUser.id;
      recipientWalletId = rWallet.id;
      recipientAddress = rWallet.address;
    } else {
      recipientAddress = recipient;
    }

    const amountStr = String(dto.amount);
    const fee = isInternal ? '0' : quote.data.fee;

    const otp = user.fullMobileNumber?.startsWith('+91') ? '666666' : generateOTP();
    const otpHash = generateHash(otp);
    const expiresAt = new Date();
    expiresAt.setSeconds(expiresAt.getSeconds() + 60);

    const otpRequest = await this.otpRepository.save(
      this.otpRepository.create({
        fullMobileNumber: user.fullMobileNumber,
        email: null,
        otpHash,
        purpose: OtpPurpose.SEND_VERIFICATION,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts: 0,
      }),
    );

    const pending = await this.sendPendingRepository.save(
      this.sendPendingRepository.create({
        userId,
        otpRequestId: otpRequest.id,
        recipientType: isInternal ? RecipientType.INTERNAL : RecipientType.EXTERNAL,
        recipientIdentifier: recipient,
        coinId: coin.id,
        network,
        amount: amountStr,
        fee,
        recipientUserId,
        recipientWalletId,
        recipientAddress,
        addressTag,
        expiresAt,
      }),
    );

    await this.otpService.sendOTP(user.fullMobileNumber, otp);

    return successResponse(
      {
        sendToken: pending.id,
        otpExpirySeconds: 60,
        ...(process.env.NODE_ENV !== 'production' && { otp }),
      },
      'Verification code sent to your phone number.',
    );
  }

  /**
   * Resend OTP for an existing send request.
   * Creates a new OTP and extends the pending request expiry.
   */
  async resendOtp(userId: string, sendToken: string) {
    const pending = await this.sendPendingRepository.findOne({
      where: { id: sendToken, userId },
      relations: ['user', 'coin'],
    });

    if (!pending) {
      throw new NotFoundException({
        status: 'error',
        message: 'Invalid or expired send request. Please start again.',
      });
    }

    if (new Date() > pending.expiresAt) {
      await this.sendPendingRepository.delete({ id: pending.id });
      throw new BadRequestException({
        status: 'error',
        message: 'Send request expired. Please start again.',
      });
    }

    const user = await this.userRepository.findOneOrFail({
      where: { id: userId },
    });

    const otp = user.fullMobileNumber?.startsWith('+91') ? '666666' : generateOTP();
    const otpHash = generateHash(otp);
    const expiresAt = new Date();
    expiresAt.setSeconds(expiresAt.getSeconds() + 60);

    const otpRequest = await this.otpRepository.save(
      this.otpRepository.create({
        fullMobileNumber: user.fullMobileNumber,
        email: null,
        otpHash,
        purpose: OtpPurpose.SEND_VERIFICATION,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts: 0,
      }),
    );

    pending.otpRequestId = otpRequest.id;
    pending.expiresAt = expiresAt;
    await this.sendPendingRepository.save(pending);

    await this.otpService.sendOTP(user.fullMobileNumber, otp);

    this.logger.log(`OTP resent for send request ${sendToken}`);

    return successResponse(
      {
        sendToken: pending.id,
        otpExpirySeconds: 60,
        ...(process.env.NODE_ENV !== 'production' && { otp }),
      },
      'Verification code resent to your phone number.',
    );
  }

  /**
   * Confirm send: verify OTP and execute transfer.
   */
  async confirm(userId: string, dto: { sendToken: string; otp: string }) {
    const pending = await this.sendPendingRepository.findOne({
      where: { id: dto.sendToken, userId },
      relations: ['coin', 'user'],
    });

    if (!pending) {
      throw new NotFoundException({
        status: 'error',
        message: 'Invalid or expired send request. Please start again.',
      });
    }

    if (new Date() > pending.expiresAt) {
      await this.sendPendingRepository.delete({ id: pending.id });
      throw new BadRequestException({
        status: 'error',
        message: 'Send request expired. Please start again.',
      });
    }

    const otpRequest = await this.otpRepository.findOne({
      where: { id: pending.otpRequestId },
    });

    if (!otpRequest || otpRequest.isConsumed) {
      throw new BadRequestException({
        status: 'error',
        message: 'Invalid or expired verification code.',
      });
    }

    if (otpRequest.attempts >= otpRequest.maxAttempts) {
      throw new BadRequestException({
        status: 'error',
        message: 'Maximum attempts reached. Please resend OTP.',
      });
    }

    const expectedHash = generateHash(dto.otp);
    const isValid = expectedHash === otpRequest.otpHash;
    if (!isValid) {
      otpRequest.attempts += 1;
      await this.otpRepository.save(otpRequest);
      throw new BadRequestException({
        status: 'error',
        message: `Incorrect verification code. ${otpRequest.maxAttempts - otpRequest.attempts} attempt(s) remaining.`,
      });
    }

    otpRequest.isConsumed = true;
    await this.otpRepository.save(otpRequest);

    const user = await this.userKycGuardService.assertUserCanPerformAction(userId, 'send');
    const senderWallet = await this.walletRepository.findOne({
      where: { userId, coinId: pending.coinId },
      relations: ['coin'],
    });

    if (!senderWallet) {
      throw new BadRequestException({
        status: 'error',
        message: 'Sender wallet not found.',
      });
    }

    const amount = parseFloat(pending.amount);
    const available = parseFloat(senderWallet.balance) - parseFloat(senderWallet.lockedBalance || '0');
    if (amount > available) {
      throw new BadRequestException({
        status: 'error',
        message: 'Insufficient balance.',
      });
    }

    const idempotencyKey = generateSendIdempotencyKey(userId, pending.id, amount);

    let transactionId: string;

    if (pending.recipientType === RecipientType.INTERNAL && pending.recipientUserId && pending.recipientWalletId) {
      transactionId = await this.executeInternalTransfer(
        userId,
        pending.recipientUserId,
        pending.coinId,
        senderWallet.id,
        pending.recipientWalletId,
        pending.amount,
        pending.fee,
        pending.network,
        pending.recipientIdentifier,
        idempotencyKey,
      );
    } else if (pending.recipientAddress) {
      this.assertBinanceKeys(user);
      transactionId = await this.executeExternalWithdrawal(
        user,
        senderWallet,
        pending.amount,
        pending.fee,
        pending.network,
        pending.recipientAddress,
        pending.addressTag,
        idempotencyKey,
      );
    } else {
      throw new BadRequestException({
        status: 'error',
        message: 'Invalid send request.',
      });
    }

    await this.sendPendingRepository.delete({ id: pending.id });

    return successResponse(
      {
        transactionId,
        amount: pending.amount,
        coin: pending.coin.symbol,
        status: 'PROCESSING',
        estimatedCompletion: new Date(Date.now() + SEND_ESTIMATED_COMPLETION_MS).toISOString(),
      },
      'Send in progress. You will receive a confirmation notification upon completion.',
    );
  }

  private async executeInternalTransfer(
    senderId: string,
    recipientId: string,
    coinId: string,
    senderWalletId: string,
    recipientWalletId: string,
    amount: string,
    fee: string,
    network: string,
    counterpartyPhone: string,
    idempotencyKey: string,
  ): Promise<string> {
    const senderWallet = await this.walletRepository.findOneOrFail({
      where: { id: senderWalletId },
      relations: ['coin'],
    });
    const recipientWallet = await this.walletRepository.findOneOrFail({
      where: { id: recipientWalletId },
      relations: ['coin', 'user'],
    });

    const amountNum = parseFloat(amount);
    if (isNaN(amountNum) || amountNum <= 0) {
      throw new BadRequestException({ status: 'error', message: 'Invalid amount' });
    }

    let outTxId = idempotencyKey;
    await this.dataSource.transaction(async (em) => {
      await em.query(
        `UPDATE wallets SET balance = balance - $1::numeric, "updatedAt" = $2 WHERE id = $3`,
        [amountNum, new Date(), senderWalletId],
      );
      await em.query(
        `UPDATE wallets SET balance = balance + $1::numeric, "updatedAt" = $2 WHERE id = $3`,
        [amountNum, new Date(), recipientWalletId],
      );

      const outTx = em.create(TransactionEntity, {
        userId: senderId,
        coinId,
        walletId: senderWalletId,
        direction: TransactionDirection.OUT,
        txType: TransactionType.SENT,
        amount,
        fee,
        status: TransactionStatus.COMPLETED,
        network,
        senderAddress: senderWallet.address,
        receiverAddress: recipientWallet.address,
        counterpartyPhone,
        idempotencyKey: `${idempotencyKey}-out`,
        provider: 'BINANCE' as any,
      });
      const savedOutTx = await em.save(outTx);
      outTxId = savedOutTx.id;

      const inTx = em.create(TransactionEntity, {
        userId: recipientId,
        coinId,
        walletId: recipientWalletId,
        direction: TransactionDirection.IN,
        txType: TransactionType.RECEIVED,
        amount,
        fee: '0',
        status: TransactionStatus.COMPLETED,
        network,
        senderAddress: senderWallet.address,
        receiverAddress: recipientWallet.address,
        counterpartyPhone: null,
        idempotencyKey: `${idempotencyKey}-in`,
        provider: 'BINANCE' as any,
      });
      const savedInTx = await em.save(inTx);

      await em.save(
        em.create(NotificationEntity, {
          userId: recipientId,
          type: NotificationType.TX,
          title: 'Received',
          message: `You have received ${amount} ${senderWallet.coin.symbol} in your Omlapay wallet.`,
          referenceId: savedInTx.id,
          referenceType: NotificationReferenceType.TRANSACTION,
        }),
      );

      await em.save(
        em.create(NotificationEntity, {
          userId: senderId,
          type: NotificationType.TX,
          title: 'Sent',
          message: `Your transaction of ${amount} ${senderWallet.coin.symbol} has been successfully sent.`,
          referenceId: outTxId,
          referenceType: NotificationReferenceType.TRANSACTION,
        }),
      );
    });

    return outTxId;
  }

  private async executeExternalWithdrawal(
    user: UserEntity,
    senderWallet: WalletEntity,
    amount: string,
    fee: string,
    network: string,
    address: string,
    addressTag: string | null,
    idempotencyKey: string,
  ): Promise<string> {
    const amountNum = parseFloat(amount);
    const feeNum = parseFloat(fee);
    const amountToSend = Math.max(0, amountNum - feeNum).toFixed(
      senderWallet.coin?.decimals ?? 8,
    );

    let tx: TransactionEntity;
    try {
      const result = await this.withdrawalService.withdraw(
        user.binanceApiKey!,
        user.binanceSecretKey!,
        {
          coin: senderWallet.coin.symbol,
          network,
          address,
          amount: amountToSend,
          addressTag: addressTag ?? undefined,
        },
      );

      tx = await this.transactionRepository.save(
        this.transactionRepository.create({
          userId: user.id,
          coinId: senderWallet.coinId,
          walletId: senderWallet.id,
          direction: TransactionDirection.OUT,
          txType: TransactionType.SENT,
          amount,
          fee,
          status: TransactionStatus.PROCESSING,
          network,
          senderAddress: senderWallet.address,
          receiverAddress: address,
          counterpartyPhone: null,
          idempotencyKey,
          binanceRequestId: result.id,
          provider: 'BINANCE' as any,
        }),
      );

      await this.dataSource
        .createQueryBuilder()
        .update(WalletEntity)
        .set({
          balance: () => `"balance" - ${amountNum}`,
          lockedBalance: () => `COALESCE("lockedBalance"::numeric, 0) + ${amountNum}`,
          updatedAt: new Date(),
        })
        .where('id = :id', { id: senderWallet.id })
        .execute();

      await this.notificationRepository.save(
        this.notificationRepository.create({
          userId: user.id,
          type: NotificationType.TX,
          title: 'Send in progress',
          message: `Your transaction of ${amount} ${senderWallet.coin.symbol} is being processed.`,
          referenceId: tx.id,
          referenceType: NotificationReferenceType.TRANSACTION,
        }),
      );
    } catch (err) {
      const errMsg = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`External withdrawal failed: ${errMsg}`);
      tx = await this.transactionRepository.save(
        this.transactionRepository.create({
          userId: user.id,
          coinId: senderWallet.coinId,
          walletId: senderWallet.id,
          direction: TransactionDirection.OUT,
          txType: TransactionType.SENT,
          amount,
          fee,
          status: TransactionStatus.FAILED,
          network,
          senderAddress: senderWallet.address,
          receiverAddress: address,
          counterpartyPhone: null,
          idempotencyKey,
          errorMessage: errMsg,
          provider: 'BINANCE' as any,
        }),
      );
      throw new BadRequestException({
        status: 'error',
        message: errMsg || 'Withdrawal failed. Please try again.',
      });
    }

    return tx.id;
  }

  /**
   * Get send history. Delegates to SendHistoryUseCase.
   */
  async getHistory(
    userId: string,
    query: { asset?: string; after?: string; limit?: number },
  ) {
    await this.userKycGuardService.assertUserCanPerformAction(userId, 'send');
    return this.sendHistoryUseCase.execute(userId, query);
  }

  async getTransactionDetail(userId: string, transactionId: string) {
    await this.userKycGuardService.assertUserCanPerformAction(userId, 'send');

    const tx = await this.transactionRepository.findOne({
      where: {
        id: transactionId,
        userId,
        direction: TransactionDirection.OUT,
        txType: TransactionType.SENT,
      },
      relations: ['coin', 'wallet'],
    });

    if (!tx) {
      throw new NotFoundException({
        status: 'error',
        message: 'Transaction not found.',
      });
    }

    return successResponse({
      id: tx.id,
      coinSymbol: tx.coin.symbol,
      amount: tx.amount,
      fee: tx.fee,
      status: tx.status,
      network: tx.network,
      senderAddress: maskAddress(tx.senderAddress),
      receiverAddress: maskAddress(tx.receiverAddress),
      counterpartyPhone: tx.counterpartyPhone ? maskAddress(tx.counterpartyPhone) : null,
      txHash: tx.txHash,
      errorMessage: tx.errorMessage,
      createdAt: tx.createdAt,
    });
  }

}
