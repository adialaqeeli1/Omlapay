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
  CoinEntity,
  WalletEntity,
  SwapEntity,
  NotificationEntity,
} from '@common/database/model';
import { SwapStatus } from '@common/database/model';
import { TradeService } from '@common/services/binance/trade.service';
import { PriceService } from '@common/services/binance/price.service';
import { ExchangeInfoService } from '@common/services/binance/exchange-info.service';
import { UserKycGuardService } from '@common/services/user-kyc-guard/user-kyc-guard.service';
import { successResponse, encodeCursor, decodeCursor } from '@common/utils';
import { isStablecoin, SUPPORTED_COINS } from '@common/constants';
import { SystemSettingsService } from '@common/services/system-settings/system-settings.service';
import { BINANCE_FEE_PERCENT, IDEMPOTENCY_WINDOW_MS } from './swap.constants';
import { NotificationType, NotificationReferenceType } from '@common/database/model';

@Injectable()
export class SwapService {
  private readonly logger = new Logger(SwapService.name);

  constructor(
    @InjectRepository(CoinEntity)
    private coinRepository: Repository<CoinEntity>,
    @InjectRepository(WalletEntity)
    private walletRepository: Repository<WalletEntity>,
    @InjectRepository(SwapEntity)
    private swapRepository: Repository<SwapEntity>,
    @InjectRepository(NotificationEntity)
    private notificationRepository: Repository<NotificationEntity>,
    private tradeService: TradeService,
    private priceService: PriceService,
    private exchangeInfoService: ExchangeInfoService,
    private userKycGuardService: UserKycGuardService,
    private systemSettingsService: SystemSettingsService,
    private dataSource: DataSource,
  ) {}

  /**
   * Get assets available for swap with user balances.
   */
  async getAvailableAssets(userId: string) {
    await this.userKycGuardService.assertUserCanPerformAction(userId, 'swap');

    const coins = await this.coinRepository.find({
      where: SUPPORTED_COINS.map((s) => ({ symbol: s, isActive: true })),
      order: { displayOrder: 'ASC' },
    });

    const wallets = await this.walletRepository.find({
      where: { userId },
      relations: ['coin'],
    });

    const walletByCoinId = new Map(wallets.map((w) => [w.coinId, w]));

    const prices = await this.priceService.getCoinPrices(
      coins.map((c) => c.symbol),
    );

    const assets = coins.map((coin) => {
      const wallet = walletByCoinId.get(coin.id);
      const balance = wallet
        ? parseFloat(wallet.balance) - parseFloat(wallet.lockedBalance || '0')
        : 0;
      const price = prices[coin.symbol] ?? 0;
      const usdValue = balance * price;

      return {
        symbol: coin.symbol,
        name: coin.name ?? coin.symbol,
        iconUrl: coin.iconUrl ?? null,
        balance: balance.toFixed(coin.decimals),
        balanceUsd: usdValue.toFixed(2),
        decimals: coin.decimals,
      };
    });

    return successResponse({ assets });
  }

  /**
   * Returns the Binance symbol for the first leg of a swap.
   * For non-stablecoin→non-stablecoin (e.g. BTC→ETH), two legs are needed:
   * Leg 1: SELL fromCoin for USDT; Leg 2: BUY toCoin with USDT.
   */
  private getTradingPair(fromCoin: string, toCoin: string): string {
    const from = fromCoin.toUpperCase();
    const to = toCoin.toUpperCase();
    if (from === to) {
      throw new BadRequestException({
        status: 'error',
        message: 'Swap cannot be done to same asset.',
      });
    }
    if (isStablecoin(from)) {
      return `${to}USDT`;
    }
    if (isStablecoin(to)) {
      return `${from}USDT`;
    }
    return `${from}USDT`;
  }

  /** Returns true when both from and to are non-stablecoins (e.g. BTC→ETH). */
  private isTwoLegSwap(fromCoin: string, toCoin: string): boolean {
    return !isStablecoin(fromCoin) && !isStablecoin(toCoin);
  }

  /**
   * Deterministic idempotency key for retries. Same params within 5-min window share key.
   */
  private generateSwapIdempotencyKey(
    userId: string,
    fromCoin: string,
    toCoin: string,
    amount: number,
  ): string {
    const window = Math.floor(Date.now() / IDEMPOTENCY_WINDOW_MS);
    const hash = crypto
      .createHash('sha256')
      .update(`${userId}-${fromCoin}-${toCoin}-${amount}-${window}`)
      .digest('hex')
      .substring(0, 16);
    return `swap-${userId}-${fromCoin}-${toCoin}-${hash}`;
  }

