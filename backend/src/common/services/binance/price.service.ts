import { Injectable, Logger } from '@nestjs/common';

/**
 * Currency codes supported for conversion
 */
export enum Currency {
  USD = 'usd',
  SAR = 'sar',
}

/**
 * Binance API response structure for 24hr ticker
 */
interface BinanceTicker24hrResponse {
  symbol: string;
  priceChange: string;
  priceChangePercent: string;
  weightedAvgPrice: string;
  prevClosePrice: string;
  lastPrice: string;
  bidPrice: string;
  askPrice: string;
  openPrice: string;
  highPrice: string;
  lowPrice: string;
  volume: string;
  quoteVolume: string;
  openTime: number;
  closeTime: number;
  firstId: number;
  lastId: number;
  count: number;
}

/**
 * Exchange rate API response structure (for USD/SAR conversion)
 */
interface ExchangeRateResponse {
  rates?: {
    SAR?: number;
  };
  result?: string;
  conversion_rate?: number;
}

/**
 * Mapping from coin symbols to Binance trading pairs (USDT pairs)
 * Note: USDT and USDC are stablecoins, so they're handled specially
 */
const COIN_TO_BINANCE_SYMBOL: Record<string, string> = {
  BTC: 'BTCUSDT',
  ETH: 'ETHUSDT',
  SOL: 'SOLUSDT',
  USDC: 'USDCUSDT',
  BNB: 'BNBUSDT',
  // USDT is not mapped - handled as stablecoin (price = 1 USD)
};

/**
 * Price service for fetching cryptocurrency prices and currency conversion.
 * Uses Binance public API for prices (no authentication required).
 * Uses free public exchange rate API for USD/SAR conversion.
 */
@Injectable()
export class PriceService {
  private readonly logger = new Logger(PriceService.name);
  private readonly BINANCE_API_BASE_URL = 'https://api.binance.com';
  private readonly EXCHANGE_RATE_API_BASE_URL = 'https://api.exchangerate.host';

  /**
   * Get Binance trading symbol for a coin symbol.
   * @param coinSymbol - Coin symbol (e.g., 'BTC', 'ETH', 'USDT')
   * @returns Binance trading pair symbol (e.g., 'BTCUSDT')
   */
  private getBinanceSymbol(coinSymbol: string): string | null {
    const symbol = coinSymbol.toUpperCase();
    return COIN_TO_BINANCE_SYMBOL[symbol] || null;
  }

  /**
   * Get USD to SAR conversion rate.
   * Uses free public exchange rate API (exchangerate.host).
   * Binance doesn't provide fiat-to-fiat exchange rates.
   * @returns Conversion rate (1 USD = X SAR)
   */
  async getUsdToSarRate(): Promise<number> {
    try {
      // Fetch USD to SAR rate from free public API
      // Using exchangerate.host which provides free exchange rates without API key
      const response = await fetch(
        `${this.EXCHANGE_RATE_API_BASE_URL}/convert?from=USD&to=SAR`,
      );

      if (!response.ok) {
        this.logger.warn(
          `Failed to fetch USD/SAR rate: ${response.statusText}. Using default rate 3.75`,
        );
        return 3.75; // Fallback rate (approximate)
      }

      const data: ExchangeRateResponse = await response.json();
      
      // Check for conversion_rate field (exchangerate.host format)
      let sarRate: number | undefined;
      if (data.conversion_rate && typeof data.conversion_rate === 'number') {
        sarRate = data.conversion_rate;
      } else if (data.rates?.SAR && typeof data.rates.SAR === 'number') {
        sarRate = data.rates.SAR;
      } else if (data.result && typeof data.result === 'string') {
        // Some APIs return the rate as a string in result field
        sarRate = parseFloat(data.result);
      }

      if (!sarRate || isNaN(sarRate) || sarRate <= 0) {
        this.logger.warn(
          'Invalid USD/SAR rate from exchange rate API. Using default rate 3.75',
        );
        return 3.75; // Fallback rate
      }

      return sarRate;
    } catch (error) {
      this.logger.error(
        `Error fetching USD/SAR rate: ${(error as Error).message}. Using default rate 3.75`,
      );
      return 3.75; // Fallback rate
    }
  }

