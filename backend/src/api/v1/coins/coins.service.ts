import {
  Injectable,
  InternalServerErrorException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CoinEntity } from '@common/database/model';
import { successResponse, errorResponse } from '@common/utils';
import { PriceService, Currency } from '@common/services/binance/price.service';

@Injectable()
export class CoinsService {
  private readonly logger = new Logger(CoinsService.name);

  constructor(
    @InjectRepository(CoinEntity)
    private coinRepository: Repository<CoinEntity>,
    private priceService: PriceService,
  ) {}

  /**
   * Get supported coins with optional price information.
   * @param currency - Optional currency for prices (USD or SAR). If not provided, prices are not included.
   * @returns List of coins with prices if currency is specified
   */
  async getSupportedCoins(currency?: Currency) {
    try {
      const coins = await this.coinRepository.find({
        where: { isActive: true },
        order: { displayOrder: 'ASC', name: 'ASC' },
      });

      // If currency is specified, fetch prices
      let prices: Record<string, number> = {};
      let usdToSarRate: number | null = null;

      if (currency) {
        // Get coin symbols for coins that are active
        const coinSymbols = coins.map((coin) => coin.symbol);

        if (coinSymbols.length > 0) {
          if (currency === Currency.SAR) {
            // Fetch prices in both USD and SAR for conversion
            const { usdPrices, sarPrices, usdToSarRate: rate } =
              await this.priceService.getCoinPricesWithConversion(coinSymbols);
            prices = sarPrices;
            usdToSarRate = rate;
          } else {
            // Fetch prices in USD
            prices = await this.priceService.getCoinPrices(
              coinSymbols,
              Currency.USD,
            );
          }
        }
      }

      return successResponse({
        coins: coins.map((coin) => {
          const coinData: any = {
            id: coin.id,
            symbol: coin.symbol,
            name: coin.name,
            decimals: coin.decimals,
            network: coin.network,
            iconUrl: coin.iconUrl,
            contractAddress: coin.contractAddress,
            minWithdrawal: coin.minWithdrawal,
            minDeposit: coin.minDeposit,
            withdrawalFee: coin.withdrawalFee,
            description: coin.description,
          };

          // Add price if currency is specified
          if (currency) {
            const price = prices[coin.symbol];
            coinData.price = price !== undefined ? price : null;
            coinData.currency = currency.toUpperCase();
          }

          return coinData;
        }),
        ...(currency === Currency.SAR && usdToSarRate !== null
          ? { usdToSarRate }
          : {}),
      });
    } catch (error) {
      throw new InternalServerErrorException(
        errorResponse('Unable to fetch supported coins.'),
      );
    }
  }

