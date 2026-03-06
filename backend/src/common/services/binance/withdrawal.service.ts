import { Injectable, Logger } from '@nestjs/common';
import { createHmac } from 'crypto';

/**
 * Binance withdrawal response.
 * @see https://developers.binance.com/docs/wallet/capital/withdraw
 */
export interface BinanceWithdrawResponse {
  id: string;
  msg: string;
  success?: boolean;
}

/**
 * Withdrawal service for Binance sub-accounts using HMAC-SHA256 signing.
 * Uses user's sub-account API keys (same as DepositAddressService).
 */
@Injectable()
export class WithdrawalService {
  private readonly logger = new Logger(WithdrawalService.name);

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
   * Initiate withdrawal from user's Binance sub-account to external address.
   *
   * @param apiKey - User's Binance sub-account API key
   * @param secretKey - User's Binance sub-account secret key
   * @param coin - Coin symbol (e.g. BTC, ETH, USDT)
   * @param network - Network (e.g. BTC, ETH, TRX, BNB, SOL)
   * @param address - Destination wallet address
   * @param amount - Amount to withdraw (string for precision)
   * @param addressTag - Optional memo/tag for networks that require it
   */
  async withdraw(
    apiKey: string,
    secretKey: string,
    params: {
      coin: string;
      network: string;
      address: string;
      amount: string;
      addressTag?: string;
    },
  ): Promise<BinanceWithdrawResponse> {
    if (!apiKey || !secretKey) {
      throw new Error('API key and secret key are required');
    }

    const recvWindow = process.env.BINANCE_RECV_WINDOW ?? '60000';
    const requestParams: Record<string, string> = {
      coin: params.coin.toUpperCase(),
      network: params.network.toUpperCase(),
      address: params.address,
      amount: params.amount,
      timestamp: String(Date.now()),
      recvWindow,
    };

    if (params.addressTag) {
      requestParams.addressTag = params.addressTag;
    }

    const queryString = new URLSearchParams(requestParams).toString();
    const signature = this.signQueryString(queryString, secretKey);
    const body = `${queryString}&signature=${signature}`;

    const url = `${this.getBaseUrl()}/sapi/v1/capital/withdraw/apply`;

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
          `[Withdrawal] Invalid JSON response: ${rawBody.slice(0, 200)}`,
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
          `[Withdrawal] Binance API error (${res.status}): ${msg}`,
        );
        throw new Error(`Binance API (${res.status}): ${msg}`);
      }

      return {
        id: parsed?.id ?? parsed?.withdrawId ?? '',
        msg: parsed?.msg ?? 'Success',
        success: parsed?.success ?? true,
      };
    } catch (error) {
      if (error instanceof Error) {
        this.logger.error(
          `[Withdrawal] Failed for ${params.coin}/${params.network}: ${error.message}`,
        );
        throw error;
      }
      throw error;
    }
  }
}
