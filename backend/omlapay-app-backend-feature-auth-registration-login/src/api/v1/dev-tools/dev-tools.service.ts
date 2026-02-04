import { Injectable, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { UserEntity } from '@common/database/model';
import { UserSecurityEntity } from '@common/database/model';
import { UserSettingsEntity, Theme, Language } from '@common/database/model';
import { CoinEntity } from '@common/database/model';
import { WalletEntity } from '@common/database/model';
import {
  TransactionEntity,
  TransactionDirection,
  TransactionType,
  TransactionStatus,
} from '@common/database/model';
import {
  NotificationEntity,
  NotificationType,
  NotificationReferenceType,
} from '@common/database/model';
import { SwapEntity, SwapStatus } from '@common/database/model';
import { UserKycEntity, KycStatus, KycLevel } from '@common/database/model';
import { AuthSessionEntity } from '@common/database/model';
import { OtpRequestEntity } from '@common/database/model';
import { AdminEntity } from '@common/database/model';
import { AdminSecurityEntity } from '@common/database/model';
import { successResponse, errorResponse } from '@common/utils';

@Injectable()
export class DevToolsService {
  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(UserSecurityEntity)
    private userSecurityRepository: Repository<UserSecurityEntity>,
    @InjectRepository(UserSettingsEntity)
    private userSettingsRepository: Repository<UserSettingsEntity>,
    @InjectRepository(CoinEntity)
    private coinRepository: Repository<CoinEntity>,
    @InjectRepository(WalletEntity)
    private walletRepository: Repository<WalletEntity>,
    @InjectRepository(TransactionEntity)
    private transactionRepository: Repository<TransactionEntity>,
    @InjectRepository(NotificationEntity)
    private notificationRepository: Repository<NotificationEntity>,
    @InjectRepository(SwapEntity)
    private swapRepository: Repository<SwapEntity>,
    @InjectRepository(UserKycEntity)
    private userKycRepository: Repository<UserKycEntity>,
    @InjectRepository(AuthSessionEntity)
    private authSessionRepository: Repository<AuthSessionEntity>,
    @InjectRepository(OtpRequestEntity)
    private otpRequestRepository: Repository<OtpRequestEntity>,
    @InjectRepository(AdminEntity)
    private adminRepository: Repository<AdminEntity>,
    @InjectRepository(AdminSecurityEntity)
    private adminSecurityRepository: Repository<AdminSecurityEntity>,
  ) {}

  async seedDatabase() {
    // Only allow in development or dev environment
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message: 'Seed endpoint is only available in development or dev environment.',
      });
    }

    try {
      // Clear existing data using TRUNCATE CASCADE to handle foreign keys
      const entityManager = this.userRepository.manager;
      
      await entityManager.query('TRUNCATE TABLE auth_sessions CASCADE');
      await entityManager.query('TRUNCATE TABLE notifications CASCADE');
      await entityManager.query('TRUNCATE TABLE binance_webhooks CASCADE');
      await entityManager.query('TRUNCATE TABLE transactions CASCADE');
      await entityManager.query('TRUNCATE TABLE swaps CASCADE');
      await entityManager.query('TRUNCATE TABLE user_kyc CASCADE');
      await entityManager.query('TRUNCATE TABLE user_status_history CASCADE');
      await entityManager.query('TRUNCATE TABLE wallets CASCADE');
      await entityManager.query('TRUNCATE TABLE otp_requests CASCADE');
      await entityManager.query('TRUNCATE TABLE user_settings CASCADE');
      await entityManager.query('TRUNCATE TABLE user_security CASCADE');
      await entityManager.query('TRUNCATE TABLE coins CASCADE');
      await entityManager.query('TRUNCATE TABLE users CASCADE');
      await entityManager.query('TRUNCATE TABLE admin_notifications CASCADE');
      await entityManager.query('TRUNCATE TABLE admin_audit_logs CASCADE');
      await entityManager.query('TRUNCATE TABLE admin_sessions CASCADE');
      await entityManager.query('TRUNCATE TABLE admin_otps CASCADE');
      await entityManager.query('TRUNCATE TABLE admin_security CASCADE');
      await entityManager.query('TRUNCATE TABLE admins CASCADE');

      // Create Coins
      const coins = await this.createCoins();

      // Create Users
      const users = await this.createUsers();

      // Create Wallets
      await this.createWallets(users, coins);

      // Create Transactions
      const transactions = await this.createTransactions(users, coins);

      // Create Notifications
      await this.createNotifications(users, transactions);

      // Create Swaps
      await this.createSwaps(users, coins);

      // Create KYC records
      await this.createKycRecords(users);

      return successResponse(
        {
          users_created: users.length,
          coins_created: coins.length,
          transactions_created: transactions.length,
        },
        'Database seeded successfully',
      );
    } catch (error) {
      return errorResponse('Failed to seed database', error.message);
    }
  }

  private async createCoins(): Promise<CoinEntity[]> {
    const coinsData = [
      { symbol: 'BTC', name: 'Bitcoin', decimals: 8 },
      { symbol: 'ETH', name: 'Ethereum', decimals: 18 },
      { symbol: 'USDT', name: 'Tether', decimals: 6 },
      { symbol: 'USDC', name: 'USD Coin', decimals: 6 },
      { symbol: 'BNB', name: 'Binance Coin', decimals: 18 },
      { symbol: 'XRP', name: 'Ripple', decimals: 6 },
      { symbol: 'SOL', name: 'Solana', decimals: 9 },
    ];

    const coins: CoinEntity[] = [];
    for (const coinData of coinsData) {
      const coin = this.coinRepository.create(coinData);
      coins.push(await this.coinRepository.save(coin));
    }

    return coins;
  }

  private async createUsers(): Promise<UserEntity[]> {
    const passcodeHash = await bcrypt.hash('123456', 10);

    const usersData = [
      {
        countryCode: '+966',
        mobileNumber: '501234567',
        fullMobileNumber: '+966501234567',
        email: 'ahmed@omlapay.com',
        isMobileVerified: true,
        isEmailVerified: true,
        profileImageUrl: 'https://cdn.omlapay.com/profiles/user1.png',
      },
      {
        countryCode: '+966',
        mobileNumber: '509876543',
        fullMobileNumber: '+966509876543',
        email: 'fatima@omlapay.com',
        isMobileVerified: true,
        isEmailVerified: true,
        profileImageUrl: 'https://cdn.omlapay.com/profiles/user2.png',
      },
      {
        countryCode: '+966',
        mobileNumber: '505551234',
        fullMobileNumber: '+966505551234',
        email: 'mohammed@omlapay.com',
        isMobileVerified: true,
        isEmailVerified: false,
        profileImageUrl: null,
      },
    ];

    const users: UserEntity[] = [];
    for (const userData of usersData) {
      const user = this.userRepository.create(userData);
      const savedUser = await this.userRepository.save(user);
      users.push(savedUser);

      // Create user security
      const userSecurity = this.userSecurityRepository.create({
        userId: savedUser.id,
        passcodeHash,
        failedAttempts: 0,
        lastPasscodeChangedAt: new Date(),
      });
      await this.userSecurityRepository.save(userSecurity);

      // Create user settings
      const userSettings = this.userSettingsRepository.create({
        userId: savedUser.id,
        theme: [Theme.LIGHT, Theme.DARK, Theme.SYSTEM][Math.floor(Math.random() * 3)],
        language: Math.random() > 0.5 ? Language.EN : Language.AR,
        notificationsEnabled: true,
        twoFactorEnabled: Math.random() > 0.5,
      });
      await this.userSettingsRepository.save(userSettings);
    }

    return users;
  }

  private async createWallets(users: UserEntity[], coins: CoinEntity[]): Promise<void> {
    const networks = ['mainnet', 'testnet', 'polygon', 'bsc'];

    for (const user of users) {
      for (const coin of coins) {
        const wallet = this.walletRepository.create({
          userId: user.id,
          coinId: coin.id,
          network: networks[Math.floor(Math.random() * networks.length)],
          address: this.generateRandomAddress(),
          balance: (Math.random() * 10000).toFixed(coin.decimals),
          lockedBalance: (Math.random() * 100).toFixed(coin.decimals),
        });
        await this.walletRepository.save(wallet);
      }
    }
  }

  private async createTransactions(
    users: UserEntity[],
    coins: CoinEntity[],
  ): Promise<TransactionEntity[]> {
    const transactions: TransactionEntity[] = [];
    const transactionCount = 80; // Create 80 transactions

    const wallets = await this.walletRepository.find();

    for (let i = 0; i < transactionCount; i++) {
      const wallet = wallets[Math.floor(Math.random() * wallets.length)];
      const coin = coins.find((c) => c.id === wallet.coinId);

      if (!coin) continue;

      const direction =
        Math.random() > 0.5 ? TransactionDirection.IN : TransactionDirection.OUT;
      const txType =
        direction === TransactionDirection.IN
          ? TransactionType.RECEIVED
          : TransactionType.SENT;

      const statuses = [
        TransactionStatus.COMPLETED,
        TransactionStatus.COMPLETED,
        TransactionStatus.COMPLETED,
        TransactionStatus.PENDING,
        TransactionStatus.FAILED,
      ];

      const transaction = this.transactionRepository.create({
        userId: wallet.userId,
        coinId: coin.id,
        walletId: wallet.id,
        direction,
        txType,
        amount: (Math.random() * 1000).toFixed(coin.decimals),
        fee: (Math.random() * 10).toFixed(coin.decimals),
        status: statuses[Math.floor(Math.random() * statuses.length)],
        network: wallet.network,
        txHash: Math.random() > 0.2 ? this.generateTxHash() : null,
        confirmations: Math.floor(Math.random() * 20),
        senderAddress: this.generateRandomAddress(),
        receiverAddress: this.generateRandomAddress(),
        counterpartyPhone:
          Math.random() > 0.5 ? `+966${Math.floor(Math.random() * 1000000000)}` : null,
        idempotencyKey: this.generateIdempotencyKey(),
        createdAt: this.randomDate(this.getStartDate(), new Date()),
      });

      transactions.push(await this.transactionRepository.save(transaction));
    }

    return transactions;
  }

  private async createNotifications(
    users: UserEntity[],
    transactions: TransactionEntity[],
  ): Promise<void> {
    const notificationCount = 100; // Create 100 notifications

    const notificationTemplates = [
      {
        type: NotificationType.TX,
        title: 'Transaction Completed',
        message: 'Your transaction has been completed successfully',
      },
      {
        type: NotificationType.TX,
        title: 'Transaction Pending',
        message: 'Your transaction is being processed',
      },
      {
        type: NotificationType.TX,
        title: 'Transaction Failed',
        message: 'Your transaction has failed. Please try again',
      },
      {
        type: NotificationType.SECURITY,
        title: 'Login Alert',
        message: 'New login detected from a new device',
      },
      {
        type: NotificationType.SECURITY,
        title: 'Password Changed',
        message: 'Your password has been changed successfully',
      },
      {
        type: NotificationType.SYSTEM,
        title: 'Welcome to OmlaPay',
        message: 'Thank you for joining OmlaPay',
      },
      {
        type: NotificationType.SYSTEM,
        title: 'System Maintenance',
        message: 'Scheduled maintenance on Sunday 2AM-4AM',
      },
      {
        type: NotificationType.PROMO,
        title: 'Special Offer',
        message: 'Get 10% cashback on your next transaction',
      },
      {
        type: NotificationType.PROMO,
        title: 'New Feature',
        message: 'Check out our new swap feature',
      },
    ];

    for (let i = 0; i < notificationCount; i++) {
      const user = users[Math.floor(Math.random() * users.length)];
      const template =
        notificationTemplates[Math.floor(Math.random() * notificationTemplates.length)];

      const notification = this.notificationRepository.create({
        userId: user.id,
        type: template.type,
        title: template.title,
        message: template.message,
        referenceId:
          template.type === NotificationType.TX && transactions.length > 0 && Math.random() > 0.3
            ? transactions[Math.floor(Math.random() * transactions.length)].id
            : null,
        referenceType:
          template.type === NotificationType.TX && transactions.length > 0 && Math.random() > 0.3
            ? NotificationReferenceType.TRANSACTION
            : null,
        isRead: Math.random() > 0.4,
        createdAt: this.randomDate(this.getStartDate(), new Date()),
      });

      await this.notificationRepository.save(notification);
    }
  }

  private async createSwaps(users: UserEntity[], coins: CoinEntity[]): Promise<void> {
    const swapCount = 30; // Create 30 swaps

    for (let i = 0; i < swapCount; i++) {
      const user = users[Math.floor(Math.random() * users.length)];
      const fromCoin = coins[Math.floor(Math.random() * coins.length)];
      let toCoin = coins[Math.floor(Math.random() * coins.length)];

      // Ensure from and to coins are different
      while (toCoin.id === fromCoin.id) {
        toCoin = coins[Math.floor(Math.random() * coins.length)];
      }

      const fromAmount = Math.random() * 1000;
      const exchangeRate = Math.random() * 5;
      const toAmount = fromAmount * exchangeRate;

      const statuses = [
        SwapStatus.COMPLETED,
        SwapStatus.COMPLETED,
        SwapStatus.COMPLETED,
        SwapStatus.PENDING,
        SwapStatus.FAILED,
      ];

      const swap = this.swapRepository.create({
        userId: user.id,
        fromCoinId: fromCoin.id,
        toCoinId: toCoin.id,
        fromAmount: fromAmount.toFixed(fromCoin.decimals),
        toAmount: toAmount.toFixed(toCoin.decimals),
        exchangeRate: exchangeRate.toFixed(8),
        fee: (fromAmount * 0.001).toFixed(fromCoin.decimals),
        status: statuses[Math.floor(Math.random() * statuses.length)],
        idempotencyKey: this.generateIdempotencyKey(),
        createdAt: this.randomDate(this.getStartDate(), new Date()),
      });

      await this.swapRepository.save(swap);
    }
  }

  private async createKycRecords(users: UserEntity[]): Promise<void> {
    const providers = ['Sumsub', 'Onfido', 'Jumio'];

    for (const user of users) {
      const kyc = this.userKycRepository.create({
        userId: user.id,
        status: [KycStatus.APPROVED, KycStatus.PENDING, KycStatus.REJECTED][
          Math.floor(Math.random() * 3)
        ],
        level: [KycLevel.BASIC, KycLevel.INTERMEDIATE, KycLevel.ADVANCED][
          Math.floor(Math.random() * 3)
        ],
        provider: providers[Math.floor(Math.random() * providers.length)],
        referenceId: `REF-${Math.random().toString(36).substring(2, 11).toUpperCase()}`,
        rejectionReason: Math.random() > 0.8 ? 'Document quality is poor' : null,
        verifiedAt: Math.random() > 0.5 ? new Date() : null,
      });

      await this.userKycRepository.save(kyc);
    }
  }

  private generateRandomAddress(): string {
    return '0x' + Array.from({ length: 40 }, () =>
      Math.floor(Math.random() * 16).toString(16),
    ).join('');
  }

  private generateTxHash(): string {
    return '0x' + Array.from({ length: 64 }, () =>
      Math.floor(Math.random() * 16).toString(16),
    ).join('');
  }

  private generateIdempotencyKey(): string {
    return `${Date.now()}-${Math.random().toString(36).substring(2, 11)}`;
  }

  private randomDate(start: Date, end: Date): Date {
    return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  }

  private getStartDate(): Date {
    const now = new Date();
    const start = new Date(now);
    start.setMonth(now.getMonth() - 3); // 3 months ago
    return start;
  }

  async seedAdmin() {
    // Only allow in development or dev environment
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message: 'Seed endpoint is only available in development or dev environment.',
      });
    }

    try {
      // Check if admin already exists
      const existingAdmin = await this.adminRepository.findOne({
        where: { email: 'admin@omlapay.com' },
      });

      if (existingAdmin) {
        return successResponse(
          {
            email: 'admin@omlapay.com',
            message: 'Admin already exists',
          },
          'Admin account already seeded',
        );
      }

      // Create admin with password: Admin@123
      const passwordHash = await bcrypt.hash('Admin@123', 10);

      const admin = this.adminRepository.create({
        email: 'admin@omlapay.com',
        phoneNumber: '+966500000000',
        passwordHash,
        isActive: true,
      });

      const savedAdmin = await this.adminRepository.save(admin);

      // Create admin security record
      const adminSecurity = this.adminSecurityRepository.create({
        adminId: savedAdmin.adminId,
        failedLoginAttempts: 0,
        passwordUpdatedAt: new Date(),
      });

      await this.adminSecurityRepository.save(adminSecurity);

      return successResponse(
        {
          email: 'admin@omlapay.com',
          phone: '+966500000000',
          password: 'Admin@123',
        },
        'Admin account seeded successfully',
      );
    } catch (error) {
      return errorResponse('Failed to seed admin', error.message);
    }
  }
}