  private assertBinanceKeys(user: { binanceApiKey?: string | null; binanceSecretKey?: string | null }): void {
    if (!user.binanceApiKey || !user.binanceSecretKey) {
      throw new BadRequestException({
        status: 'error',
        message: 'Binance API keys not configured. Please complete KYC.',
      });
    }
  }

  /**
   * Get swap quote: exchange rate, fees, estimated output.
   */
  async getQuote(
    userId: string,
    dto: { fromCoin: string; toCoin: string; amount: number },
  ) {
    await this.userKycGuardService.assertUserCanPerformAction(userId, 'swap');

    const fromCoin = dto.fromCoin.toUpperCase();
    const toCoin = dto.toCoin.toUpperCase();

    if (fromCoin === toCoin) {
      throw new BadRequestException({
        status: 'error',
        message: 'Swap cannot be done to same asset.',
      });
    }

    const fromCoinEntity = await this.coinRepository.findOne({
      where: { symbol: fromCoin, isActive: true },
    });
    const toCoinEntity = await this.coinRepository.findOne({
      where: { symbol: toCoin, isActive: true },
    });

    if (!fromCoinEntity || !toCoinEntity) {
      throw new BadRequestException({
        status: 'error',
        message: 'Unsupported coin.',
      });
    }

    const amount = dto.amount;
    if (amount <= 0) {
      throw new BadRequestException({
        status: 'error',
        message: 'Please enter a valid amount.',
      });
    }

    const prices = await this.priceService.getCoinPrices([fromCoin, toCoin]);
    const fromPrice = prices[fromCoin] ?? 1;
    const toPrice = prices[toCoin] ?? 1;

    const swapFeePercent = await this.systemSettingsService.getSwapFeePercent();
    const fromValueUsd = amount * fromPrice;
    const estimatedToAmount = fromValueUsd / toPrice;
    const omlapayFee = fromValueUsd * swapFeePercent;
    const binanceFee = estimatedToAmount * BINANCE_FEE_PERCENT;
    const totalFee = omlapayFee + binanceFee * toPrice;
    const finalToAmount = estimatedToAmount - omlapayFee / toPrice - binanceFee;

    const wallet = await this.walletRepository.findOne({
      where: { userId, coinId: fromCoinEntity.id },
    });
    const available = wallet
      ? parseFloat(wallet.balance) - parseFloat(wallet.lockedBalance || '0')
      : 0;

    if (amount > available) {
      throw new BadRequestException({
        status: 'error',
        message: 'Amount exceeds available balance.',
      });
    }

    const symbol = this.getTradingPair(fromCoin, toCoin);
    const filters = await this.exchangeInfoService.getSymbolFilters(symbol);

    let minFromAmount = 0;
    let maxFromAmount = available;

    if (filters) {
      const isBuyingToCoin = isStablecoin(fromCoin);
      if (isBuyingToCoin) {
        minFromAmount = filters.minNotional;
        maxFromAmount = available;
      } else {
        minFromAmount = Math.max(
          filters.minQty,
          filters.minNotional / fromPrice,
        );
        maxFromAmount = Math.min(available, filters.maxQty);
      }
    }

    if (amount < minFromAmount) {
      throw new BadRequestException({
        status: 'error',
        message: `Minimum swap amount is ${minFromAmount.toFixed(fromCoinEntity.decimals)} ${fromCoin}.`,
      });
    }

    if (amount > maxFromAmount) {
      throw new BadRequestException({
        status: 'error',
        message: `Maximum swap amount is ${maxFromAmount.toFixed(fromCoinEntity.decimals)} ${fromCoin}.`,
      });
    }

    const fromAmountUsd = fromValueUsd;
    const estimatedToAmountUsd = finalToAmount * toPrice;

    return successResponse({
      fromCoin,
      toCoin,
      fromAmount: String(amount),
      fromAmountUsd: fromAmountUsd.toFixed(2),
      estimatedToAmount: finalToAmount.toFixed(toCoinEntity.decimals),
      estimatedToAmountUsd: estimatedToAmountUsd.toFixed(2),
      exchangeRate: (toPrice / fromPrice).toFixed(8),
      binanceFee: binanceFee.toFixed(toCoinEntity.decimals),
      omlapayFee: (omlapayFee / toPrice).toFixed(toCoinEntity.decimals),
      totalFee: totalFee.toFixed(4),
      available: available.toFixed(fromCoinEntity.decimals),
      minFromAmount: minFromAmount.toFixed(fromCoinEntity.decimals),
      maxFromAmount: maxFromAmount.toFixed(fromCoinEntity.decimals),
    });
  }

