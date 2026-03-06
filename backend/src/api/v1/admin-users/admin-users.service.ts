import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity } from '@common/database/model';
import { WalletEntity } from '@common/database/model';
import { TransactionEntity, TransactionDirection } from '@common/database/model';
import { SwapEntity } from '@common/database/model';
import { UserKycEntity, KycStatus } from '@common/database/model';
import { UserStatusHistoryEntity, UserStatus } from '@common/database/model';
import {
  UserListDto,
  UserListTabFilter,
  UserListSortBy,
  UserListSortOrder,
} from './dto/user-list.dto';
import { BlockUserDto } from './dto/block-user.dto';
import {
  UserActivityListDto,
  WalletTypeFilter,
  ActivityTypeFilter,
} from './dto/user-activity-list.dto';
import { UserTransactionListDto } from './dto/user-transaction-list.dto';
import { MailService } from '@common/services/mail/mail.service';
import { getFullNameFromKyc } from '@common/utils/kyc.util';
import { maskPhoneNumber } from '@common/utils';
import { getSupportEmail } from '@common/constants';
import { AdminNotificationsService } from '../admin-notifications/admin-notifications.service';
import { AdminNotificationType } from '@common/database/model';

@Injectable()
export class AdminUsersService {
  private readonly logger = new Logger(AdminUsersService.name);

  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(WalletEntity)
    private walletRepository: Repository<WalletEntity>,
    @InjectRepository(TransactionEntity)
    private transactionRepository: Repository<TransactionEntity>,
    @InjectRepository(SwapEntity)
    private swapRepository: Repository<SwapEntity>,
    @InjectRepository(UserKycEntity)
    private userKycRepository: Repository<UserKycEntity>,
    @InjectRepository(UserStatusHistoryEntity)
    private userStatusHistoryRepository: Repository<UserStatusHistoryEntity>,
    private mailService: MailService,
    private adminNotificationsService: AdminNotificationsService,
  ) {}

  async getUserList(dto: UserListDto) {
    const {
      search,
      status,
      filter,
      dateFrom,
      dateTo,
      sortBy = UserListSortBy.CREATED_AT,
      sortOrder = UserListSortOrder.DESC,
    } = dto;

    // Enforce fixed page size of 10 as per requirements
    const page = dto.page ?? 1;
    const limit = 10;
    const skip = (page - 1) * limit;

    // Build query (base 1=1 so all filters can use andWhere)
    const queryBuilder = this.userRepository
      .createQueryBuilder('user')
      .where('1=1');

    // Apply search filter (email or mobile number)
    if (search) {
      queryBuilder.andWhere(
        '(user.fullMobileNumber ILIKE :search OR user.email ILIKE :search)',
        { search: `%${search}%` },
      );
    }

    // Apply legacy status filter (ACTIVE | BLOCKED) when no tab filter is used
    if (status) {
      const isActive = status === 'ACTIVE';
      queryBuilder.andWhere('user.isActive = :isActive', { isActive });
    }

    // Apply tab filter: All Users, KYC Users, Non-KYC Users, Blocked Users
    const effectiveFilter = filter ?? UserListTabFilter.ALL;
    if (effectiveFilter === UserListTabFilter.BLOCKED) {
      queryBuilder.andWhere('user.isActive = :isActive', { isActive: false });
    } else if (effectiveFilter === UserListTabFilter.KYC) {
      // Users who have at least one approved KYC (e.g. Sumsub)
      queryBuilder.andWhere(
        `EXISTS (SELECT 1 FROM user_kyc kyc WHERE kyc."userId" = user.id AND kyc.status = :kycApproved)`,
        { kycApproved: KycStatus.APPROVED },
      );
    } else if (effectiveFilter === UserListTabFilter.NON_KYC) {
      // Users without any approved KYC
      queryBuilder.andWhere(
        `NOT EXISTS (SELECT 1 FROM user_kyc kyc WHERE kyc."userId" = user.id AND kyc.status = :kycApproved)`,
        { kycApproved: KycStatus.APPROVED },
      );
    }
    // ALL: no extra filter

    // Apply date range filter (by user created date)
    if (dateFrom) {
      queryBuilder.andWhere('user.createdAt >= :dateFrom', {
        dateFrom: new Date(dateFrom),
      });
    }
    if (dateTo) {
      // Include full day: end of dateTo
      const toEnd = new Date(dateTo);
      toEnd.setHours(23, 59, 59, 999);
      queryBuilder.andWhere('user.createdAt <= :dateTo', { dateTo: toEnd });
    }

    // Get total count before pagination
    const total = await queryBuilder.getCount();

    // Apply sort (default: createdAt DESC)
    const orderColumn =
      sortBy === UserListSortBy.EMAIL ? 'user.email' : 'user.createdAt';
    const orderDir = sortOrder === UserListSortOrder.ASC ? 'ASC' : 'DESC';
    queryBuilder.orderBy(orderColumn, orderDir);

    // Apply pagination and fetch
    const users = await queryBuilder.skip(skip).take(limit).getMany();

    // Calculate total balance for each user
    const usersWithBalance = await Promise.all(
      users.map(async (user) => {
        const wallets = await this.walletRepository.find({
          where: { userId: user.id },
        });

        const totalBalance = wallets.reduce((sum, wallet) => {
          return sum + parseFloat(wallet.balance || '0');
        }, 0);

        // Get KYC record (if any)
        const kyc = await this.userKycRepository.findOne({
          where: { userId: user.id },
        });

        const fullNameFromKyc = getFullNameFromKyc(kyc);

        // Mask phone number (show first 3 and last 2 digits)
        const maskedPhone = maskPhoneNumber(user.fullMobileNumber);

        return {
          id: user.id,
          phoneNumber: maskedPhone,
          email: user.email || '—',
          fullName: fullNameFromKyc,
          dateRegistered: user.createdAt,
          totalBalance: totalBalance.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
          status: user.isActive ? 'ACTIVE' : 'BLOCKED',
        };
      }),
    );

    return {
      data: usersWithBalance,
      pagination: {
        page,
        limit,
        totalRecords: total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Maps WalletTypeFilter to transaction network values for DB query.
   */
  private getNetworksForWalletType(walletType: WalletTypeFilter): string[] {
    const mapping: Record<WalletTypeFilter, string[]> = {
      [WalletTypeFilter.EVM]: ['ETH', 'BNB', 'BSC'],
      [WalletTypeFilter.BITCOIN]: ['BTC'],
      [WalletTypeFilter.TRON]: ['TRX', 'TRON'],
      [WalletTypeFilter.SOLANA]: ['SOL'],
    };
    return mapping[walletType] ?? [];
  }

  async getUserDetails(userId: string) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Get wallets with coins
    const wallets = await this.walletRepository.find({
      where: { userId: user.id },
      relations: ['coin'],
    });

    // Calculate total balance
    const totalBalance = wallets.reduce((sum, wallet) => {
      return sum + parseFloat(wallet.balance || '0');
    }, 0);

    // Get KYC information
    const kyc = await this.userKycRepository.findOne({
      where: { userId: user.id },
    });

    const fullName = getFullNameFromKyc(kyc);

    return {
      id: user.id,
      phoneNumber: user.fullMobileNumber,
      email: user.email || '—',
      fullName, // From 3rd party KYC
      dateRegistered: user.createdAt,
      status: user.isActive ? 'ACTIVE' : 'BLOCKED',
      wallet: {
        totalBalance: totalBalance.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
        coins: wallets.map((wallet) => ({
          coin: wallet.coin.symbol,
          balance: wallet.balance || '0',
          publicAddress: wallet.address,
        })),
      },
    };
  }

  async getUserTransactions(
    userId: string,
    dto: UserTransactionListDto,
  ) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const page = dto.page ?? 1;
    const limit = dto.limit ?? 10;
    const skip = (page - 1) * limit;

    const queryBuilder = this.transactionRepository
      .createQueryBuilder('tx')
      .leftJoinAndSelect('tx.coin', 'coin')
      .where('tx.userId = :userId', { userId: user.id });

    if (dto.walletType) {
      const networks = this.getNetworksForWalletType(dto.walletType);
      queryBuilder.andWhere('UPPER(tx.network) IN (:...networks)', {
        networks: networks.map((n) => n.toUpperCase()),
      });
    }

    const total = await queryBuilder.getCount();

    const transactions = await queryBuilder
      .orderBy('tx.createdAt', 'DESC')
      .skip(skip)
      .take(limit)
      .getMany();

    return {
      data: transactions.map((tx) => ({
        id: tx.id,
        coin: tx.coin.symbol,
        amount: tx.amount,
        direction: tx.direction === TransactionDirection.IN ? 'RECEIVED' : 'SENT',
        from: tx.senderAddress,
        to: tx.receiverAddress,
        txHash: tx.txHash,
        status: tx.status,
        network: tx.network,
        timestamp: tx.createdAt,
      })),
      pagination: {
        page,
        limit,
        totalRecords: total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Returns combined transactions and swaps for user activity view.
   * Supports filtering by type (TRANSACTION, SWAP, ALL) and walletType (EVM, BITCOIN, TRON, SOLANA).
   */
  async getUserActivity(userId: string, dto: UserActivityListDto) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const type = dto.type ?? ActivityTypeFilter.ALL;
    const page = dto.page ?? 1;
    const limit = dto.limit ?? 10;

    const items: Array<{
      id: string;
      type: 'TRANSACTION' | 'SWAP';
      coin?: string;
      amount: string;
      direction: string;
      from?: string;
      to?: string;
      txHash: string | null;
      status: string;
      network: string;
      timestamp: Date;
      coinSent?: string;
      coinReceived?: string;
    }> = [];

    if (type === ActivityTypeFilter.ALL || type === ActivityTypeFilter.TRANSACTION) {
      const txQueryBuilder = this.transactionRepository
        .createQueryBuilder('tx')
        .leftJoinAndSelect('tx.coin', 'coin')
        .where('tx.userId = :userId', { userId: user.id });

      if (dto.walletType) {
        const networks = this.getNetworksForWalletType(dto.walletType);
        txQueryBuilder.andWhere('UPPER(tx.network) IN (:...networks)', {
          networks: networks.map((n) => n.toUpperCase()),
        });
      }

      const transactions = await txQueryBuilder
        .orderBy('tx.createdAt', 'DESC')
        .getMany();

      for (const tx of transactions) {
        items.push({
          id: tx.id,
          type: 'TRANSACTION',
          coin: tx.coin.symbol,
          amount: tx.amount,
          direction: tx.direction === TransactionDirection.IN ? 'RECEIVED' : 'SENT',
          from: tx.senderAddress,
          to: tx.receiverAddress,
          txHash: tx.txHash,
          status: tx.status,
          network: tx.network,
          timestamp: tx.createdAt,
        });
      }
    }

    if (type === ActivityTypeFilter.ALL || type === ActivityTypeFilter.SWAP) {
      const swaps = await this.swapRepository.find({
        where: { userId: user.id },
        relations: ['fromCoin', 'toCoin'],
        order: { createdAt: 'DESC' },
      });

      for (const swap of swaps) {
        items.push({
          id: swap.id,
          type: 'SWAP',
          amount: swap.fromAmount,
          direction: 'SWAP',
          txHash: null,
          status: swap.status,
          network: '—',
          timestamp: swap.createdAt,
          coinSent: swap.fromCoin.symbol,
          coinReceived: swap.toCoin.symbol,
        });
      }
    }

    items.sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime());

    const total = items.length;
    const skip = (page - 1) * limit;
    const paginatedItems = items.slice(skip, skip + limit);

    return {
      data: paginatedItems,
      pagination: {
        page,
        limit,
        totalRecords: total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getUserSwaps(userId: string, page: number = 1, limit: number = 10) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const skip = (page - 1) * limit;

    const [swaps, total] = await this.swapRepository.findAndCount({
      where: { userId: user.id },
      relations: ['fromCoin', 'toCoin'],
      order: { createdAt: 'DESC' },
      skip,
      take: limit,
    });

    return {
      data: swaps.map((swap) => ({
        coinSent: swap.fromCoin.symbol,
        coinReceived: swap.toCoin.symbol,
        amount: swap.fromAmount,
        timestamp: swap.createdAt,
      })),
      pagination: {
        page,
        limit,
        totalRecords: total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async blockUser(userId: string, adminId: string, dto: BlockUserDto) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (!user.isActive) {
      throw new BadRequestException('User is already blocked');
    }

    // Get old status
    const oldStatus = user.isActive ? UserStatus.ACTIVE : UserStatus.BLOCKED;

    // Block user
    user.isActive = false;
    await this.userRepository.save(user);

    // Create status history
    await this.userStatusHistoryRepository.save({
      userId: user.id,
      oldStatus,
      newStatus: UserStatus.BLOCKED,
      reason: dto.reason,
      changedByAdminId: adminId,
    });

    // Send email to user if email exists
    if (user.email) {
      await this.mailService.sendUserBlockNotification(
        user.email,
        dto.reason,
        getSupportEmail(),
      );
    }

    const suspiciousKeywords = ['suspicious', 'fraud', 'scam', 'violation', 'abuse'];
    const isSuspiciousActivity = suspiciousKeywords.some((keyword) =>
      dto.reason.toLowerCase().includes(keyword),
    );

    if (isSuspiciousActivity) {
      await this.mailService.sendInternalBlockNotification(
        getSupportEmail(),
        user.email || user.fullMobileNumber,
        dto.reason,
        adminId,
      );
    }

    // Notify all admins about user being blocked
    try {
      await this.adminNotificationsService.notifyAllAdmins(
        AdminNotificationType.SECURITY,
        'User Blocked',
        `A user has been blocked by an administrator. User: ${user.fullMobileNumber || user.email || userId}. Reason: ${dto.reason}`,
      );
    } catch (error) {
      this.logger.warn(
        `Failed to notify admins about user block: ${error instanceof Error ? error.message : 'Unknown error'}`,
      );
    }

    return {
      message: 'User blocked successfully',
      userId: user.id,
      status: 'Blocked',
    };
  }

  async unblockUser(userId: string, adminId: string) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.isActive) {
      throw new BadRequestException('User is already active');
    }

    // Get old status
    const oldStatus = user.isActive ? UserStatus.ACTIVE : UserStatus.BLOCKED;

    // Unblock user
    user.isActive = true;
    await this.userRepository.save(user);

    // Create status history
    await this.userStatusHistoryRepository.save({
      userId: user.id,
      oldStatus,
      newStatus: UserStatus.ACTIVE,
      reason: 'Account unblocked by admin',
      changedByAdminId: adminId,
    });

    // Notify all admins about user being unblocked
    try {
      await this.adminNotificationsService.notifyAllAdmins(
        AdminNotificationType.SECURITY,
        'User Unblocked',
        `A user has been unblocked by an administrator. User: ${user.fullMobileNumber || user.email || userId}`,
      );
    } catch (error) {
      this.logger.warn(
        `Failed to notify admins about user unblock: ${error instanceof Error ? error.message : 'Unknown error'}`,
      );
    }

    return {
      message: 'User unblocked successfully',
      userId: user.id,
      status: 'Active',
    };
  }
}