  async syncCoinsFromBinance() {
    try {
      // Coins to sync with complete configurations
      const coinsToSync = [
        {
          symbol: 'BTC',
          name: 'Bitcoin',
          network: 'BTC',
          decimals: 8,
          description: 'Bitcoin is the first decentralized cryptocurrency',
          minWithdrawal: '0.0001',
          minDeposit: '0.0001',
          withdrawalFee: '0.0005',
          displayOrder: 1,
          coinGeckoId: 'bitcoin',
          contractAddress: null,
        },
        {
          symbol: 'ETH',
          name: 'Ethereum',
          network: 'ETH',
          decimals: 18,
          description: 'Ethereum is a decentralized platform for smart contracts',
          minWithdrawal: '0.01',
          minDeposit: '0.01',
          withdrawalFee: '0.005',
          displayOrder: 2,
          coinGeckoId: 'ethereum',
          contractAddress: null,
        },
        {
          symbol: 'SOL',
          name: 'Solana',
          network: 'SOL',
          decimals: 9,
          description: 'Solana is a high-performance blockchain supporting fast transactions',
          minWithdrawal: '0.01',
          minDeposit: '0.01',
          withdrawalFee: '0.01',
          displayOrder: 3,
          coinGeckoId: 'solana',
          contractAddress: null,
        },
        {
          symbol: 'USDT',
          name: 'Tether',
          network: 'TRX',
          decimals: 6,
          description: 'USDT is a stablecoin pegged to the US Dollar',
          minWithdrawal: '10',
          minDeposit: '1',
          withdrawalFee: '1',
          displayOrder: 4,
          coinGeckoId: 'tether',
          contractAddress: 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t', // USDT on Tron
        },
        {
          symbol: 'USDC',
          name: 'USD Coin',
          network: 'TRX',
          decimals: 6,
          description: 'USDC is a fully-backed stablecoin pegged to the US Dollar',
          minWithdrawal: '10',
          minDeposit: '1',
          withdrawalFee: '1',
          displayOrder: 5,
          coinGeckoId: 'usd-coin',
          contractAddress: 'TEkxiTehnzSmSe2XqrBj4w32RUN966rdz8', // USDC on Tron
        },
        {
          symbol: 'BNB',
          name: 'BNB',
          network: 'BNB',
          decimals: 18,
          description: 'BNB is the native cryptocurrency of the BNB Chain',
          minWithdrawal: '0.01',
          minDeposit: '0.01',
          withdrawalFee: '0.005',
          displayOrder: 6,
          coinGeckoId: 'binancecoin',
          contractAddress: null,
        },
      ];

      const updatedCoins: Array<{
        id: string;
        symbol: string;
        name: string;
        decimals: number;
        network: string;
        isActive: boolean;
      }> = [];
      const createdCoins: Array<{
        id: string;
        symbol: string;
        name: string;
        decimals: number;
        network: string;
        isActive: boolean;
      }> = [];

      for (const coinConfig of coinsToSync) {
        // Check if coin already exists
        const existingCoin = await this.coinRepository.findOne({
          where: { symbol: coinConfig.symbol },
        });

        if (existingCoin) {
          // Update existing coin
          existingCoin.name = coinConfig.name;
          existingCoin.decimals = coinConfig.decimals;
          existingCoin.network = coinConfig.network;
          existingCoin.description = coinConfig.description;
          existingCoin.minWithdrawal = coinConfig.minWithdrawal;
          existingCoin.minDeposit = coinConfig.minDeposit;
          existingCoin.withdrawalFee = coinConfig.withdrawalFee;
          existingCoin.displayOrder = coinConfig.displayOrder;
          existingCoin.coinGeckoId = coinConfig.coinGeckoId;
          existingCoin.contractAddress = coinConfig.contractAddress;
          existingCoin.isActive = true;

          await this.coinRepository.save(existingCoin);
          updatedCoins.push({
            id: existingCoin.id,
            symbol: existingCoin.symbol,
            name: existingCoin.name,
            decimals: existingCoin.decimals,
            network: coinConfig.network,
            isActive: existingCoin.isActive,
          });
        } else {
          // Create new coin
          const newCoin = this.coinRepository.create({
            symbol: coinConfig.symbol,
            name: coinConfig.name,
            decimals: coinConfig.decimals,
            network: coinConfig.network,
            description: coinConfig.description,
            minWithdrawal: coinConfig.minWithdrawal,
            minDeposit: coinConfig.minDeposit,
            withdrawalFee: coinConfig.withdrawalFee,
            displayOrder: coinConfig.displayOrder,
            coinGeckoId: coinConfig.coinGeckoId,
            contractAddress: coinConfig.contractAddress,
            isActive: true,
          });

          const savedCoin = await this.coinRepository.save(newCoin);
          createdCoins.push({
            id: savedCoin.id,
            symbol: savedCoin.symbol,
            name: savedCoin.name,
            decimals: savedCoin.decimals,
            network: coinConfig.network,
            isActive: savedCoin.isActive,
          });
        }
      }

      return successResponse(
        {
          created: createdCoins,
          updated: updatedCoins,
        },
        'Coins synced successfully',
      );
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Failed to sync coins';
      return errorResponse('Failed to sync coins', message);
    }
  }

  /**
   * Get a single coin by symbol with optional price and 24h change information.
   * @param symbol - Coin symbol (e.g., 'USDT', 'BTC')
   * @param currency - Optional currency for prices (USD or SAR). If not provided, prices are not included.
   * @returns Coin details with price and 24h change if currency is specified
   */
  async getCoinBySymbol(symbol: string, currency?: Currency) {
    try {
      // Find coin by symbol (case-insensitive)
      const coin = await this.coinRepository.findOne({
        where: { symbol: symbol.toUpperCase(), isActive: true },
      });

      if (!coin) {
        throw new NotFoundException(
          errorResponse(`Coin with symbol '${symbol}' not found.`),
        );
      }

      // Build base coin data
      const coinData: any = {
        id: coin.id,
        symbol: coin.symbol,
        name: coin.name,
        decimals: coin.decimals,
        network: coin.network,
        iconUrl: coin.iconUrl,
        contractAddress: coin.contractAddress,
        minWithdrawal: coin.minWithdrawal,
        minDeposit: coin.minDeposit,
        withdrawalFee: coin.withdrawalFee,
        description: coin.description,
      };

      // If currency is specified, fetch price and 24h change
      if (currency) {
        try {
          const priceData = await this.priceService.getCoinPriceWith24hChange(
            coin.symbol,
            currency,
          );

          coinData.price = priceData.price || null;
          coinData.change24h = priceData.change24h;
          coinData.currency = currency.toUpperCase();

          // Include conversion rate if SAR
          if (currency === Currency.SAR && priceData.usdToSarRate) {
            coinData.usdToSarRate = priceData.usdToSarRate;
          }
        } catch (error) {
          // If price fetch fails, still return coin data without price
          this.logger.warn(
            `Failed to fetch price for ${coin.symbol}: ${(error as Error).message}`,
          );
          coinData.price = null;
          coinData.change24h = null;
          coinData.currency = currency.toUpperCase();
        }
      }

      return successResponse(coinData);
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      throw new InternalServerErrorException(
        errorResponse('Unable to fetch coin details.'),
      );
    }
  }
}

