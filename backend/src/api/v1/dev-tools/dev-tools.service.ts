import { Injectable, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import { createSign, createPrivateKey, sign } from 'crypto';
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
import {
  UserKycEntity,
  KycStatus,
  KycLevel,
  KycProvider,
} from '@common/database/model';
import { AuthSessionEntity } from '@common/database/model';
import { OtpRequestEntity } from '@common/database/model';
import { AdminEntity, AdminRole } from '@common/database/model';
import { AdminSecurityEntity } from '@common/database/model';
import { FaqEntity } from '@common/database/model';
import { LegalContentEntity, LegalContentType } from '@common/database/model';
import { AboutEntity } from '@common/database/model';
import {
  SupportRequestEntity,
  SupportRequestStatus,
} from '@common/database/model';
import { TicketResponseEntity } from '@common/database/model';
import {
  SendPendingRequestEntity,
  RecipientType,
} from '@common/database/model';
import { SystemSettingsEntity } from '@common/database/model';
import { OtpPurpose } from '@common/database/model';
import { successResponse, errorResponse } from '@common/utils';
import { SumsubService } from '@common/services/sumsub/sumsub.service';
import { BinanceService } from '@common/services/binance/binance.service';
import {
  AdminNotificationsService,
} from '../admin-notifications/admin-notifications.service';
import {
  AdminNotificationType,
  UserStatusHistoryEntity,
  UserStatus,
} from '@common/database/model';
import * as QRCode from 'qrcode';
import { Response } from 'express';
import { CreateBinanceSubaccountDto } from './dto/create-binance-subaccount.dto';
import { BlockSubaccountDto } from './dto/block-subaccount.dto';
import { UnblockSubaccountDto } from './dto/unblock-subaccount.dto';

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
    @InjectRepository(FaqEntity)
    private faqRepository: Repository<FaqEntity>,
    @InjectRepository(LegalContentEntity)
    private legalContentRepository: Repository<LegalContentEntity>,
    @InjectRepository(AboutEntity)
    private aboutRepository: Repository<AboutEntity>,
    @InjectRepository(UserStatusHistoryEntity)
    private userStatusHistoryRepository: Repository<UserStatusHistoryEntity>,
    @InjectRepository(SupportRequestEntity)
    private supportRequestRepository: Repository<SupportRequestEntity>,
    @InjectRepository(TicketResponseEntity)
    private ticketResponseRepository: Repository<TicketResponseEntity>,
    @InjectRepository(SendPendingRequestEntity)
    private sendPendingRequestRepository: Repository<SendPendingRequestEntity>,
    @InjectRepository(SystemSettingsEntity)
    private systemSettingsRepository: Repository<SystemSettingsEntity>,
    private readonly sumsubService: SumsubService,
    private readonly adminNotificationsService: AdminNotificationsService,
    private readonly binanceService: BinanceService,
    private readonly configService: ConfigService,
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
      
      await entityManager.query('TRUNCATE TABLE ticket_responses CASCADE');
      await entityManager.query('TRUNCATE TABLE support_requests CASCADE');
      await entityManager.query('TRUNCATE TABLE send_pending_requests CASCADE');
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
      await entityManager.query('TRUNCATE TABLE faqs CASCADE');
      await entityManager.query('TRUNCATE TABLE legal_content CASCADE');
      await entityManager.query('TRUNCATE TABLE about CASCADE');
      await entityManager.query('TRUNCATE TABLE system_settings CASCADE');

      // Create Coins
      const coins = await this.createCoins();

      // Create Users
      const users = await this.createUsers();

      // Create seed admins (before tickets, user_status_history, send_pending)
      await this.createSeedAdmins();
      const admins = await this.adminRepository.find();

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

      // Create Support tickets and responses
      const supportRequests = await this.createSupportRequests(users);
      await this.createTicketResponses(supportRequests, admins);

      // Create User status history (admin actions)
      await this.createUserStatusHistory(users, admins);

      // Create Auth sessions and OTP requests for testing
      await this.createAuthSessions(users);
      const otpRequests = await this.createOtpRequests(users);

      // Create System settings
      await this.createSystemSettings();

      // Create Send pending requests (requires otp_requests)
      const wallets = await this.walletRepository.find();
      await this.createSendPendingRequests(users, coins, wallets, otpRequests);

      // Create FAQs, Legal Content, and About content
      await this.createFaqs();
      await this.createLegalContent();
      await this.createAboutContent();

      // Create sample admin notifications (inbox data for UI)
      await this.createSampleAdminNotifications();

      return successResponse(
        {
          users_created: users.length,
          coins_created: coins.length,
          transactions_created: transactions.length,
          support_requests_created: supportRequests.length,
          admins_created: admins.length,
        },
        'Database seeded successfully',
      );
    } catch (error) {
      return errorResponse('Failed to seed database', error.message);
    }
  }

  async createBinanceTestnetOrder(
    overrides: {
      symbol: string;
      side?: 'BUY' | 'SELL';
      type?: 'LIMIT' | 'MARKET';
      timeInForce?: string;
      quantity?: string;
      price?: string;
    },
  ) {
    // Only allow in development or dev environment
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    if (!overrides?.symbol) {
      return errorResponse('symbol is required');
    }

    const apiKey = process.env.BINANCE_TESTNET_API_KEY;
    const privateKeyPem = process.env.BINANCE_TESTNET_PRIVATE_KEY_PEM;
    if (!apiKey || !privateKeyPem) {
      return errorResponse(
        'Missing BINANCE_TESTNET_API_KEY or BINANCE_TESTNET_PRIVATE_KEY_PEM env vars',
      );
    }

    const symbol = overrides.symbol;
    const orderType = overrides?.type ?? 'LIMIT';
    let price = overrides?.price;

    // For LIMIT orders, fetch current price if not provided
    if (orderType === 'LIMIT' && !price) {
      try {
        const tickerRes = await fetch(
          `https://testnet.binance.vision/api/v3/ticker/price?symbol=${symbol}`,
        );
        const ticker = await tickerRes.json();
        if (ticker.price) {
          // Use current price (or slightly offset for SELL orders to ensure it executes)
          const currentPrice = parseFloat(ticker.price);
          price = String(currentPrice);
        }
      } catch (error) {
        return errorResponse(
          'Failed to fetch current price from Binance. Please provide a price parameter.',
        );
      }
    }

    const params: Record<string, string> = {
      symbol,
      side: overrides?.side ?? 'SELL',
      type: orderType,
      timeInForce: overrides?.timeInForce ?? 'GTC',
      quantity: overrides?.quantity ?? '1.0000000',
      timestamp: String(Date.now()),
    };

    // Only include price for LIMIT orders
    if (orderType === 'LIMIT' && price) {
      params.price = price;
    }

    // Binance expects the signature over the querystring payload.
    const payload = new URLSearchParams(params).toString();

    // RSA signature, base64 encoded (matches the Python example)
    const signer = createSign('RSA-SHA256');
    signer.update(payload, 'utf8');
    signer.end();
    const signature = signer.sign(privateKeyPem, 'base64');

    const body = new URLSearchParams({ ...params, signature });

    const res = await fetch('https://testnet.binance.vision/api/v3/order', {
      method: 'POST',
      headers: {
        'X-MBX-APIKEY': apiKey,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body,
    });

    // Return Binance JSON exactly (no wrapping), per request
    const json = await res.json().catch(() => null);
    return json ?? { status: res.status, statusText: res.statusText };
  }

  private async signAndFetchBinanceGet(
    endpoint: string,
    params: Record<string, string>,
  ) {
    const apiKey = process.env.BINANCE_TESTNET_API_KEY;
    const privateKeyPem = process.env.BINANCE_TESTNET_PRIVATE_KEY_PEM;
    if (!apiKey || !privateKeyPem) {
      return errorResponse(
        'Missing BINANCE_TESTNET_API_KEY or BINANCE_TESTNET_PRIVATE_KEY_PEM env vars',
      );
    }

    // Add timestamp
    params.timestamp = String(Date.now());

    // Sign the query string
    const payload = new URLSearchParams(params).toString();
    const signer = createSign('RSA-SHA256');
    signer.update(payload, 'utf8');
    signer.end();
    const signature = signer.sign(privateKeyPem, 'base64');

    // Add signature to params
    const signedParams = new URLSearchParams({
      ...params,
      signature,
    }).toString();

    const res = await fetch(
      `https://testnet.binance.vision${endpoint}?${signedParams}`,
      {
        method: 'GET',
        headers: {
          'X-MBX-APIKEY': apiKey,
        },
      },
    );

    const json = await res.json().catch(() => null);
    return json ?? { status: res.status, statusText: res.statusText };
  }

  private async signAndFetchBinancePost(
    endpoint: string,
    params: Record<string, string>,
  ) {
    const apiKey = process.env.BINANCE_TESTNET_API_KEY;
    const privateKeyPem = process.env.BINANCE_TESTNET_PRIVATE_KEY_PEM;
    if (!apiKey || !privateKeyPem) {
      return errorResponse(
        'Missing BINANCE_TESTNET_API_KEY or BINANCE_TESTNET_PRIVATE_KEY_PEM env vars',
      );
    }

    // Add timestamp
    params.timestamp = String(Date.now());

    // Sign the payload
    const payload = new URLSearchParams(params).toString();
    const signer = createSign('RSA-SHA256');
    signer.update(payload, 'utf8');
    signer.end();
    const signature = signer.sign(privateKeyPem, 'base64');

    const body = new URLSearchParams({ ...params, signature });

    const res = await fetch(`https://testnet.binance.vision${endpoint}`, {
      method: 'POST',
      headers: {
        'X-MBX-APIKEY': apiKey,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body,
    });

    const json = await res.json().catch(() => null);
    return json ?? { status: res.status, statusText: res.statusText };
  }

  async getBinanceTestnetOrder(params: {
    symbol: string;
    orderId?: string;
    origClientOrderId?: string;
  }) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    const queryParams: Record<string, string> = {
      symbol: params.symbol,
    };

    if (params.orderId) {
      queryParams.orderId = params.orderId;
    }
    if (params.origClientOrderId) {
      queryParams.origClientOrderId = params.origClientOrderId;
    }

    return this.signAndFetchBinanceGet('/api/v3/order', queryParams);
  }

  async getBinanceTestnetOpenOrders(symbol?: string) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    const queryParams: Record<string, string> = {};
    if (symbol) {
      queryParams.symbol = symbol;
    }

    return this.signAndFetchBinanceGet('/api/v3/openOrders', queryParams);
  }

  async getBinanceTestnetAllOrders(params: {
    symbol: string;
    orderId?: string;
    startTime?: string;
    endTime?: string;
    limit?: string;
  }) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    const queryParams: Record<string, string> = {
      symbol: params.symbol,
    };

    if (params.orderId) {
      queryParams.orderId = params.orderId;
    }
    if (params.startTime) {
      queryParams.startTime = params.startTime;
    }
    if (params.endTime) {
      queryParams.endTime = params.endTime;
    }
    if (params.limit) {
      queryParams.limit = params.limit;
    }

    return this.signAndFetchBinanceGet('/api/v3/allOrders', queryParams);
  }

  async getBinanceTestnetMyTrades(params: {
    symbol: string;
    orderId?: string;
    startTime?: string;
    endTime?: string;
    fromId?: string;
    limit?: string;
  }) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    const queryParams: Record<string, string> = {
      symbol: params.symbol,
    };

    if (params.orderId) {
      queryParams.orderId = params.orderId;
    }
    if (params.startTime) {
      queryParams.startTime = params.startTime;
    }
    if (params.endTime) {
      queryParams.endTime = params.endTime;
    }
    if (params.fromId) {
      queryParams.fromId = params.fromId;
    }
    if (params.limit) {
      queryParams.limit = params.limit;
    }

    return this.signAndFetchBinanceGet('/api/v3/myTrades', queryParams);
  }

  async getBinanceTestnetAccount() {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    return this.signAndFetchBinanceGet('/api/v3/account', {});
  }

  // Swap Testing Flow - Step by Step
  async step1GetAccount() {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    return this.signAndFetchBinanceGet('/api/v3/account', {});
  }

  async step2PlaceSwapOrder(overrides: {
    symbol: string;
    side?: 'BUY' | 'SELL';
    type?: 'LIMIT' | 'MARKET';
    timeInForce?: string;
    quantity?: string;
    price?: string;
  }) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    if (!overrides?.symbol) {
      return errorResponse('symbol is required');
    }

    const apiKey = process.env.BINANCE_TESTNET_API_KEY;
    const privateKeyPem = process.env.BINANCE_TESTNET_PRIVATE_KEY_PEM;
    if (!apiKey || !privateKeyPem) {
      return errorResponse(
        'Missing BINANCE_TESTNET_API_KEY or BINANCE_TESTNET_PRIVATE_KEY_PEM env vars',
      );
    }

    const symbol = overrides.symbol;
    const orderType = overrides?.type ?? 'MARKET';
    const side = overrides?.side ?? 'SELL';

    const params: Record<string, string> = {
      symbol,
      side,
      type: orderType,
      quantity: overrides?.quantity ?? '0.001',
      timestamp: String(Date.now()),
    };

    // Only include price and timeInForce for LIMIT orders
    if (orderType === 'LIMIT') {
      if (overrides?.price) {
        params.price = overrides.price;
      }
      params.timeInForce = overrides?.timeInForce ?? 'GTC';
    }

    // Binance expects the signature over the querystring payload.
    const payload = new URLSearchParams(params).toString();

    // RSA signature, base64 encoded
    const signer = createSign('RSA-SHA256');
    signer.update(payload, 'utf8');
    signer.end();
    const signature = signer.sign(privateKeyPem, 'base64');

    const body = new URLSearchParams({ ...params, signature });

    const res = await fetch('https://testnet.binance.vision/api/v3/order', {
      method: 'POST',
      headers: {
        'X-MBX-APIKEY': apiKey,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body,
    });

    const json = await res.json().catch(() => null);
    return json ?? { status: res.status, statusText: res.statusText };
  }

  async step3GetOrderStatus(params: {
    symbol: string;
    orderId: string;
  }) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    if (!params.orderId) {
      return errorResponse('orderId is required');
    }

    const queryParams: Record<string, string> = {
      symbol: params.symbol,
      orderId: params.orderId,
    };

    return this.signAndFetchBinanceGet('/api/v3/order', queryParams);
  }

  async step4GetTradeFills(params: {
    symbol: string;
    orderId?: string;
    limit?: string;
  }) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    const queryParams: Record<string, string> = {
      symbol: params.symbol,
    };

    if (params.orderId) {
      queryParams.orderId = params.orderId;
    }
    if (params.limit) {
      queryParams.limit = params.limit;
    }

    return this.signAndFetchBinanceGet('/api/v3/myTrades', queryParams);
  }

  async step5VerifyBalances() {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    return this.signAndFetchBinanceGet('/api/v3/account', {});
  }

  // Receive Funds Flow - Step by Step
  async step1GetDepositAddress(params: {
    coin: string;
    network: string;
  }) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    if (!params.coin || !params.network) {
      return errorResponse('coin and network are required');
    }

    const queryParams: Record<string, string> = {
      coin: params.coin,
      network: params.network,
    };

    return this.signAndFetchBinanceGet('/sapi/v1/capital/deposit/address', queryParams);
  }

  async step2SimulateTransfer() {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    return {
      message: 'Step 2: Simulate External Transfer',
      description:
        'On testnet, you cannot use real wallets. External means Binance testnet faucet, another testnet account, or manual balance simulation.',
      instructions: [
        '1. Use Binance testnet faucet to get testnet tokens',
        '2. Send tokens from another testnet account to the deposit address from Step 1',
        '3. Or manually simulate balance changes in testnet environment',
      ],
      note: 'This is a testnet limitation, not a design flaw. In production, users send from real wallets.',
    };
  }

  async step3CheckDepositHistory(params: {
    coin?: string;
    limit?: string;
  }) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    const queryParams: Record<string, string> = {};

    if (params.coin) {
      queryParams.coin = params.coin;
    }
    if (params.limit) {
      queryParams.limit = params.limit;
    }

    return this.signAndFetchBinanceGet('/sapi/v1/capital/deposit/hisrec', queryParams);
  }

  async step4CreditUser() {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    return {
      message: 'Step 4: Credit User Internally (CRITICAL STEP)',
      description:
        'Once deposit appears with status=1 (success), you must credit the user in your internal ledger.',
      steps: [
        '1. Match deposit to user in your database',
        '2. Add balance to user wallet (update DB)',
        '3. Record transaction in your system',
        '4. Do NOT call Binance again - this is your internal logic',
      ],
      warning: 'Binance does NOT credit your users for you. You must handle this in your backend.',
      note: 'This is backend logic, not a Binance API call. Implement this in your application code.',
    };
  }

  async step5VerifyBalance() {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    return this.signAndFetchBinanceGet('/api/v3/account', {});
  }

  /** Sample addresses per network for QR testing (no real funds) */
  private static readonly SAMPLE_ADDRESSES: Record<string, string> = {
    TRX: 'TXJTGk4K6W6qkS5uJ6q1rP25U4v9e',
    BTC: '1HPn8Rx2y6nNSfagQBKy27GB99Vbzg89wv',
    ETH: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
    BNB: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
    SOL: 'DYw8jCTfwHNRJhhmFcbXvVDTqWMEVFBX6ZKUmG5CNSKK',
  };

  async testReceiveQr(
    params: {
      network: string;
      coin: string;
      format: string;
      address?: string;
    },
    res: Response,
  ) {
    const { network, coin, format, address } = params;
    const validNetworks = ['TRX', 'BTC', 'ETH', 'BNB', 'SOL'];
    const validCoins = ['USDT', 'USDC', 'BTC', 'ETH', 'BNB', 'SOL'];

    if (!network || !validNetworks.includes(network.toUpperCase())) {
      res.status(400).json(
        errorResponse('Invalid network', { validNetworks }),
      );
      return;
    }

    if (!coin || !validCoins.includes(coin.toUpperCase())) {
      res.status(400).json(
        errorResponse('Invalid coin', { validCoins }),
      );
      return;
    }

    const fmt = (format ?? 'png').toLowerCase() === 'svg' ? 'svg' : 'png';
    const addr =
      address ?? DevToolsService.SAMPLE_ADDRESSES[network.toUpperCase()];

    if (!addr) {
      res.status(400).json(
        errorResponse('No sample address for network. Provide address param.'),
      );
      return;
    }

    const qrContent = this.buildTestQrContent(
      addr,
      network.toUpperCase(),
      coin.toUpperCase(),
    );

    const options = {
      width: 400,
      margin: 2,
      errorCorrectionLevel: 'M' as const,
    };

    try {
      if (fmt === 'svg') {
        const svg = await QRCode.toString(qrContent, {
          ...options,
          type: 'svg',
        });
        res.setHeader('Content-Type', 'image/svg+xml');
        res.send(Buffer.from(svg, 'utf8'));
      } else {
        const buffer = await QRCode.toBuffer(qrContent, {
          ...options,
          type: 'png',
        });
        res.setHeader('Content-Type', 'image/png');
        res.send(buffer);
      }
    } catch (err) {
      res.status(500).json(
        errorResponse('QR generation failed', (err as Error).message),
      );
    }
  }

  private buildTestQrContent(
    address: string,
    network: string,
    coin: string,
  ): string {
    if (network === 'BTC' && coin === 'BTC') {
      return `bitcoin:${address}`;
    }
    if (
      (network === 'ETH' || network === 'BNB') &&
      (coin === 'ETH' || coin === 'BNB')
    ) {
      return `ethereum:${address}`;
    }
    return address;
  }

  // Send Funds Flow - Step by Step
  async step0CheckPreconditions() {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    return {
      message: 'Step 0: Preconditions Check',
      description: 'Before allowing withdrawal, these conditions must be true:',
      preconditions: [
        '1. User has completed Binance KYC',
        '2. User has sufficient internal balance',
        '3. Withdrawal permissions are enabled on the API key',
        '4. Network & address validation is done in your app',
      ],
      note: 'This is validation logic in your application, not a Binance API call.',
    };
  }

  async step1ValidateWithdrawalDetails(params: {
    coin: string;
    amount: string;
    address: string;
    network: string;
    addressTag?: string;
  }) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    if (!params.coin || !params.amount || !params.address || !params.network) {
      return errorResponse('coin, amount, address, and network are required');
    }

    // Basic validation
    const amountNum = parseFloat(params.amount);
    if (isNaN(amountNum) || amountNum <= 0) {
      return errorResponse('amount must be a positive number');
    }

    return {
      message: 'Step 1: Withdrawal Details Validated',
      description: 'User withdrawal details have been validated. Ready to proceed to next step.',
      validatedData: {
        coin: params.coin,
        amount: params.amount,
        address: params.address,
        network: params.network,
        addressTag: params.addressTag || null,
      },
      note: 'This is your application validation. No Binance API call yet.',
      nextStep: 'Proceed to Step 2 (check balance) or Step 3 (initiate withdrawal)',
    };
  }

  async step2CheckBalance() {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    return this.signAndFetchBinanceGet('/api/v3/account', {});
  }

  async step3InitiateWithdrawal(params: {
    coin: string;
    address: string;
    amount: string;
    network: string;
    addressTag?: string;
  }) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    if (!params.coin || !params.address || !params.amount || !params.network) {
      return errorResponse('coin, address, amount, and network are required');
    }

    const requestParams: Record<string, string> = {
      coin: params.coin,
      address: params.address,
      amount: params.amount,
      network: params.network,
    };

    if (params.addressTag) {
      requestParams.addressTag = params.addressTag;
    }

    return this.signAndFetchBinancePost('/sapi/v1/capital/withdraw/apply', requestParams);
  }

  async step4DeductBalance() {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    return {
      message: 'Step 4: Deduct User Balance Internally (Immediately)',
      description:
        'Once Binance accepts the withdrawal request (Step 3 returns withdrawal order ID), you must immediately:',
      steps: [
        '1. Deduct balance from user internal ledger (update DB)',
        '2. Mark transaction as "processing" in your system',
        '3. Record the withdrawal in your transaction history',
      ],
      warning:
        'Do NOT wait for blockchain confirmation to deduct balance. Deduct immediately after Binance accepts the request.',
      note: 'This is backend logic, not a Binance API call. Implement this in your application code.',
    };
  }

  async step5TrackWithdrawalStatus(params: {
    coin?: string;
    withdrawOrderId?: string;
    limit?: string;
  }) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance testnet dev-tools endpoint is only available in development or dev environment.',
      });
    }

    const queryParams: Record<string, string> = {};

    if (params.coin) {
      queryParams.coin = params.coin;
    }
    if (params.withdrawOrderId) {
      queryParams.withdrawOrderId = params.withdrawOrderId;
    }
    if (params.limit) {
      queryParams.limit = params.limit;
    }

    return this.signAndFetchBinanceGet('/sapi/v1/capital/withdraw/history', queryParams);
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

  /**
   * Creates seed users: 2 KYC (approved), 2 Non-KYC, 2 Blocked.
   * Order is used by createKycRecords to assign KYC status per filter.
   */
  private async createUsers(): Promise<UserEntity[]> {
    const passcodeHash = await bcrypt.hash('123456', 10);

    const usersData: Array<{
      countryCode: string;
      mobileNumber: string;
      fullMobileNumber: string;
      email: string;
      isMobileVerified: boolean;
      isEmailVerified: boolean;
      profileImageUrl: string | null;
      isActive?: boolean;
    }> = [
      // 2 users for KYC filter (will get approved KYC in createKycRecords)
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
      // 2 users for Non-KYC filter (will get non-approved KYC)
      {
        countryCode: '+966',
        mobileNumber: '505551234',
        fullMobileNumber: '+966505551234',
        email: 'mohammed@omlapay.com',
        isMobileVerified: true,
        isEmailVerified: false,
        profileImageUrl: null,
      },
      {
        countryCode: '+966',
        mobileNumber: '507778888',
        fullMobileNumber: '+966507778888',
        email: 'sara@omlapay.com',
        isMobileVerified: true,
        isEmailVerified: true,
        profileImageUrl: null,
      },
      // 2 users for Blocked filter (isActive = false)
      {
        countryCode: '+966',
        mobileNumber: '504441111',
        fullMobileNumber: '+966504441111',
        email: 'blocked1@omlapay.com',
        isMobileVerified: true,
        isEmailVerified: false,
        profileImageUrl: null,
        isActive: false,
      },
      {
        countryCode: '+966',
        mobileNumber: '503332222',
        fullMobileNumber: '+966503332222',
        email: 'blocked2@omlapay.com',
        isMobileVerified: true,
        isEmailVerified: false,
        profileImageUrl: null,
        isActive: false,
      },
    ];

    const users: UserEntity[] = [];
    for (const userData of usersData) {
      const user = this.userRepository.create({
        ...userData,
        isActive: userData.isActive ?? true,
      });
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

      const savedTx = await this.transactionRepository.save(transaction);
      transactions.push(savedTx);

      // Notify all admins when a transaction fails (spec: Failed transaction notification)
      if (savedTx.status === TransactionStatus.FAILED) {
        try {
          await this.adminNotificationsService.notifyTransactionFailed(
            savedTx.id,
            savedTx.userId,
            savedTx.amount,
            savedTx.errorMessage ?? undefined,
          );
        } catch {
          // Don't fail seed if notification fails (e.g. no admins yet)
        }
      }
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
        title: 'Welcome to Omlapay',
        message: 'Thank you for joining Omlapay',
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

  /**
   * Creates KYC records so admin list filters have data:
   * - Users 0,1: APPROVED KYC (SUMSUB) → show in "KYC Users" tab
   * - Users 2,3: PENDING KYC → show in "Non-KYC Users" tab
   * - Users 4,5: PENDING KYC (blocked users still get a record) → show in "Blocked Users" tab
   */
  private async createKycRecords(users: UserEntity[]): Promise<void> {
    for (let i = 0; i < users.length; i++) {
      const user = users[i];
      const isApproved = i < 2;
      const kyc = this.userKycRepository.create({
        userId: user.id,
        status: isApproved ? KycStatus.APPROVED : KycStatus.PENDING,
        level: i % 3 === 0 ? KycLevel.BASIC : KycLevel.INTERMEDIATE,
        provider: KycProvider.SUMSUB,
        referenceId: `REF-${user.id.slice(0, 8).toUpperCase()}`,
        rejectionReason: null,
        verifiedAt: isApproved ? new Date() : null,
        providerPayload: isApproved
          ? ({
              info: {
                firstName: user.email?.split('@')[0] || 'User',
                lastName: `Seed${i + 1}`,
              },
            } as any)
          : null,
      });

      await this.userKycRepository.save(kyc);
    }
  }

  /**
   * Creates support tickets (OPEN, SOLVED, REJECTED) for admin ticket list testing.
   */
  private async createSupportRequests(
    users: UserEntity[],
  ): Promise<SupportRequestEntity[]> {
    const tickets: SupportRequestEntity[] = [];
    const titles = [
      'Cannot withdraw funds',
      'KYC verification stuck',
      'Transaction failed',
      'Account locked',
      'Swap not completing',
      'Wrong amount received',
      'Need to update phone number',
      'Two-factor not working',
    ];
    const descriptions = [
      'I have been trying to withdraw but it keeps failing.',
      'My KYC has been pending for 3 days.',
      'Transaction ID abc123 failed with no error message.',
      'My account was locked after password reset.',
      'Swap from USDT to BTC is stuck in pending.',
      'I sent 100 USDT but received only 95.',
      'I changed my phone and need to update it.',
      '2FA codes are not being accepted.',
    ];
    const statuses = [
      SupportRequestStatus.OPEN,
      SupportRequestStatus.OPEN,
      SupportRequestStatus.SOLVED,
      SupportRequestStatus.SOLVED,
      SupportRequestStatus.REJECTED,
    ];

    for (let i = 0; i < 25; i++) {
      const user = users[Math.floor(Math.random() * users.length)];
      const idx = i % titles.length;
      const ticket = this.supportRequestRepository.create({
        userId: user.id,
        title: titles[idx],
        description: descriptions[idx],
        attachmentUrl: Math.random() > 0.8 ? 'https://cdn.omlapay.com/attachments/sample.png' : null,
        status: statuses[Math.floor(Math.random() * statuses.length)],
      });
      const saved = await this.supportRequestRepository.save(ticket);
      tickets.push(saved);
    }

    return tickets;
  }

  /**
   * Creates ticket responses (admin replies) for support tickets.
   */
  private async createTicketResponses(
    supportRequests: SupportRequestEntity[],
    admins: AdminEntity[],
  ): Promise<void> {
    const messages = [
      'Thank you for contacting support. We are looking into this.',
      'Your request has been escalated to our technical team.',
      'Please try again after 24 hours. The issue should be resolved.',
      'We have verified your account. You can proceed now.',
      'This was caused by a temporary outage. Apologies for the inconvenience.',
      'Your KYC has been approved. Please refresh the app.',
    ];

    for (const ticket of supportRequests) {
      const numResponses = Math.floor(Math.random() * 3) + 1;
      for (let r = 0; r < numResponses; r++) {
        const admin = admins[Math.floor(Math.random() * admins.length)];
        const response = this.ticketResponseRepository.create({
          ticketId: ticket.id,
          adminId: admin.adminId,
          message: messages[Math.floor(Math.random() * messages.length)],
        });
        await this.ticketResponseRepository.save(response);
      }
    }
  }

  /**
   * Creates user status history (block/unblock actions by admins).
   */
  private async createUserStatusHistory(
    users: UserEntity[],
    admins: AdminEntity[],
  ): Promise<void> {
    const reasons = [
      'Terms of service violation',
      'Suspicious activity detected',
      'User request',
      'Duplicate account',
      'Fraudulent activity',
    ];

    for (let i = 0; i < 15; i++) {
      const user = users[Math.floor(Math.random() * users.length)];
      const admin = admins[Math.floor(Math.random() * admins.length)];
      const isBlock = Math.random() > 0.5;
      const history = this.userStatusHistoryRepository.create({
        userId: user.id,
        oldStatus: isBlock ? UserStatus.ACTIVE : UserStatus.BLOCKED,
        newStatus: isBlock ? UserStatus.BLOCKED : UserStatus.ACTIVE,
        reason: reasons[Math.floor(Math.random() * reasons.length)],
        changedByAdminId: admin.adminId,
      });
      await this.userStatusHistoryRepository.save(history);
    }
  }

  /**
   * Creates auth sessions for testing login/session flows.
   */
  private async createAuthSessions(users: UserEntity[]): Promise<void> {
    const tokenHash = await bcrypt.hash('seed-access-token', 10);
    const refreshHash = await bcrypt.hash('seed-refresh-token', 10);

    for (let i = 0; i < 8; i++) {
      const user = users[Math.floor(Math.random() * users.length)];
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 7);

      const session = this.authSessionRepository.create({
        userId: user.id,
        accessTokenHash: tokenHash,
        refreshTokenHash: refreshHash,
        expiresAt,
        isRevoked: Math.random() > 0.9,
        ipAddress: `192.168.1.${Math.floor(Math.random() * 255)}`,
        userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)',
      });
      await this.authSessionRepository.save(session);
    }
  }

  /**
   * Creates OTP requests for testing (SEND_VERIFICATION, REGISTER, etc.).
   */
  private async createOtpRequests(users: UserEntity[]): Promise<OtpRequestEntity[]> {
    const otpHash = await bcrypt.hash('123456', 10);
    const otpRequests: OtpRequestEntity[] = [];

    for (let i = 0; i < 12; i++) {
      const user = users[Math.floor(Math.random() * users.length)];
      const purposes = [
        OtpPurpose.SEND_VERIFICATION,
        OtpPurpose.REGISTER,
        OtpPurpose.RESET,
        OtpPurpose.EMAIL_VERIFICATION,
      ];
      const purpose = purposes[i % purposes.length];
      const expiresAt = new Date();
      expiresAt.setMinutes(expiresAt.getMinutes() + 15);

      const otp = this.otpRequestRepository.create({
        fullMobileNumber: user.fullMobileNumber,
        email: user.email,
        otpHash,
        purpose,
        attempts: Math.floor(Math.random() * 2),
        maxAttempts: 3,
        expiresAt,
        lockedUntil: null,
        resendAttempts: 0,
        lastResendAt: null,
        isConsumed: Math.random() > 0.6,
      });
      const saved = await this.otpRequestRepository.save(otp);
      otpRequests.push(saved);
    }

    return otpRequests;
  }

  /**
   * Creates system settings (app config key-value).
   */
  private async createSystemSettings(): Promise<void> {
    const settings = [
      { key: 'maintenance_mode', value: 'false' },
      { key: 'min_withdrawal_amount_usd', value: '10' },
      { key: 'max_withdrawal_amount_usd', value: '10000' },
      { key: 'kyc_required_for_withdrawal', value: 'true' },
      { key: 'support_email', value: 'support@omlapay.com' },
      { key: 'display_currency', value: 'USD' },
    ];

    for (const { key, value } of settings) {
      const setting = this.systemSettingsRepository.create({
        settingKey: key,
        settingValue: value,
      });
      await this.systemSettingsRepository.save(setting);
    }
  }

  /**
   * Creates send pending requests (awaiting OTP confirmation).
   */
  private async createSendPendingRequests(
    users: UserEntity[],
    coins: CoinEntity[],
    wallets: WalletEntity[],
    otpRequests: OtpRequestEntity[],
  ): Promise<void> {
    const networks = ['mainnet', 'testnet', 'polygon', 'bsc'];

    for (let i = 0; i < 10; i++) {
      const user = users[Math.floor(Math.random() * users.length)];
      const userWallets = wallets.filter((w) => w.userId === user.id);
      if (userWallets.length === 0) continue;

      const otp = otpRequests.find((o) => o.fullMobileNumber === user.fullMobileNumber)
        ?? otpRequests[Math.floor(Math.random() * otpRequests.length)];
      const wallet = userWallets[Math.floor(Math.random() * userWallets.length)];
      const coin = coins.find((c) => c.id === wallet.coinId);
      if (!coin) continue;

      const expiresAt = new Date();
      expiresAt.setMinutes(expiresAt.getMinutes() + 30);

      const recipientType =
        Math.random() > 0.5 ? RecipientType.INTERNAL : RecipientType.EXTERNAL;

      const pending = this.sendPendingRequestRepository.create({
        userId: user.id,
        otpRequestId: otp.id,
        recipientType,
        recipientIdentifier:
          recipientType === RecipientType.INTERNAL
            ? `+966${500000000 + Math.floor(Math.random() * 500000000)}`
            : this.generateRandomAddress(),
        coinId: coin.id,
        network: networks[Math.floor(Math.random() * networks.length)],
        amount: (Math.random() * 500).toFixed(coin.decimals),
        fee: (Math.random() * 2).toFixed(coin.decimals),
        recipientUserId: null,
        recipientWalletId: null,
        recipientAddress: recipientType === RecipientType.EXTERNAL ? this.generateRandomAddress() : null,
        addressTag: null,
        expiresAt,
      });

      await this.sendPendingRequestRepository.save(pending);
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
        where: { email: 'smallick@marsdevs.com' },
      });

      if (existingAdmin) {
        return successResponse(
          {
            email: 'smallick@marsdevs.com',
            message: 'Admin already exists',
          },
          'Admin account already seeded',
        );
      }

      await this.createSeedAdmins();
      return { message: 'Admin accounts seeded successfully' };
    } catch (error) {
      console.error('Failed to seed admin:', error);
      throw new Error('Failed to seed admin');
    }
  }

  /**
   * Creates seed admin accounts (used by seed and by seed-admin endpoint).
   */
  private async createSeedAdmins(): Promise<void> {
    const passwordHash = await bcrypt.hash('Password@123', 10);

    const admin = this.adminRepository.create({
      email: 'smallick@marsdevs.com',
      phoneNumber: '+966500000002',
      passwordHash,
      isActive: true,
      role: AdminRole.SUPER_ADMIN,
    });

    const admin2 = this.adminRepository.create({
      email: 'rahul@marsdevs.com',
      phoneNumber: '+966500000001',
      passwordHash,
      isActive: true,
      role: AdminRole.ADMIN,
    });

    const savedAdmin = await this.adminRepository.save([admin, admin2] as AdminEntity[]);

    const adminSecurity = this.adminSecurityRepository.create({
      adminId: savedAdmin[0].adminId,
      failedLoginAttempts: 0,
      passwordUpdatedAt: new Date(),
    });

    const adminSecurity2 = this.adminSecurityRepository.create({
      adminId: savedAdmin[1].adminId,
      failedLoginAttempts: 0,
      passwordUpdatedAt: new Date(),
    });

    await this.adminSecurityRepository.save([adminSecurity, adminSecurity2] as AdminSecurityEntity[]);
  }

  /**
   * Creates sample admin notifications (one of each type) for all active admins.
   * Part of seed data so the notifications inbox has data for UI testing.
   */
  private async createSampleAdminNotifications(): Promise<void> {
    await this.adminNotificationsService.notifyAllAdmins(
      AdminNotificationType.USER,
      'New User Registered',
      'A new user has registered on the platform: test@example.com.',
    );
    await this.adminNotificationsService.notifyAllAdmins(
      AdminNotificationType.SECURITY,
      'User Blocked',
      'A user has been blocked by an administrator for violating terms of service.',
    );
    await this.adminNotificationsService.notifyAllAdmins(
      AdminNotificationType.TICKET,
      'New Support Ticket',
      'A new support ticket has been created by user omar.a.ziad@gmail.com.',
    );
    await this.adminNotificationsService.notifyAllAdmins(
      AdminNotificationType.TRANSACTION,
      'Failed Transaction',
      'A transaction has failed. Amount: 150.00. Transaction ID: A1B2C3D4. User ID: E5F6G7H8.',
    );
  }

  async createSumsubAccessToken(dto: {
    userId: string;
    levelName: string;
    email?: string;
    phone?: string;
    ttlInSecs?: number;
  }) {
    // Dev-focused helper that delegates to shared Sumsub service
    return this.sumsubService.createSdkAccessToken(dto);
  }

  async getSumsubLevels() {
    // Dev-focused helper that delegates to shared Sumsub service
    return this.sumsubService.getVerificationLevels();
  }

  async getSumsubApplicantStatus(userId: string) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Sumsub dev-tools endpoint is only available in development or dev environment.',
      });
    }

    try {
      const applicant = await this.sumsubService.getApplicantByExternalUserId(userId);
      return successResponse(applicant, 'Applicant status retrieved successfully');
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Failed to get applicant status';
      return errorResponse('Failed to get applicant status', message);
    }
  }

  /**
   * Create seed FAQs data.
   */
  private async createFaqs(): Promise<void> {
    const faqs = [
      {
        question: 'What is Omlapay?',
        answer:
          'Omlapay is a secure digital wallet platform that allows you to store, send, and receive cryptocurrencies safely.',
        isActive: true,
      },
      {
        question: 'How do I register?',
        answer:
          'You can register by providing your mobile number. You will receive an OTP for verification, then set up a secure passcode.',
        isActive: true,
      },
      {
        question: 'Which cryptocurrencies are supported?',
        answer:
          'Omlapay supports Bitcoin (BTC), Ethereum (ETH), Solana (SOL), USDT, USDC, and BNB.',
        isActive: true,
      },
      {
        question: 'Is my data secure?',
        answer:
          'Yes, Omlapay uses industry-standard encryption and security measures to protect your data and funds.',
        isActive: true,
      },
      {
        question: 'How do I withdraw funds?',
        answer:
          'After completing KYC verification, you can withdraw funds to your external wallet using the withdrawal feature.',
        isActive: true,
      },
    ];

    const faqEntities = this.faqRepository.create(faqs);
    await this.faqRepository.save(faqEntities);
  }

  /**
   * Create seed legal content (Terms & Conditions and Privacy Policy).
   */
  private async createLegalContent(): Promise<void> {
    const legalContent = [
      // Terms & Conditions - English
      {
        type: LegalContentType.TERMS,
        language: 'en',
        content: `
# Terms & Conditions

## 1. Acceptance of Terms
By using Omlapay, you agree to be bound by these Terms and Conditions.

## 2. Services
Omlapay provides cryptocurrency wallet services including storage, sending, and receiving of digital assets.

## 3. User Responsibilities
- You are responsible for maintaining the security of your account
- You must complete KYC verification before using certain features
- You must comply with all applicable laws and regulations

## 4. Limitation of Liability
Omlapay is not liable for any losses resulting from unauthorized access to your account or failure to secure your credentials.

## 5. Changes to Terms
We reserve the right to modify these terms at any time. Continued use of the service constitutes acceptance of modified terms.
        `.trim(),
        version: '1.0',
        isActive: true,
      },
      // Terms & Conditions - Arabic
      {
        type: LegalContentType.TERMS,
        language: 'ar',
        content: `
# الشروط والأحكام

## 1. قبول الشروط
باستخدام Omlapay، فإنك توافق على الالتزام بهذه الشروط والأحكام.

## 2. الخدمات
يوفر Omlapay خدمات محفظة العملات المشفرة بما في ذلك التخزين والإرسال والاستلام للأصول الرقمية.

## 3. مسؤوليات المستخدم
- أنت مسؤول عن الحفاظ على أمان حسابك
- يجب عليك إكمال التحقق من KYC قبل استخدام ميزات معينة
- يجب عليك الامتثال لجميع القوانين واللوائح المعمول بها

## 4. تحديد المسؤولية
Omlapay غير مسؤول عن أي خسائر ناتجة عن الوصول غير المصرح به إلى حسابك أو فشل في تأمين بيانات اعتمادك.

## 5. تغييرات الشروط
نحتفظ بالحق في تعديل هذه الشروط في أي وقت. الاستمرار في استخدام الخدمة يشكل قبولاً للشروط المعدلة.
        `.trim(),
        version: '1.0',
        isActive: true,
      },
      // Privacy Policy - English
      {
        type: LegalContentType.PRIVACY,
        language: 'en',
        content: `
# Privacy Policy

## 1. Information We Collect
We collect information you provide directly, including:
- Mobile number and contact information
- KYC verification documents
- Transaction history
- Device information

## 2. How We Use Your Information
We use your information to:
- Provide and improve our services
- Verify your identity (KYC)
- Process transactions
- Comply with legal obligations
- Send important notifications

## 3. Data Security
We implement industry-standard security measures to protect your personal information and funds.

## 4. Data Sharing
We do not sell your personal information. We may share information only as required by law or with your consent.

## 5. Your Rights
You have the right to:
- Access your personal data
- Request correction of inaccurate data
- Request deletion of your data
- Withdraw consent for data processing

## 6. Contact Us
For privacy-related inquiries, please contact us through the app support channels.
        `.trim(),
        version: '1.0',
        isActive: true,
      },
      // Privacy Policy - Arabic
      {
        type: LegalContentType.PRIVACY,
        language: 'ar',
        content: `
# سياسة الخصوصية

## 1. المعلومات التي نجمعها
نجمع المعلومات التي تقدمها مباشرة، بما في ذلك:
- رقم الهاتف المحمول ومعلومات الاتصال
- وثائق التحقق من KYC
- سجل المعاملات
- معلومات الجهاز

## 2. كيفية استخدام معلوماتك
نستخدم معلوماتك لـ:
- تقديم وتحسين خدماتنا
- التحقق من هويتك (KYC)
- معالجة المعاملات
- الامتثال للالتزامات القانونية
- إرسال الإشعارات المهمة

## 3. أمان البيانات
نطبق تدابير أمنية معيارية في الصناعة لحماية معلوماتك الشخصية وأموالك.

## 4. مشاركة البيانات
لا نبيع معلوماتك الشخصية. قد نشارك المعلومات فقط حسبما يتطلبه القانون أو بموافقتك.

## 5. حقوقك
لديك الحق في:
- الوصول إلى بياناتك الشخصية
- طلب تصحيح البيانات غير الدقيقة
- طلب حذف بياناتك
- سحب الموافقة على معالجة البيانات

## 6. اتصل بنا
للاستفسارات المتعلقة بالخصوصية، يرجى الاتصال بنا من خلال قنوات دعم التطبيق.
        `.trim(),
        version: '1.0',
        isActive: true,
      },
    ];

    const legalContentEntities = this.legalContentRepository.create(legalContent);
    await this.legalContentRepository.save(legalContentEntities);
  }

  /**
   * Create seed About Omlapay content.
   */
  private async createAboutContent(): Promise<void> {
    const aboutContent = [
      // English
      {
        language: 'en',
        description:
          'Omlapay is a secure and user-friendly cryptocurrency wallet platform designed to make digital asset management simple and accessible for everyone.',
        features: [
          'Secure cryptocurrency storage',
          'Easy send and receive functionality',
          'Multi-currency support (BTC, ETH, SOL, USDT, USDC, BNB)',
          'KYC verification for enhanced security',
          'Real-time transaction tracking',
          '24/7 customer support',
        ],
        mission:
          'To provide secure, accessible, and user-friendly cryptocurrency services that empower individuals to manage their digital assets with confidence.',
        vision:
          'To become the leading cryptocurrency wallet platform in the region, known for security, reliability, and exceptional user experience.',
        isActive: true,
      },
      // Arabic
      {
        language: 'ar',
        description:
          'Omlapay هي منصة محفظة عملات مشفرة آمنة وسهلة الاستخدام مصممة لجعل إدارة الأصول الرقمية بسيطة ومتاحة للجميع.',
        features: [
          'تخزين آمن للعملات المشفرة',
          'وظائف إرسال واستقبال سهلة',
          'دعم متعدد العملات (BTC، ETH، SOL، USDT، USDC، BNB)',
          'التحقق من KYC لتعزيز الأمان',
          'تتبع المعاملات في الوقت الفعلي',
          'دعم العملاء على مدار الساعة طوال أيام الأسبوع',
        ],
        mission:
          'توفير خدمات عملات مشفرة آمنة ويمكن الوصول إليها وسهلة الاستخدام تمكن الأفراد من إدارة أصولهم الرقمية بثقة.',
        vision:
          'أن نصبح منصة محفظة العملات المشفرة الرائدة في المنطقة، معروفة بالأمان والموثوقية وتجربة المستخدم الاستثنائية.',
        isActive: true,
      },
    ];

    const aboutEntities = this.aboutRepository.create(aboutContent);
    await this.aboutRepository.save(aboutEntities);
  }

  /**
   * Test Binance sub-account creation with custom credentials.
   * Uses Ed25519 signing (always).
   * This is a dev-tools only method - keeps testing logic out of BinanceService.
   */
  async testBinanceSubaccount(dto: CreateBinanceSubaccountDto) {
    // Only allow in development or dev environment
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message: 'Binance sub-account test endpoint is only available in development or dev environment.',
      });
    }

    const endpoint = '/sapi/v1/broker/subAccount';
    const baseUrl = dto.baseUrl || 'https://api.binance.com';
    const timestamp = Date.now();

    const params: Record<string, string> = {
      timestamp: String(timestamp),
    };

    if (dto.recvWindow) {
      params.recvWindow = dto.recvWindow;
    }

    // Create Ed25519 signature
    const payload = new URLSearchParams(params).toString();
    
    try {
      // Normalize line endings for Ed25519 PKCS#8 PEM key
      const privateKey = dto.privateKey.trim().replace(/\r\n/g, '\n').replace(/\r/g, '\n');
      
      // Create Ed25519 signature using PKCS#8 PEM format
      const key = createPrivateKey(privateKey);
      const buffer = Buffer.from(payload, 'utf8');
      const signature = sign(null, buffer, key).toString('base64');

      const body = new URLSearchParams({ ...params, signature });
      const res = await fetch(`${baseUrl}${endpoint}`, {
        method: 'POST',
        headers: {
          'X-MBX-APIKEY': dto.apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body,
      });

      const contentType = res.headers.get('content-type') || '';
      const isJson = contentType.toLowerCase().includes('application/json');
      const rawBody = await res.text();

      let parsed: any | undefined;
      if (isJson) {
        try {
          parsed = JSON.parse(rawBody);
        } catch {
          // Fall through to error handling
        }
      }

      if (!res.ok) {
        const msg =
          parsed?.msg ||
          parsed?.message ||
          rawBody?.slice(0, 500) ||
          'Unknown error response';
        return errorResponse(
          `Binance API error (${res.status})`,
          msg,
        );
      }

      if (!isJson || parsed == null) {
        const location = res.headers.get('location') || '';
        const hint = location ? ` location="${location}"` : '';
        return errorResponse(
          `Binance API returned non-JSON response`,
          `${res.status} content-type="${contentType}"${hint}: ${rawBody.slice(0, 500)}`,
        );
      }

      return successResponse(
        {
          subaccountId: parsed.subaccountId,
          email: parsed.email,
          tag: parsed.tag,
        },
        'Binance sub-account created successfully',
      );
    } catch (error) {
      return errorResponse(
        'Failed to create Binance sub-account',
        (error as Error).message,
      );
    }
  }

  /**
   * Block a sub-account by Binance subAccountId.
   * Accepts apiKey, privateKey, baseUrl in body (like test-subaccount).
   * Finds the user linked to the sub-account and sets isActive = false.
   * Dev-only endpoint.
   */
  async blockSubaccount(dto: BlockSubaccountDto) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance sub-account block endpoint is only available in development or dev environment.',
      });
    }

    const { subAccountId } = dto;

    const user = await this.userRepository.findOne({
      where: { binanceSubaccountId: subAccountId },
    });

    if (!user) {
      return errorResponse(
        'User not found',
        `No user found with binanceSubaccountId: ${subAccountId}`,
      );
    }

    if (!user.isActive) {
      return errorResponse(
        'Sub-account already blocked',
        `User ${user.id} (subAccountId: ${subAccountId}) is already blocked.`,
      );
    }

    const oldStatus = UserStatus.ACTIVE;
    user.isActive = false;
    await this.userRepository.save(user);

    const admin = await this.adminRepository.findOne({
      where: { isActive: true },
      order: { createdAt: 'ASC' },
    });

    if (admin) {
      await this.userStatusHistoryRepository.save({
        userId: user.id,
        oldStatus,
        newStatus: UserStatus.BLOCKED,
        reason: dto.reason ?? 'Blocked via dev-tools (sub-account)',
        changedByAdminId: admin.adminId,
      });
    }

    return successResponse(
      {
        userId: user.id,
        subAccountId,
        status: 'Blocked',
      },
      'Sub-account blocked successfully',
    );
  }

  /**
   * Unblock a sub-account by Binance subAccountId.
   * Accepts apiKey, privateKey, baseUrl in body (like test-subaccount).
   * Finds the user linked to the sub-account and sets isActive = true.
   * Dev-only endpoint.
   */
  async unblockSubaccount(dto: UnblockSubaccountDto) {
    const nodeEnv = process.env.NODE_ENV?.toLowerCase();
    if (nodeEnv !== 'development' && nodeEnv !== 'dev') {
      throw new ForbiddenException({
        status: 'error',
        message:
          'Binance sub-account unblock endpoint is only available in development or dev environment.',
      });
    }

    const { subAccountId } = dto;

    const user = await this.userRepository.findOne({
      where: { binanceSubaccountId: subAccountId },
    });

    if (!user) {
      return errorResponse(
        'User not found',
        `No user found with binanceSubaccountId: ${subAccountId}`,
      );
    }

    if (user.isActive) {
      return errorResponse(
        'Sub-account already active',
        `User ${user.id} (subAccountId: ${subAccountId}) is already active.`,
      );
    }

    const oldStatus = UserStatus.BLOCKED;
    user.isActive = true;
    await this.userRepository.save(user);

    const admin = await this.adminRepository.findOne({
      where: { isActive: true },
      order: { createdAt: 'ASC' },
    });

    if (admin) {
      await this.userStatusHistoryRepository.save({
        userId: user.id,
        oldStatus,
        newStatus: UserStatus.ACTIVE,
        reason: 'Unblocked via dev-tools (sub-account)',
        changedByAdminId: admin.adminId,
      });
    }

    return successResponse(
      {
        userId: user.id,
        subAccountId,
        status: 'Active',
      },
      'Sub-account unblocked successfully',
    );
  }

  /**
   * Check SMS service (Taqnyat) balance.
   * Allowed in production - useful for monitoring SMS credits.
   */
  async checkSmsBalance() {
    const apiKey = this.configService.get<string>('TAQNYAT_API_KEY');

    if (!apiKey) {
      return errorResponse(
        'SMS service not configured',
        'TAQNYAT_API_KEY environment variable is not set',
      );
    }

    try {
      const response = await fetch('https://api.taqnyat.sa/account/balance', {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${apiKey}`,
        },
      });

      const contentType = response.headers.get('content-type') || '';
      const isJson = contentType.toLowerCase().includes('application/json');
      const rawBody = await response.text();

      let parsed: any | undefined;
      if (isJson) {
        try {
          parsed = JSON.parse(rawBody);
        } catch {
          // Fall through to error handling
        }
      }

      if (!response.ok) {
        const msg =
          parsed?.message ||
          parsed?.error ||
          rawBody?.slice(0, 500) ||
          'Unknown error response';
        return errorResponse(
          `SMS service API error (${response.status})`,
          msg,
        );
      }

      if (!isJson || parsed == null) {
        return errorResponse(
          'SMS service returned non-JSON response',
          `${response.status} content-type="${contentType}": ${rawBody.slice(0, 500)}`,
        );
      }

      return successResponse(
        parsed,
        'SMS service balance retrieved successfully',
      );
    } catch (error) {
      return errorResponse(
        'Failed to check SMS service balance',
        (error as Error).message,
      );
    }
  }
}

