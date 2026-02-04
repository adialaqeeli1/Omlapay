import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { UserEntity } from '@common/database/model';
import { WalletEntity } from '@common/database/model';
import { TransactionEntity, TransactionDirection } from '@common/database/model';
import { SwapEntity } from '@common/database/model';
import { UserKycEntity } from '@common/database/model';
import { UserStatusHistoryEntity, UserStatus } from '@common/database/model';
import { UserListDto } from './dto/user-list.dto';
import { BlockUserDto } from './dto/block-user.dto';
import { MailService } from '@common/services/mail/mail.service';

@Injectable()
export class AdminUsersService {
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
  ) {}

  async getUserList(dto: UserListDto) {
    const { search, page = 1, limit = 10 } = dto;
    const skip = (page - 1) * limit;

    // Build query
    const queryBuilder = this.userRepository.createQueryBuilder('user');

    // Apply search filter
    if (search) {
      queryBuilder.where(
        '(user.fullMobileNumber ILIKE :search OR user.email ILIKE :search)',
        { search: `%${search}%` },
      );
    }

    // Get total count
    const total = await queryBuilder.getCount();

    // Apply pagination and ordering
    const users = await queryBuilder
      .orderBy('user.createdAt', 'DESC')
      .skip(skip)
      .take(limit)
      .getMany();

    // Calculate total balance for each user
    const usersWithBalance = await Promise.all(
      users.map(async (user) => {
        const wallets = await this.walletRepository.find({
          where: { userId: user.id },
        });

        const totalBalance = wallets.reduce((sum, wallet) => {
          return sum + parseFloat(wallet.balance || '0');
        }, 0);

        // Get KYC status
        const kyc = await this.userKycRepository.findOne({
          where: { userId: user.id },
        });

        return {
          id: user.id,
          phoneNumber: user.fullMobileNumber,
          email: user.email || '—',
          fullName: '—', // Will be fetched from 3rd party KYC if available
          dateRegistered: user.createdAt,
          totalBalance: totalBalance.toFixed(2),
          status: user.isActive ? 'Active' : 'Blocked',
        };
      }),
    );

    return {
      users: usersWithBalance,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
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

    // Get transactions
    const transactions = await this.transactionRepository.find({
      where: { userId: user.id },
      relations: ['coin'],
      order: { createdAt: 'DESC' },
      take: 50, // Limit to recent 50 transactions
    });

    // Get swaps
    const swaps = await this.swapRepository.find({
      where: { userId: user.id },
      relations: ['fromCoin', 'toCoin'],
      order: { createdAt: 'DESC' },
      take: 50, // Limit to recent 50 swaps
    });

    return {
      profile: {
        phoneNumber: user.fullMobileNumber,
        email: user.email || '—',
        fullName: '—', // Will be fetched from 3rd party KYC if available
        dateRegistered: user.createdAt,
        kycStatus: kyc?.status || 'Not Started',
        kycLevel: kyc?.level || null,
      },
      wallet: {
        totalBalance: totalBalance.toFixed(2),
        wallets: wallets.map((wallet) => ({
          coin: wallet.coin.symbol,
          coinName: wallet.coin.name,
          network: wallet.network,
          address: wallet.address,
          balance: wallet.balance,
          lockedBalance: wallet.lockedBalance,
        })),
      },
      transactions: transactions.map((tx) => ({
        id: tx.id,
        coin: tx.coin.symbol,
        coinName: tx.coin.name,
        amount: tx.amount,
        direction: tx.direction,
        fromAddress: tx.senderAddress,
        toAddress: tx.receiverAddress,
        status: tx.status,
        createdAt: tx.createdAt,
      })),
      swaps: swaps.map((swap) => ({
        id: swap.id,
        fromCoin: swap.fromCoin.symbol,
        fromCoinName: swap.fromCoin.name,
        toCoin: swap.toCoin.symbol,
        toCoinName: swap.toCoin.name,
        fromAmount: swap.fromAmount,
        toAmount: swap.toAmount,
        status: swap.status,
        createdAt: swap.createdAt,
      })),
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
        'support@gmail.com',
      );
    }

    // Send internal notification if reason indicates suspicious activity
    // Check if reason contains keywords that suggest suspicious activity
    const suspiciousKeywords = ['suspicious', 'fraud', 'scam', 'violation', 'abuse'];
    const isSuspiciousActivity = suspiciousKeywords.some((keyword) =>
      dto.reason.toLowerCase().includes(keyword),
    );

    if (isSuspiciousActivity) {
      await this.mailService.sendInternalBlockNotification(
        'support@gmail.com',
        user.email || user.fullMobileNumber,
        dto.reason,
        adminId,
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

    return {
      message: 'User unblocked successfully',
      userId: user.id,
      status: 'Active',
    };
  }
}
