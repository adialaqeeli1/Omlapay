import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity } from '@common/database/model';
import { WalletEntity } from '@common/database/model';
import { TransactionEntity } from '@common/database/model';
import { NotificationEntity } from '@common/database/model';

@Injectable()
export class HomeService {
  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(WalletEntity)
    private walletRepository: Repository<WalletEntity>,
    @InjectRepository(TransactionEntity)
    private transactionRepository: Repository<TransactionEntity>,
    @InjectRepository(NotificationEntity)
    private notificationRepository: Repository<NotificationEntity>,
  ) {}

  async getHomeData(userId: string) {
    // Get user profile
    const user = await this.userRepository.findOne({ where: { id: userId } });

    if (!user) {
      return {
        status: 'error',
        message: 'User not found',
      };
    }

    // Calculate total balance from all wallets
    const wallets = await this.walletRepository.find({
      where: { userId },
      relations: ['coin'],
    });

    const totalBalance = wallets.reduce((sum, wallet) => {
      return sum + parseFloat(wallet.balance);
    }, 0);

    // Get recent transactions (last 10)
    const recentTransactions = await this.transactionRepository.find({
      where: { userId },
      relations: ['coin'],
      order: { createdAt: 'DESC' },
      take: 10,
    });

    // Format transactions
    const formattedTransactions = recentTransactions.map((tx) => ({
      id: tx.id,
      coin_symbol: tx.coin.symbol,
      coin_name: tx.coin.name,
      amount: tx.amount,
      direction: tx.direction,
      type: tx.txType,
      status: tx.status,
      created_at: tx.createdAt,
      tx_hash: tx.txHash,
    }));

    // Count unread notifications
    const unreadNotifications = await this.notificationRepository.count({
      where: { userId, isRead: false },
    });

    return {
      status: 'success',
      data: {
        profile_image: user.profileImageUrl || null,
        total_balance: totalBalance.toFixed(2),
        recent_transactions: formattedTransactions,
        unread_notifications: unreadNotifications,
      },
    };
  }
}

