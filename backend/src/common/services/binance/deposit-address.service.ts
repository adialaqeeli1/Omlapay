import { Injectable, Logger } from '@nestjs/common';
import { createHmac } from 'crypto';

/**
 * Response from Binance deposit address API.
 * @see https://developers.binance.com/docs/wallet/capital/deposite-address
 */
export interface BinanceDepositAddressResponse {
  address: string;
  coin: string;
  tag: string;
  url: string;
}

/**
 * Fetches deposit addresses for Binance sub-accounts using HMAC-SHA256 signing.
 * Sub-account API keys use standard HMAC (not RSA/Ed25519 used by broker main account).
 */
@Injectable()
export class DepositAddressService {
  private readonly logger = new Logger(DepositAddressService.name);

  private getBaseUrl(): string {
    const baseUrl = process.env.BINANCE_API_BASE_URL;
    if (!baseUrl) {
      throw new Error(
        'Missing BINANCE_API_BASE_URL (e.g. https://api.binance.com)',
      );
    }
    return baseUrl.replace(/\/$/, '');
  }

  /**
   * Create HMAC-SHA256 signature for Binance API (sub-account keys).
   * Binance expects hex-encoded signature.
   */
  private signQueryString(queryString: string, secretKey: string): string {
    return createHmac('sha256', secretKey)
      .update(queryString, 'utf8')
      .digest('hex');
  }

  /**
   * Fetch deposit address for a coin on a specific network.
   * Uses the user's sub-account API key and secret for HMAC-SHA256 signing.
   *
   * @param apiKey - User's Binance sub-account API key
   * @param secretKey - User's Binance sub-account secret key
   * @param coin - Coin symbol (e.g. BTC, ETH, USDT)
   * @param network - Network (e.g. BTC, ETH, TRX, BNB, SOL). If omitted, returns default network.
   * @returns Deposit address response from Binance
   */
  async getDepositAddress(
    apiKey: string,
    secretKey: string,
    coin: string,
    network?: string,
  ): Promise<BinanceDepositAddressResponse> {
    if (!apiKey || !secretKey) {
      throw new Error('API key and secret key are required');
    }

    const recvWindow = process.env.BINANCE_RECV_WINDOW ?? '5000';
    const params: Record<string, string> = {
      coin: coin.toUpperCase(),
      timestamp: String(Date.now()),
      recvWindow,
    };

    if (network) {
      params.network = network.toUpperCase();
    }

    const queryString = new URLSearchParams(params).toString();
    const signature = this.signQueryString(queryString, secretKey);
    const signedQuery = `${queryString}&signature=${signature}`;

    const url = `${this.getBaseUrl()}/sapi/v1/capital/deposit/address?${signedQuery}`;

    try {
      const res = await fetch(url, {
        method: 'GET',
        headers: {
          'X-MBX-APIKEY': apiKey,
        },
      });

      const rawBody = await res.text();
      let parsed: any = null;
      try {
        parsed = rawBody ? JSON.parse(rawBody) : null;
      } catch {
        this.logger.error(
          `[DepositAddress] Invalid JSON response: ${rawBody.slice(0, 200)}`,
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
          `[DepositAddress] Binance API error (${res.status}): ${msg}`,
        );
        throw new Error(`Binance API (${res.status}): ${msg}`);
      }

      if (!parsed?.address) {
        throw new Error('No address in Binance response');
      }

      return {
        address: parsed.address,
        coin: parsed.coin ?? coin,
        tag: parsed.tag ?? '',
        url: parsed.url ?? '',
      };
    } catch (error) {
      if (error instanceof Error) {
        this.logger.error(
          `[DepositAddress] Failed to fetch address for ${coin}/${network ?? 'default'}: ${error.message}`,
        );
        throw error;
      }
      throw error;
    }
  }
}
