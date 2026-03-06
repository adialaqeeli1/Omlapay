import {
  Injectable,
  BadRequestException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import {
  AdminEntity,
  AdminOtpEntity,
  AdminAuditLogEntity,
  TransactionEntity,
  SwapEntity,
  UserEntity,
  CoinEntity,
} from '@common/database/model';
import {
  TransactionDirection,
  TransactionType,
  TransactionStatus,
} from '@common/database/model';
import { SwapStatus } from '@common/database/model';
import { SystemSettingsService } from '@common/services/system-settings/system-settings.service';
import { PriceService } from '@common/services/binance/price.service';
import { MailService } from '@common/services/mail/mail.service';
import { generateOTP, generateHash } from '@common/filters';
import { InitiateFeeUpdateDto, ConfirmFeeUpdateDto, FeeType } from './dto/update-fee.dto';
import {
  AdminTransactionListDto,
  AdminTransactionType,
} from './dto/transaction-list.dto';

const FEE_OTP_PREFIX = 'FEE_UPDATE:';
const OTP_EXPIRY_MINUTES = 10;
const OTP_MAX_ATTEMPTS = 3;

@Injectable()
export class AdminFeesService {
  private readonly logger = new Logger(AdminFeesService.name);

  constructor(
    @InjectRepository(AdminEntity)
    private adminRepository: Repository<AdminEntity>,
    @InjectRepository(AdminOtpEntity)
    private adminOtpRepository: Repository<AdminOtpEntity>,
    @InjectRepository(AdminAuditLogEntity)
    private adminAuditLogRepository: Repository<AdminAuditLogEntity>,
    @InjectRepository(TransactionEntity)
    private transactionRepository: Repository<TransactionEntity>,
    @InjectRepository(SwapEntity)
    private swapRepository: Repository<SwapEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    private systemSettingsService: SystemSettingsService,
    private priceService: PriceService,
    private mailService: MailService,
  ) {}

  private async createAuditLog(
    action: string,
    adminId: string | null,
    metadata: Record<string, unknown> | null,
    ipAddress: string | null,
  ): Promise<void> {
    await this.adminAuditLogRepository.save({
      adminId,
      action,
      metadata,
      ipAddress,
    });
  }

  /**
   * Get current fee percentages (external transfer and swap).
   */
  async getFees(): Promise<{
    externalTransferFeePercent: number;
    swapFeePercent: number;
  }> {
    const [externalTransferFeePercent, swapFeePercent] = await Promise.all([
      this.systemSettingsService.getExternalTransferFeePercent(),
      this.systemSettingsService.getSwapFeePercent(),
    ]);
    return {
      externalTransferFeePercent: externalTransferFeePercent * 100,
      swapFeePercent: swapFeePercent * 100,
    };
  }

  /**
   * Initiate fee update: send OTP to admin email. Requires Super Admin.
   */
  async initiateFeeUpdate(
    adminId: string,
    dto: InitiateFeeUpdateDto,
    ipAddress?: string,
  ): Promise<{ message: string; maskedEmail: string }> {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin || !admin.email) {
      throw new NotFoundException('Admin email not found');
    }

    const sentTo = `${FEE_OTP_PREFIX}${admin.email}`;

    await this.adminOtpRepository.update(
      { adminId, isUsed: false },
      { isUsed: true },
    );

    const otp = generateOTP();
    const otpHash = generateHash(otp);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + OTP_EXPIRY_MINUTES);

    await this.adminOtpRepository.save({
      adminId,
      otpCode: otpHash,
      sentTo,
      expiresAt,
      attemptCount: 0,
      isUsed: false,
    });

    await this.mailService.sendOTP(admin.email, otp);

    await this.createAuditLog(
      'FEE_UPDATE_INITIATED',
      adminId,
      { feeType: dto.feeType, value: dto.value },
      ipAddress ?? null,
    );
    this.logger.log(`Fee update initiated for ${dto.feeType} by admin ${adminId}`);

    const maskedEmail = this.maskEmail(admin.email);
    return {
      message: 'OTP sent to your email address',
      maskedEmail,
    };
  }

  /**
   * Confirm fee update: verify OTP and apply new fee value.
   */
  async confirmFeeUpdate(
    adminId: string,
    dto: ConfirmFeeUpdateDto,
    ipAddress?: string,
  ): Promise<{ message: string; feeType: string; value: number }> {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin || !admin.email) {
      throw new NotFoundException('Admin email not found');
    }

    const sentTo = `${FEE_OTP_PREFIX}${admin.email}`;

    const otpRequest = await this.adminOtpRepository.findOne({
      where: { adminId, sentTo, isUsed: false },
      order: { createdAt: 'DESC' },
    });

    if (!otpRequest) {
      throw new BadRequestException('Invalid OTP. Please request a new one.');
    }

    if (otpRequest.expiresAt < new Date()) {
      throw new BadRequestException('OTP expired. Please resend.');
    }

    if (otpRequest.attemptCount >= OTP_MAX_ATTEMPTS) {
      throw new BadRequestException('Too many attempts. Please request a new OTP.');
    }

    const otpHash = generateHash(dto.otp);
    if (otpHash !== otpRequest.otpCode) {
      otpRequest.attemptCount += 1;
      await this.adminOtpRepository.save(otpRequest);
      throw new BadRequestException('Invalid OTP');
    }

    otpRequest.isUsed = true;
    await this.adminOtpRepository.save(otpRequest);

    if (dto.feeType === FeeType.EXTERNAL_TRANSFER) {
      await this.systemSettingsService.setExternalTransferFeePercent(dto.value);
    } else {
      await this.systemSettingsService.setSwapFeePercent(dto.value);
    }

    await this.createAuditLog(
      'FEE_UPDATED',
      adminId,
      { feeType: dto.feeType, value: dto.value },
      ipAddress ?? null,
    );
    this.logger.log(`Fee ${dto.feeType} updated to ${dto.value}% by admin ${adminId}`);

    return {
      message: 'Fee updated successfully',
      feeType: dto.feeType,
      value: dto.value,
    };
  }

  /** Mask email for display (e.g. j***n@example.com). */
  private maskEmail(email: string): string {
    if (!email) return '';
    const [local, domain] = email.split('@');
    if (!domain) return '***';
    if (local.length <= 2) return `${local[0]}***@${domain}`;
    return `${local[0]}${'*'.repeat(local.length - 2)}${local[local.length - 1]}@${domain}`;
  }

  /**
   * Get profit metrics in USD: External Transfer Profit, Swap Profit, Total Profit.
   */
  async getProfitMetrics(fromDate?: string, toDate?: string): Promise<{
    externalTransferProfitUsd: string;
    swapProfitUsd: string;
    totalProfitUsd: string;
  }> {
    const dateFilter = this.buildDateFilter(fromDate, toDate);

    const externalTxWhere: Record<string, unknown> = {
      direction: TransactionDirection.OUT,
      txType: TransactionType.SENT,
      status: TransactionStatus.COMPLETED,
    };
    if (dateFilter) externalTxWhere.createdAt = dateFilter;

    const externalTxs = await this.transactionRepository.find({
      where: externalTxWhere,
      relations: ['coin'],
    });

    const swapWhere: Record<string, unknown> = {
      status: SwapStatus.COMPLETED,
    };
    if (dateFilter) swapWhere.createdAt = dateFilter;

    const swaps = await this.swapRepository.find({
      where: swapWhere,
      relations: ['toCoin'],
    });

    const coinSymbols = new Set<string>();
    externalTxs.forEach((tx) => coinSymbols.add(tx.coin.symbol));
    swaps.forEach((s) => coinSymbols.add(s.toCoin.symbol));

    const prices = await this.priceService.getCoinPrices([...coinSymbols]);

    let externalProfitUsd = 0;
    for (const tx of externalTxs) {
      const feeNum = parseFloat(tx.fee);
      if (feeNum > 0) {
        const price = prices[tx.coin.symbol] ?? 0;
        externalProfitUsd += feeNum * price;
      }
    }

    let swapProfitUsd = 0;
    for (const s of swaps) {
      const feeNum = parseFloat(s.fee);
      if (feeNum > 0) {
        const price = prices[s.toCoin.symbol] ?? 0;
        swapProfitUsd += feeNum * price;
      }
    }

    const totalProfitUsd = externalProfitUsd + swapProfitUsd;

    return {
      externalTransferProfitUsd: externalProfitUsd.toFixed(2),
      swapProfitUsd: swapProfitUsd.toFixed(2),
      totalProfitUsd: totalProfitUsd.toFixed(2),
    };
  }

  /**
   * Truncate address for display (e.g. 0x1234...5678).
   */
  private truncateAddress(address: string, head = 8, tail = 8): string {
    if (!address || address.length <= head + tail) return address;
    return `${address.slice(0, head)}...${address.slice(-tail)}`;
  }

  /**
   * List fee-bearing transactions with filters and search.
   */
  async getTransactions(dto: AdminTransactionListDto): Promise<{
    data: Array<{
      id: string;
      transactionType: AdminTransactionType;
      from: string;
      to: string;
      amount: string;
      amountUsd: string;
      coinSymbol: string;
      profitEarned: string;
      profitEarnedUsd: string;
      createdAt: Date;
    }>;
    pagination: {
      page: number;
      limit: number;
      totalRecords: number;
      totalPages: number;
    };
  }> {
    const page = dto.page ?? 1;
    const limit = dto.limit ?? 20;
    const skip = (page - 1) * limit;
    const typeFilter = dto.transactionType;
    const senderEmail = dto.senderEmail?.trim().toLowerCase();
    const fromDate = dto.fromDate ? new Date(dto.fromDate) : null;
    const toDate = dto.toDate ? new Date(dto.toDate) : null;

    const items: Array<{
      id: string;
      transactionType: AdminTransactionType;
      from: string;
      to: string;
      amount: string;
      amountUsd: string;
      coinSymbol: string;
      profitEarned: string;
      profitEarnedUsd: string;
      createdAt: Date;
    }> = [];

    if (!typeFilter || typeFilter === AdminTransactionType.EXTERNAL_TRANSFER) {
      let txQuery = this.transactionRepository
        .createQueryBuilder('tx')
        .innerJoinAndSelect('tx.user', 'user')
        .innerJoinAndSelect('tx.coin', 'coin')
        .where('tx.direction = :dir', { dir: TransactionDirection.OUT })
        .andWhere('tx.txType = :type', { type: TransactionType.SENT })
        .andWhere('tx.status = :status', { status: TransactionStatus.COMPLETED })
        .andWhere('CAST(tx.fee AS DECIMAL) > 0');

      if (fromDate) {
        txQuery = txQuery.andWhere('tx.createdAt >= :fromDate', { fromDate });
      }
      if (toDate) {
        txQuery = txQuery.andWhere('tx.createdAt <= :toDate', { toDate });
      }
      if (senderEmail) {
        txQuery = txQuery.andWhere('LOWER(user.email) = :senderEmail', {
          senderEmail,
        });
      }

      const externalTxs = await txQuery
        .orderBy('tx.createdAt', 'DESC')
        .getMany();

      for (const tx of externalTxs) {
        const toDisplay =
          tx.receiverAddress && tx.receiverAddress.length > 0
            ? this.truncateAddress(tx.receiverAddress)
            : 'External';
        items.push({
          id: tx.id,
          transactionType: AdminTransactionType.EXTERNAL_TRANSFER,
          from: tx.user.email ?? tx.user.fullMobileNumber ?? tx.userId,
          to: toDisplay,
          amount: tx.amount,
          amountUsd: '0',
          coinSymbol: tx.coin.symbol,
          profitEarned: tx.fee,
          profitEarnedUsd: '0',
          createdAt: tx.createdAt,
        });
      }
    }

    if (!typeFilter || typeFilter === AdminTransactionType.SWAP) {
      let swapQuery = this.swapRepository
        .createQueryBuilder('swap')
        .innerJoinAndSelect('swap.user', 'user')
        .innerJoinAndSelect('swap.toCoin', 'toCoin')
        .where('swap.status = :status', { status: SwapStatus.COMPLETED })
        .andWhere('CAST(swap.fee AS DECIMAL) > 0');

      if (fromDate) {
        swapQuery = swapQuery.andWhere('swap.createdAt >= :fromDate', {
          fromDate,
        });
      }
      if (toDate) {
        swapQuery = swapQuery.andWhere('swap.createdAt <= :toDate', {
          toDate,
        });
      }
      if (senderEmail) {
        swapQuery = swapQuery.andWhere('LOWER(user.email) = :senderEmail', {
          senderEmail,
        });
      }

      const swaps = await swapQuery
        .orderBy('swap.createdAt', 'DESC')
        .getMany();

      for (const s of swaps) {
        items.push({
          id: s.id,
          transactionType: AdminTransactionType.SWAP,
          from: s.user.email ?? s.user.fullMobileNumber ?? s.userId,
          to: 'Internal Swap',
          amount: s.fromAmount,
          amountUsd: '0',
          coinSymbol: s.toCoin.symbol,
          profitEarned: s.fee,
          profitEarnedUsd: '0',
          createdAt: s.createdAt,
        });
      }
    }

    items.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

    const coinSymbols = [...new Set(items.map((i) => i.coinSymbol))];
    const prices =
      coinSymbols.length > 0
        ? await this.priceService.getCoinPrices(coinSymbols)
        : {};

    for (const item of items) {
      const price = prices[item.coinSymbol] ?? 0;
      item.profitEarnedUsd = (parseFloat(item.profitEarned) * price).toFixed(2);
      item.amountUsd = (parseFloat(item.amount) * price).toFixed(2);
    }

    const totalRecords = items.length;
    const paginatedItems = items.slice(skip, skip + limit);

    return {
      data: paginatedItems,
      pagination: {
        page,
        limit,
        totalRecords,
        totalPages: Math.ceil(totalRecords / limit),
      },
    };
  }

  /** Build date filter for Between/MoreThanOrEqual/LessThanOrEqual. */
  private buildDateFilter(
    fromDate?: string,
    toDate?: string,
  ): ReturnType<typeof Between> | ReturnType<typeof MoreThanOrEqual> | ReturnType<typeof LessThanOrEqual> | null {
    if (!fromDate && !toDate) return null;
    const from = fromDate ? new Date(fromDate) : undefined;
    const to = toDate ? new Date(toDate) : undefined;
    if (from && to) return Between(from, to);
    if (from) return MoreThanOrEqual(from);
    if (to) return LessThanOrEqual(to);
    return null;
  }
}
