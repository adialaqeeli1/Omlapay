import { Injectable, Logger } from '@nestjs/common';

/** LOT_SIZE filter from Binance exchangeInfo */
interface LotSizeFilter {
  filterType: 'LOT_SIZE';
  minQty: string;
  maxQty: string;
  stepSize: string;
}

/** MIN_NOTIONAL filter (or NOTIONAL for newer API) */
interface MinNotionalFilter {
  filterType: 'MIN_NOTIONAL' | 'NOTIONAL';
  minNotional?: string;
  notional?: string;
  applyToMarket?: boolean;
  avgPriceMins?: number;
}

/** Symbol filters for swap validation */
export interface SymbolFilters {
  minQty: number;
  maxQty: number;
  minNotional: number;
  stepSize: number;
}

/**
 * Fetches Binance exchange info (public endpoint, no auth).
 * Used for swap min/max validation.
 */
@Injectable()
export class ExchangeInfoService {
  private readonly logger = new Logger(ExchangeInfoService.name);

  private getBaseUrl(): string {
    const baseUrl = process.env.BINANCE_API_BASE_URL;
    return baseUrl?.replace(/\/$/, '') ?? 'https://api.binance.com';
  }

  /**
   * Get symbol filters (LOT_SIZE, MIN_NOTIONAL) for a trading pair.
   * Used to validate swap amounts against Binance limits.
   */
  async getSymbolFilters(symbol: string): Promise<SymbolFilters | null> {
    const sym = symbol.toUpperCase();
    try {
      const url = `${this.getBaseUrl()}/api/v3/exchangeInfo?symbol=${sym}`;
      const res = await fetch(url);

      if (!res.ok) {
        this.logger.warn(
          `[ExchangeInfo] Failed to fetch ${sym}: ${res.status} ${res.statusText}`,
        );
        return null;
      }

      const data = (await res.json()) as {
        symbols?: Array<{
          symbol: string;
          filters?: Array<LotSizeFilter | MinNotionalFilter>;
        }>;
      };

      const symbolInfo = data.symbols?.[0];
      if (!symbolInfo?.filters?.length) {
        return null;
      }

      const lotSize = symbolInfo.filters.find(
        (f): f is LotSizeFilter => f.filterType === 'LOT_SIZE',
      );
      const minNotionalFilter = symbolInfo.filters.find(
        (f): f is MinNotionalFilter =>
          f.filterType === 'MIN_NOTIONAL' || f.filterType === 'NOTIONAL',
      );

      const minQty = lotSize ? parseFloat(lotSize.minQty) : 0;
      const maxQty = lotSize ? parseFloat(lotSize.maxQty) : Number.MAX_SAFE_INTEGER;
      const stepSize = lotSize ? parseFloat(lotSize.stepSize) : 0.00000001;
      const minNotionalRaw =
        minNotionalFilter?.minNotional ??
        minNotionalFilter?.notional ??
        '0';
      const minNotional = parseFloat(minNotionalRaw) || 0;

      return {
        minQty,
        maxQty,
        minNotional,
        stepSize,
      };
    } catch (err) {
      this.logger.warn(
        `[ExchangeInfo] Error fetching ${sym}: ${(err as Error).message}`,
      );
      return null;
    }
  }
}