  /**
   * Get coin prices from Binance API.
   * Note: This method expects coin symbols (e.g., 'BTC', 'ETH') not coinGeckoIds.
   * @param coinSymbols - Array of coin symbols (e.g., ['BTC', 'ETH'])
   * @param currency - Target currency (USD or SAR). Prices are fetched in USDT (≈USD).
   * @returns Map of coinSymbol to price in target currency
   */
  async getCoinPrices(
    coinSymbols: string[],
    currency: Currency = Currency.USD,
  ): Promise<Record<string, number>> {
    if (coinSymbols.length === 0) {
      return {};
    }

    try {
      const prices: Record<string, number> = {};
      const usdToSarRate =
        currency === Currency.SAR ? await this.getUsdToSarRate() : null;

      // Fetch prices for each coin symbol
      for (const coinSymbol of coinSymbols) {
        const binanceSymbol = this.getBinanceSymbol(coinSymbol);

        // Handle stablecoins (USDT, USDC) - price is approximately 1 USD
        if (coinSymbol.toUpperCase() === 'USDT' || coinSymbol.toUpperCase() === 'USDC') {
          const usdPrice = 1.0;
          prices[coinSymbol] =
            currency === Currency.SAR && usdToSarRate
              ? this.convertUsdToSar(usdPrice, usdToSarRate)
              : usdPrice;
          continue;
        }

        if (!binanceSymbol) {
          this.logger.warn(
            `No Binance symbol mapping found for ${coinSymbol}. Skipping.`,
          );
          continue;
        }

        try {
          // Fetch 24hr ticker from Binance (public endpoint, no auth required)
          const response = await fetch(
            `${this.BINANCE_API_BASE_URL}/api/v3/ticker/24hr?symbol=${binanceSymbol}`,
          );

          if (!response.ok) {
            this.logger.warn(
              `Failed to fetch price for ${coinSymbol} (${binanceSymbol}): ${response.statusText}`,
            );
            continue;
          }

          const ticker: BinanceTicker24hrResponse = await response.json();
          const usdPrice = parseFloat(ticker.lastPrice);

          if (isNaN(usdPrice)) {
            this.logger.warn(
              `Invalid price for ${coinSymbol} (${binanceSymbol}): ${ticker.lastPrice}`,
            );
            continue;
          }

          // Convert to target currency
          prices[coinSymbol] =
            currency === Currency.SAR && usdToSarRate
              ? this.convertUsdToSar(usdPrice, usdToSarRate)
              : usdPrice;
        } catch (error) {
          this.logger.warn(
            `Error fetching price for ${coinSymbol}: ${(error as Error).message}`,
          );
        }
      }

      return prices;
    } catch (error) {
      this.logger.error(
        `Error fetching coin prices: ${(error as Error).message}. Returning empty prices.`,
      );
      return {};
    }
  }

  /**
   * Convert price from USD to SAR.
   * @param usdPrice - Price in USD
   * @param usdToSarRate - USD to SAR conversion rate
   * @returns Price in SAR
   */
  convertUsdToSar(usdPrice: number, usdToSarRate: number): number {
    return usdPrice * usdToSarRate;
  }

