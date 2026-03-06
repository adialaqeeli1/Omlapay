import {
  Injectable,
  ForbiddenException,
  BadRequestException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { Brackets } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as QRCode from 'qrcode';
import {
  CoinEntity,
  TransactionEntity,
  WalletEntity,
} from '@common/database/model';
import {
  TransactionDirection,
  TransactionType,
} from '@common/database/model';
import { DepositAddressService } from '@common/services/binance/deposit-address.service';
import { SUPPORTED_NETWORKS, type AssetFilter } from '@common/constants';
import { UserKycGuardService } from '@common/services/user-kyc-guard/user-kyc-guard.service';
import {
  successResponse,
  encodeCursor,
  decodeCursor,
  maskAddress,
} from '@common/utils';

@Injectable()
export class ReceiveService {
  private readonly logger = new Logger(ReceiveService.name);

  constructor(
    @InjectRepository(CoinEntity)
    private coinRepository: Repository<CoinEntity>,
    @InjectRepository(TransactionEntity)
    private transactionRepository: Repository<TransactionEntity>,
    @InjectRepository(WalletEntity)
    private walletRepository: Repository<WalletEntity>,
    private userKycGuardService: UserKycGuardService,
    private depositAddressService: DepositAddressService,
  ) {}

  /**
   * Get wallet addresses grouped by network for the Wallet Selection Screen.
   */
  private assertBinanceKeys(user: { binanceApiKey?: string | null; binanceSecretKey?: string | null }): void {
    if (!user.binanceApiKey || !user.binanceSecretKey) {
      throw new BadRequestException({
        status: 'error',
        message: 'Binance API keys not configured. Please complete KYC.',
      });
    }
  }

  async getWallets(userId: string) {
    const user = await this.userKycGuardService.assertUserCanPerformAction(userId, 'receive');
    this.assertBinanceKeys(user);

    const wallets: Array<{
      network: string;
      networkDisplayName: string;
      networkIconUrl: string | null;
      coins: Array<{
        symbol: string;
        name: string;
        address: string;
        addressTag: string | null;
      }>;
    }> = [];

    const coinCache = new Map<string, CoinEntity>();
    const addressCache = new Map<string, { address: string; tag: string }>();

    for (const net of SUPPORTED_NETWORKS) {
      const coins: Array<{
        symbol: string;
        name: string;
        address: string;
        addressTag: string | null;
      }> = [];

      for (const symbol of net.coins) {
        try {
          const cacheKey = `${symbol}_${net.network}`;
          let addressData = addressCache.get(cacheKey);

          if (!addressData) {
            const result = await this.depositAddressService.getDepositAddress(
              user.binanceApiKey!,
              user.binanceSecretKey!,
              symbol,
              net.network,
            );
            addressData = {
              address: result.address,
              tag: result.tag || '',
            };
            addressCache.set(cacheKey, addressData);
          }

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
            address: addressData.address,
            addressTag: addressData.tag || null,
          });
        } catch (err) {
          this.logger.warn(
            `[Receive] Failed to fetch address for ${symbol}/${net.network}: ${err instanceof Error ? err.message : 'Unknown error'}`,
          );
          // Skip this coin but continue with others
        }
      }

      if (coins.length > 0) {
        wallets.push({
          network: net.network,
          networkDisplayName: net.displayName,
          networkIconUrl: null,
          coins,
        });
      }
    }

    return successResponse({ wallets });
  }

  /**
   * Get single wallet address for a network and coin.
   */
  async getWalletAddress(
    userId: string,
    network: string,
    coin: string,
  ): Promise<{ address: string; addressTag: string | null }> {
    const user = await this.userKycGuardService.assertUserCanPerformAction(userId, 'receive');
    this.assertBinanceKeys(user);

    const networkUpper = network.toUpperCase();
    const coinUpper = coin.toUpperCase();

    const net = SUPPORTED_NETWORKS.find((n) => n.network === networkUpper);
    if (!net || !(net.coins as readonly string[]).includes(coinUpper)) {
      throw new BadRequestException({
        status: 'error',
        message: `Invalid network or coin combination: ${network}/${coin}`,
      });
    }

    const result = await this.depositAddressService.getDepositAddress(
      user.binanceApiKey!,
      user.binanceSecretKey!,
      coinUpper,
      networkUpper,
    );

    return {
      address: result.address,
      addressTag: result.tag || null,
    };
  }

  /**
   * Generate QR code for wallet address.
   * Optionally uses blockchain URI format for better scanner compatibility.
   */
  async getQrCode(
    userId: string,
    network: string,
    coin: string,
    format: 'png' | 'svg' = 'png',
  ): Promise<{ buffer: Buffer; mimeType: string }> {
    const { address } = await this.getWalletAddress(userId, network, coin);

    const qrContent = this.buildQrContent(address, network, coin);

    const options = {
      width: 400,
      margin: 2,
      errorCorrectionLevel: 'M' as const,
    };

    if (format === 'svg') {
      const svg = await QRCode.toString(qrContent, {
        ...options,
        type: 'svg',
      });
      return {
        buffer: Buffer.from(svg, 'utf8'),
        mimeType: 'image/svg+xml',
      };
    }

    const buffer = await QRCode.toBuffer(qrContent, {
      ...options,
      type: 'png',
    });

    return {
      buffer,
      mimeType: 'image/png',
    };
  }

  /**
   * Build QR content - use blockchain URI if supported, else plain address.
   */
  private buildQrContent(address: string, network: string, coin: string): string {
    const net = network.toUpperCase();
    const c = coin.toUpperCase();

    if (net === 'BTC' && c === 'BTC') {
      return `bitcoin:${address}`;
    }
    if ((net === 'ETH' || net === 'BNB') && (c === 'ETH' || c === 'BNB')) {
      return `ethereum:${address}`;
    }
    // Tron, Solana: plain address (no standard URI in Phase 1)
    return address;
  }

  /**
   * Get receive transaction history (IN direction, RECEIVED type).
   * Uses cursor-based pagination (after, limit) matching /v1/notifications pattern.
   */
  async getReceiveHistory(
    userId: string,
    query: { asset?: AssetFilter; after?: string; limit?: number },
  ) {
    await this.userKycGuardService.assertUserCanPerformAction(userId, 'receive');

    const { after, limit = 20, asset = 'ALL' } = query;

    const qb = this.transactionRepository
      .createQueryBuilder('tx')
      .leftJoinAndSelect('tx.coin', 'coin')
      .where('tx.userId = :userId', { userId })
      .andWhere('tx.direction = :direction', {
        direction: TransactionDirection.IN,
      })
      .andWhere('tx.txType = :txType', { txType: TransactionType.RECEIVED })
      .orderBy('tx.createdAt', 'DESC')
      .addOrderBy('tx.id', 'DESC');

    if (asset !== 'ALL') {
      qb.andWhere('coin.symbol = :symbol', { symbol: asset });
    }

    if (after) {
      const decoded = decodeCursor(after);
      if (decoded) {
        const cursorDate = new Date(decoded.timestamp);
        qb.andWhere(
          new Brackets((sub) => {
            sub
              .where('tx.createdAt < :cursorCreatedAt')
              .orWhere('(tx.createdAt = :cursorCreatedAt AND tx.id < :cursorId)');
          }),
          { cursorCreatedAt: cursorDate, cursorId: decoded.id },
        );
      }
    }

    const transactions = await qb.take(limit + 1).getMany();

    const hasMore = transactions.length > limit;
    if (hasMore) {
      transactions.pop();
    }

    const now = new Date();
    const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);

    const recently: typeof transactions = [];
    const byMonth: Record<string, typeof transactions> = {};

    for (const tx of transactions) {
      if (tx.createdAt >= oneDayAgo) {
        recently.push(tx);
      } else {
        const key = `${tx.createdAt.getFullYear()}-${String(tx.createdAt.getMonth() + 1).padStart(2, '0')}`;
        if (!byMonth[key]) byMonth[key] = [];
        byMonth[key].push(tx);
      }
    }

    const groupedBy: Record<string, typeof transactions> = {
      Recently: recently,
    };

    const months = Object.keys(byMonth).sort().reverse();
    for (const m of months) {
      const [y, mo] = m.split('-');
      const d = new Date(parseInt(y, 10), parseInt(mo, 10) - 1);
      const label = d.toLocaleString('default', {
        month: 'long',
        year: 'numeric',
      });
      groupedBy[label] = byMonth[m] ?? [];
    }

    const formatTx = (tx: TransactionEntity) => ({
      id: tx.id,
      assetSymbol: tx.coin?.symbol ?? 'UNKNOWN',
      assetName: tx.coin?.name ?? 'Unknown',
      assetIconUrl: tx.coin?.iconUrl ?? null,
      amount: `+${parseFloat(tx.amount).toFixed(tx.coin?.decimals ?? 8)}`,
      network: tx.network,
      createdAt: tx.createdAt,
      txHash: tx.txHash,
      status: tx.status,
    });

    const formatted = transactions.map(formatTx);

    const formattedGroupedBy: Record<string, ReturnType<typeof formatTx>[]> = {};
    for (const [key, txs] of Object.entries(groupedBy)) {
      formattedGroupedBy[key] = txs.map(formatTx);
    }

    let nextCursor: string | null = null;
    if (hasMore && transactions.length > 0) {
      const lastItem = transactions[transactions.length - 1];
      nextCursor = encodeCursor(lastItem.id, lastItem.createdAt);
    }

    return successResponse({
      transactions: formatted,
      groupedBy: formattedGroupedBy,
      pagination: {
        nextCursor,
        hasMore,
        limit,
      },
    });
  }

  /**
   * Get single receive transaction details.
   */
  async getReceiveTransactionDetails(userId: string, transactionId: string) {
    await this.userKycGuardService.assertUserCanPerformAction(userId, 'receive');

    const tx = await this.transactionRepository.findOne({
      where: {
        id: transactionId,
        userId,
        direction: TransactionDirection.IN,
        txType: TransactionType.RECEIVED,
      },
      relations: ['coin'],
    });

    if (!tx) {
      throw new NotFoundException({
        status: 'error',
        message: 'Transaction not found or not a receive transaction.',
      });
    }

    return successResponse({
      id: tx.id,
      assetSymbol: tx.coin?.symbol ?? 'UNKNOWN',
      assetName: tx.coin?.name ?? 'Unknown',
      amount: `+${parseFloat(tx.amount).toFixed(tx.coin?.decimals ?? 8)}`,
      network: tx.network,
      createdAt: tx.createdAt,
      txHash: tx.txHash,
      status: tx.status,
      senderAddress: tx.senderAddress ? maskAddress(tx.senderAddress) : null,
      receiverAddress: tx.receiverAddress
        ? maskAddress(tx.receiverAddress)
        : null,
    });
  }
}