  /**
   * Execute swap: deduct from, credit to, record swap, place Binance order.
   */
  async execute(
    userId: string,
    dto: { fromCoin: string; toCoin: string; amount: number },
  ) {
    const user = await this.userKycGuardService.assertUserCanPerformAction(userId, 'swap');

    const fromCoin = dto.fromCoin.toUpperCase();
    const toCoin = dto.toCoin.toUpperCase();

    if (fromCoin === toCoin) {
      throw new BadRequestException({
        status: 'error',
        message: 'Swap cannot be done to same asset.',
      });
    }

    const fromCoinEntity = await this.coinRepository.findOneOrFail({
      where: { symbol: fromCoin, isActive: true },
    });
    const toCoinEntity = await this.coinRepository.findOneOrFail({
      where: { symbol: toCoin, isActive: true },
    });

    const fromWallet = await this.walletRepository.findOne({
      where: { userId, coinId: fromCoinEntity.id },
      relations: ['coin'],
    });
    const toWallet = await this.walletRepository.findOne({
      where: { userId, coinId: toCoinEntity.id },
      relations: ['coin'],
    });

    if (!fromWallet || !toWallet) {
      throw new BadRequestException({
        status: 'error',
        message: 'Wallet not found.',
      });
    }

    const amount = dto.amount;
    const available =
      parseFloat(fromWallet.balance) - parseFloat(fromWallet.lockedBalance || '0');
    if (amount > available) {
      throw new BadRequestException({
        status: 'error',
        message: 'Insufficient balance.',
      });
    }

    const idempotencyKey = this.generateSwapIdempotencyKey(userId, fromCoin, toCoin, amount);

    const prices = await this.priceService.getCoinPrices([fromCoin, toCoin]);
    const fromPrice = prices[fromCoin] ?? 1;
    const toPrice = prices[toCoin] ?? 1;
    const swapFeePercent = await this.systemSettingsService.getSwapFeePercent();
    const exchangeRate = toPrice / fromPrice;
    const omlapayFee = (amount * fromPrice * swapFeePercent) / toPrice;

    this.assertBinanceKeys(user);

    const symbol = this.getTradingPair(fromCoin, toCoin);
    const isBuyingToCoin = isStablecoin(fromCoin);
    const isTwoLeg = this.isTwoLegSwap(fromCoin, toCoin);

    let toAmount = 0;
    let binanceOrderId: string | null = null;

    try {
      if (isTwoLeg) {
        const fromSymbol = `${fromCoin}USDT`;
        const toSymbol = `${toCoin}USDT`;
        const leg1 = await this.tradeService.placeMarketOrder(
          user.binanceApiKey!,
          user.binanceSecretKey!,
          { symbol: fromSymbol, side: 'SELL', quantity: String(amount) },
        );
        const usdtReceived = parseFloat(leg1.cummulativeQuoteQty || '0');
        const leg2 = await this.tradeService.placeMarketOrder(
          user.binanceApiKey!,
          user.binanceSecretKey!,
          { symbol: toSymbol, side: 'BUY', quoteOrderQty: String(usdtReceived) },
        );
        toAmount = parseFloat(leg2.executedQty || '0');
        binanceOrderId = leg2.orderId;
      } else if (isBuyingToCoin) {
        const quoteOrderQty = String(amount * fromPrice);
        const result = await this.tradeService.placeMarketOrder(
          user.binanceApiKey!,
          user.binanceSecretKey!,
          { symbol, side: 'BUY', quoteOrderQty },
        );
        toAmount = parseFloat(result.executedQty || '0');
        binanceOrderId = result.orderId;
      } else {
        const quantity = String(amount);
        const result = await this.tradeService.placeMarketOrder(
          user.binanceApiKey!,
          user.binanceSecretKey!,
          { symbol, side: 'SELL', quantity },
        );
        toAmount = parseFloat(result.cummulativeQuoteQty || '0');
        binanceOrderId = result.orderId;
      }

      const finalToAmount = Math.max(0, toAmount - omlapayFee);
      const fee = String(omlapayFee);

      try {
        await this.dataSource.transaction(async (em) => {
          await em.query(
            `UPDATE wallets SET balance = balance - $1::numeric, "updatedAt" = $2 WHERE id = $3`,
            [amount, new Date(), fromWallet.id],
          );
          await em.query(
            `UPDATE wallets SET balance = balance + $1::numeric, "updatedAt" = $2 WHERE id = $3`,
            [finalToAmount, new Date(), toWallet.id],
          );

        const swap = em.create(SwapEntity, {
          userId,
          fromCoinId: fromCoinEntity.id,
          toCoinId: toCoinEntity.id,
          fromAmount: String(amount),
          toAmount: String(finalToAmount),
          exchangeRate: String(exchangeRate),
          fee,
          status: SwapStatus.COMPLETED,
          idempotencyKey,
        });
        await em.save(swap);

        await em.save(
          em.create(NotificationEntity, {
            userId,
            type: NotificationType.TX,
            title: 'Swap completed',
            message: `Your swap of ${amount} ${fromCoin} for ${toCoin} has been completed. You received ${finalToAmount.toFixed(toCoinEntity.decimals)} ${toCoin}.`,
            referenceId: swap.id,
            referenceType: NotificationReferenceType.SWAP,
          }),
        );
      });
      } catch (txErr) {
        const errMsg = txErr instanceof Error ? txErr.message : 'Unknown error';
        this.logger.error(
          `[Swap] Binance succeeded but DB transaction failed - manual reconciliation required. ` +
            `userId=${userId} fromCoin=${fromCoin} toCoin=${toCoin} amount=${amount} ` +
            `binanceOrderId=${binanceOrderId} toAmount=${finalToAmount} error=${errMsg}`,
        );
        throw txErr;
      }

      const swapRecord = await this.swapRepository.findOne({
        where: { idempotencyKey },
        relations: ['fromCoin', 'toCoin'],
      });

      return successResponse(
        {
          swapId: swapRecord?.id,
          fromCoin,
          toCoin,
          fromAmount: String(amount),
          toAmount: String(finalToAmount),
          status: SwapStatus.COMPLETED,
          binanceOrderId,
        },
        'Swap completed successfully.',
      );
    } catch (err) {
      const errMsg = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`Swap failed: ${errMsg}`);

      await this.swapRepository.save(
        this.swapRepository.create({
          userId,
          fromCoinId: fromCoinEntity.id,
          toCoinId: toCoinEntity.id,
          fromAmount: String(amount),
          toAmount: '0',
          exchangeRate: String(exchangeRate),
          fee: '0',
          status: SwapStatus.FAILED,
          idempotencyKey,
        }),
      );

      throw new BadRequestException({
        status: 'error',
        message: errMsg || 'Swap failed. Please try again.',
      });
    }
  }

  async getHistory(
    userId: string,
    query: { after?: string; limit?: number },
  ) {
    await this.userKycGuardService.assertUserCanPerformAction(userId, 'swap');

    const { after, limit = 20 } = query;

    const qb = this.swapRepository
      .createQueryBuilder('s')
      .leftJoinAndSelect('s.fromCoin', 'fromCoin')
      .leftJoinAndSelect('s.toCoin', 'toCoin')
      .where('s.userId = :userId', { userId })
      .orderBy('s.createdAt', 'DESC')
      .addOrderBy('s.id', 'DESC');

    if (after) {
      const decoded = decodeCursor(after);
      if (decoded) {
        qb.andWhere(
          '(s.createdAt < :cursorCreatedAt OR (s.createdAt = :cursorCreatedAt AND s.id < :cursorId))',
          { cursorCreatedAt: decoded.timestamp, cursorId: decoded.id },
        );
      }
    }

    const swaps = await qb.take((limit ?? 20) + 1).getMany();
    const hasMore = swaps.length > limit;
    if (hasMore) swaps.pop();

    const items = swaps.map((s) => ({
      id: s.id,
      fromCoin: s.fromCoin.symbol,
      toCoin: s.toCoin.symbol,
      fromAmount: s.fromAmount,
      toAmount: s.toAmount,
      fee: s.fee,
      status: s.status,
      createdAt: s.createdAt,
    }));

    return successResponse({
      items,
      hasMore,
      nextCursor:
        hasMore && items.length > 0
          ? encodeCursor(items[items.length - 1].id, items[items.length - 1].createdAt)
          : null,
    });
  }

  /**
   * Get single swap by ID.
   */
  async getById(userId: string, swapId: string) {
    await this.userKycGuardService.assertUserCanPerformAction(userId, 'swap');

    const swap = await this.swapRepository.findOne({
      where: { id: swapId, userId },
      relations: ['fromCoin', 'toCoin'],
    });

    if (!swap) {
      throw new NotFoundException({
        status: 'error',
        message: 'Swap not found.',
      });
    }

    return successResponse({
      id: swap.id,
      fromCoin: swap.fromCoin.symbol,
      toCoin: swap.toCoin.symbol,
      fromAmount: swap.fromAmount,
      toAmount: swap.toAmount,
      exchangeRate: swap.exchangeRate,
      fee: swap.fee,
      status: swap.status,
      createdAt: swap.createdAt,
    });
  }
}
