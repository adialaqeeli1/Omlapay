import { Injectable, Logger } from '@nestjs/common';
import { createHmac } from 'crypto';

/**
 * Binance order response.
 * @see https://developers.binance.com/docs/binance-spot-api-docs/rest-api#new-order-trade
 */
export interface BinanceOrderResponse {
  orderId: string;
  symbol: string;
  status: string;
  executedQty: string;
  cummulativeQuoteQty: string;
  [key: string]: any;
}

/**
 * Trade service for Binance sub-accounts - places spot market orders.
 * Uses user's sub-account API keys (HMAC-SHA256).
 */
@Injectable()
export class TradeService {
  private readonly logger = new Logger(TradeService.name);

  private getBaseUrl(): string {
    const baseUrl = process.env.BINANCE_API_BASE_URL;
    if (!baseUrl) {
      throw new Error(
        'Missing BINANCE_API_BASE_URL (e.g. https://api.binance.com)',
      );
    }
    return baseUrl.replace(/\/$/, '');
  }

  private signQueryString(queryString: string, secretKey: string): string {
    return createHmac('sha256', secretKey)
      .update(queryString, 'utf8')
      .digest('hex');
  }

  /**
   * Place a market order.
   * @param apiKey - User's Binance sub-account API key
   * @param secretKey - User's Binance sub-account secret key
   * @param symbol - Trading pair (e.g. BTCUSDT)
   * @param side - BUY or SELL
   * @param quantity - Base asset quantity (for SELL) or use quoteOrderQty for BUY with quote amount
   */
  async placeMarketOrder(
    apiKey: string,
    secretKey: string,
    params: {
      symbol: string;
      side: 'BUY' | 'SELL';
      quantity?: string;
      quoteOrderQty?: string;
    },
  ): Promise<BinanceOrderResponse> {
    if (!apiKey || !secretKey) {
      throw new Error('API key and secret key are required');
    }

    const recvWindow = process.env.BINANCE_RECV_WINDOW ?? '60000';
    const requestParams: Record<string, string> = {
      symbol: params.symbol.toUpperCase(),
      side: params.side,
      type: 'MARKET',
      timestamp: String(Date.now()),
      recvWindow,
    };

    if (params.quantity) {
      requestParams.quantity = params.quantity;
    } else if (params.quoteOrderQty) {
      requestParams.quoteOrderQty = params.quoteOrderQty;
    } else {
      throw new Error('quantity or quoteOrderQty is required');
    }

    const queryString = new URLSearchParams(requestParams).toString();
    const signature = this.signQueryString(queryString, secretKey);
    const body = `${queryString}&signature=${signature}`;

    const url = `${this.getBaseUrl()}/api/v3/order`;

    try {
      const res = await fetch(url, {
        method: 'POST',
        headers: {
          'X-MBX-APIKEY': apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body,
      });

      const rawBody = await res.text();
      let parsed: any = null;
      try {
        parsed = rawBody ? JSON.parse(rawBody) : null;
      } catch {
        this.logger.error(
          `[Trade] Invalid JSON response: ${rawBody.slice(0, 200)}`,
        );
        throw new Error('Invalid response from Binance');
      }

      if (!res.ok) {
        const msg =
          parsed?.msg ??
          parsed?.message ??
          rawBody?.slice(0, 300) ??
          res.statusText;
        this.logger.error(
          `[Trade] Binance API error (${res.status}): ${msg}`,
        );
        throw new Error(`Binance API (${res.status}): ${msg}`);
      }

      return parsed;
    } catch (error) {
      if (error instanceof Error) {
        this.logger.error(
          `[Trade] Failed for ${params.symbol}: ${error.message}`,
        );
        throw error;
      }
      throw error;
    }
  }
}