  /**
   * Get coin prices with 24-hour change percentage from Binance API.
   * Note: This method expects coin symbols (e.g., 'BTC', 'ETH') not coinGeckoIds.
   * @param coinSymbols - Array of coin symbols (e.g., ['BTC', 'ETH'])
   * @param currency - Target currency (USD or SAR). Prices are fetched in USDT (≈USD).
   * @returns Map of coinSymbol to price and 24h change percentage
   */
  async getCoinPricesWith24hChange(
    coinSymbols: string[],
    currency: Currency = Currency.USD,
  ): Promise<Record<string, { price: number; change24h: number | null }>> {
    if (coinSymbols.length === 0) {
      return {};
    }

    try {
      const prices: Record<string, { price: number; change24h: number | null }> = {};
      const usdToSarRate =
        currency === Currency.SAR ? await this.getUsdToSarRate() : null;

      // Fetch prices for each coin symbol
      for (const coinSymbol of coinSymbols) {
        const binanceSymbol = this.getBinanceSymbol(coinSymbol);

        // Handle stablecoins (USDT, USDC) - price is approximately 1 USD, change is ~0
        if (coinSymbol.toUpperCase() === 'USDT' || coinSymbol.toUpperCase() === 'USDC') {
          const usdPrice = 1.0;
          prices[coinSymbol] = {
            price:
              currency === Currency.SAR && usdToSarRate
                ? this.convertUsdToSar(usdPrice, usdToSarRate)
                : usdPrice,
            change24h: 0.0, // Stablecoins typically have minimal change
          };
          continue;
        }

        if (!binanceSymbol) {
          this.logger.warn(
            `No Binance symbol mapping found for ${coinSymbol}. Skipping.`,
          );
          continue;
        }

        try {
          // Fetch 24hr ticker from Binance (public endpoint, no auth required)
          const response = await fetch(
            `${this.BINANCE_API_BASE_URL}/api/v3/ticker/24hr?symbol=${binanceSymbol}`,
          );

          if (!response.ok) {
            this.logger.warn(
              `Failed to fetch price for ${coinSymbol} (${binanceSymbol}): ${response.statusText}`,
            );
            continue;
          }

          const ticker: BinanceTicker24hrResponse = await response.json();
          const usdPrice = parseFloat(ticker.lastPrice);
          const change24h = parseFloat(ticker.priceChangePercent);

          if (isNaN(usdPrice)) {
            this.logger.warn(
              `Invalid price for ${coinSymbol} (${binanceSymbol}): ${ticker.lastPrice}`,
            );
            continue;
          }

          // Convert to target currency
          const finalPrice =
            currency === Currency.SAR && usdToSarRate
              ? this.convertUsdToSar(usdPrice, usdToSarRate)
              : usdPrice;

          prices[coinSymbol] = {
            price: finalPrice,
            change24h: isNaN(change24h) ? null : change24h,
          };
        } catch (error) {
          this.logger.warn(
            `Error fetching price for ${coinSymbol}: ${(error as Error).message}`,
          );
        }
      }

      return prices;
    } catch (error) {
      this.logger.error(
        `Error fetching coin prices with 24h change: ${(error as Error).message}. Returning empty prices.`,
      );
      return {};
    }
  }

  /**
   * Get coin prices in both USD and SAR.
   * Note: This method expects coin symbols (e.g., 'BTC', 'ETH') not coinGeckoIds.
   * @param coinSymbols - Array of coin symbols (e.g., ['BTC', 'ETH'])
   * @returns Object with USD prices, SAR prices, and conversion rate
   */
  async getCoinPricesWithConversion(
    coinSymbols: string[],
  ): Promise<{
    usdPrices: Record<string, number>;
    sarPrices: Record<string, number>;
    usdToSarRate: number;
  }> {
    // Fetch USD prices and conversion rate in parallel
    const [usdPrices, usdToSarRate] = await Promise.all([
      this.getCoinPrices(coinSymbols, Currency.USD),
      this.getUsdToSarRate(),
    ]);

    // Convert USD prices to SAR
    const sarPrices: Record<string, number> = {};
    for (const [coinSymbol, usdPrice] of Object.entries(usdPrices)) {
      sarPrices[coinSymbol] = this.convertUsdToSar(usdPrice, usdToSarRate);
    }

    return {
      usdPrices,
      sarPrices,
      usdToSarRate,
    };
  }

  /**
   * Get single coin price with 24-hour change percentage and currency conversion.
   * Note: This method expects coin symbol (e.g., 'BTC', 'ETH') not coinGeckoId.
   * @param coinSymbol - Coin symbol (e.g., 'BTC', 'ETH', 'USDT')
   * @param currency - Target currency (USD or SAR)
   * @returns Price, 24h change percentage, and conversion rate (if SAR)
   */
  async getCoinPriceWith24hChange(
    coinSymbol: string,
    currency: Currency = Currency.USD,
  ): Promise<{
    price: number;
    change24h: number | null;
    usdToSarRate?: number;
  }> {
    if (currency === Currency.SAR) {
      // Fetch USD price with 24h change and conversion rate
      const [usdData, usdToSarRate] = await Promise.all([
        this.getCoinPricesWith24hChange([coinSymbol], Currency.USD),
        this.getUsdToSarRate(),
      ]);

      const usdPriceData = usdData[coinSymbol];
      if (!usdPriceData) {
        return { price: 0, change24h: null, usdToSarRate };
      }

      // Convert USD price to SAR (24h change percentage remains the same)
      const sarPrice = this.convertUsdToSar(usdPriceData.price, usdToSarRate);

      return {
        price: sarPrice,
        change24h: usdPriceData.change24h,
        usdToSarRate,
      };
    } else {
      // Fetch USD price with 24h change
      const usdData = await this.getCoinPricesWith24hChange(
        [coinSymbol],
        Currency.USD,
      );
      const priceData = usdData[coinSymbol];

      return {
        price: priceData?.price ?? 0,
        change24h: priceData?.change24h ?? null,
      };
    }
  }
}
