import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import { TransactionEntity, TransactionDirection, TransactionStatus } from '@common/database/model';
import { UserEntity } from '@common/database/model';
import { UserKycEntity, KycStatus } from '@common/database/model';
import { DashboardStatsDto } from './dto/dashboard-stats.dto';

@Injectable()
export class AdminDashboardService {
  constructor(
    @InjectRepository(TransactionEntity)
    private transactionRepository: Repository<TransactionEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(UserKycEntity)
    private userKycRepository: Repository<UserKycEntity>,
  ) {}

  async getDashboardStats(dto: DashboardStatsDto) {
    // Validate date range
    if (dto.fromDate && dto.toDate) {
      const from = new Date(dto.fromDate);
      const to = new Date(dto.toDate);
      
      if (from > to) {
        throw new BadRequestException('From date cannot be later than To date');
      }
      
      const now = new Date();
      if (from > now || to > now) {
        throw new BadRequestException('Future dates are not allowed');
      }
    }

    // Build date filter
    let dateFilter: any = {};
    if (dto.fromDate && dto.toDate) {
      dateFilter = Between(new Date(dto.fromDate), new Date(dto.toDate));
    } else if (dto.fromDate) {
      dateFilter = MoreThanOrEqual(new Date(dto.fromDate));
    } else if (dto.toDate) {
      dateFilter = LessThanOrEqual(new Date(dto.toDate));
    }

    // Total Funds Received (IN direction, COMPLETED status, not reversed)
    const receivedTransactions = await this.transactionRepository.find({
      where: {
        direction: TransactionDirection.IN,
        status: TransactionStatus.COMPLETED,
        ...(Object.keys(dateFilter).length > 0 ? { createdAt: dateFilter } : {}),
      },
    });

    const totalFundsReceived = receivedTransactions.reduce((sum, tx) => {
      return sum + parseFloat(tx.amount);
    }, 0);

    // Total Funds Sent (OUT direction, COMPLETED status, not reversed)
    const sentTransactions = await this.transactionRepository.find({
      where: {
        direction: TransactionDirection.OUT,
        status: TransactionStatus.COMPLETED,
        ...(Object.keys(dateFilter).length > 0 ? { createdAt: dateFilter } : {}),
      },
    });

    const totalFundsSent = sentTransactions.reduce((sum, tx) => {
      return sum + parseFloat(tx.amount);
    }, 0);

    // Total Transactions (both IN and OUT, COMPLETED status)
    const totalTransactions = await this.transactionRepository.count({
      where: {
        status: TransactionStatus.COMPLETED,
        ...(Object.keys(dateFilter).length > 0 ? { createdAt: dateFilter } : {}),
      },
    });

    // Total Users (Active) - includes app downloads and phone number registrations
    // This represents all users who have downloaded the app or registered with phone number
    const totalUsers = await this.userRepository.count({
      ...(Object.keys(dateFilter).length > 0 ? {
        where: {
          createdAt: dateFilter,
        },
      } : {}),
    });

    // Total KYC-Completed Users
    const kycCompletedCount = await this.userKycRepository.count({
      where: {
        status: KycStatus.APPROVED,
        ...(Object.keys(dateFilter).length > 0 ? { verifiedAt: dateFilter } : {}),
      },
    });

    return {
      totalFundsReceived: totalFundsReceived.toFixed(2),
      totalFundsSent: totalFundsSent.toFixed(2),
      totalTransactions,
      totalUsers,
      totalKycCompletedUsers: kycCompletedCount,
    };
  }
}
