import { Injectable, Logger } from '@nestjs/common';
import { createPrivateKey, sign } from 'crypto';
import { CryptoUtil } from '@common/utils/crypto.util';

/** Binance eKYC share-kyc-data: basicInfo (2-alpha country codes, userSubmitIp required). */
export interface BinanceKycBasicInfo {
  firstName: string;
  lastName: string;
  middleName?: string;
  residentialCountry: string; // 2-alpha UPPER
  dob: string; // yyyy-MM-dd
  country: string; // nationality 2-alpha UPPER
  userSubmitIp: string;
  address: string;
  city: string;
  postalCode?: string;
}

/** Binance eKYC share-kyc-data: identityInfo (documentType, image URLs, 2-alpha countries). */
export interface BinanceKycIdentityInfo {
  documentType: string; // ID_CARD, PASSPORT, DRIVING_LICENSE, RESIDENCE_PERMIT
  selectCountry: string;
  frontFileUrl: string;
  backFileUrl?: string;
  faceFileUrl: string;
  firstName: string;
  lastName: string;
  dob: string;
  idType: string;
  idCountry: string;
  nationalityCountry: string;
  idNumber: string;
  idExpiry?: string;
  userSubmitIp: string;
}

export interface BinanceShareKycDataParams {
  entityCustomerId: string; // our user id
  brokerMainAccountId: string;
  brokerSubAccountId: string;
  notifyUrl: string;
  basicInfo: BinanceKycBasicInfo;
  identityInfo: BinanceKycIdentityInfo;
}

@Injectable()
export class BinanceService {
  private readonly logger = new Logger(BinanceService.name);

  /**
   * Create a Binance Link (Broker) sub account.
   * In dev/staging: if BINANCE_DEV_SUBACCOUNT_ID and BINANCE_DEV_SUBACCOUNT_EMAIL are set,
   * returns the pre-created sub-account instead of calling the API (for local testing).
   * @see https://developers.binance.com/docs/binance_link/exchange-link/account
   * POST /sapi/v1/broker/subAccount
   * @param tag - Optional tag for the sub-account (max 32 chars). Pass to receive it in the response.
   */
  async createSubAccount(tag?: string): Promise<{
    subaccountId: string;
    email: string;
    tag: string;
  }> {
    const nodeEnv = (process.env.NODE_ENV || '').toLowerCase();
    const devSubId = process.env.BINANCE_DEV_SUBACCOUNT_ID;
    const devSubEmail = process.env.BINANCE_DEV_SUBACCOUNT_EMAIL;

    if (
      (nodeEnv === 'development' || nodeEnv === 'dev' || nodeEnv === 'staging') &&
      devSubId &&
      devSubEmail
    ) {
      this.logger.log(
        `[Dev] Using pre-created sub-account: ${devSubId} (skipping Binance API call)`,
      );
      return {
        subaccountId: devSubId,
        email: devSubEmail,
        tag: tag ?? '',
      };
    }

    const apiKey = process.env.BINANCE_API_KEY;
    const privateKeyPem = process.env.BINANCE_API_PRIVATE_KEY_PEM;

    if (!apiKey || !privateKeyPem) {
      throw new Error(
        'Missing Binance API credentials. Set BINANCE_API_KEY and BINANCE_API_PRIVATE_KEY_PEM',
      );
    }

    const baseUrl = process.env.BINANCE_API_BASE_URL;
    if (!baseUrl) {
      throw new Error(
        'Missing BINANCE_API_BASE_URL (e.g. https://api.binance.com)',
      );
    }

    const endpoint = '/sapi/v1/broker/subAccount';
    const timestamp = Date.now();

    const params: Record<string, string> = {
      timestamp: String(timestamp),
    };

    if (tag && tag.length > 0) {
      params.tag = tag.length >= 32 ? tag.slice(0, 31) : tag;
    }

    const recvWindow = process.env.BINANCE_RECV_WINDOW;
    if (recvWindow) {
      params.recvWindow = recvWindow;
    }

    // Create signature
    const payload = new URLSearchParams(params).toString();
    
    // Normalize line endings for Ed25519 PKCS#8 PEM key
    const privateKey = privateKeyPem.trim().replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    
    // Create Ed25519 signature using PKCS#8 PEM format
    const key = createPrivateKey(privateKey);
    const buffer = Buffer.from(payload, 'utf8');
    const signature = sign(null, buffer, key).toString('base64');

    const body = new URLSearchParams({ ...params, signature });

    try {
      const res = await fetch(`${baseUrl}${endpoint}`, {
        method: 'POST',
        headers: {
          'X-MBX-APIKEY': apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body,
      });

      const contentType = res.headers.get('content-type') || '';
      const isJson = contentType.toLowerCase().includes('application/json');

      // Always read as text first so we can error with context if parsing fails.
      const rawBody = await res.text();

      let parsed: any | undefined;
      if (isJson) {
        try {
          parsed = JSON.parse(rawBody);
        } catch {
          // Fall through to throw below with a useful message
        }
      }

      if (!res.ok) {
        const msg =
          parsed?.msg ||
          parsed?.message ||
          rawBody?.slice(0, 500) ||
          'Unknown error response';
        throw new Error(
          `Binance API error (${res.status}) content-type="${contentType}": ${msg}`,
        );
      }

      if (!isJson || parsed == null) {
        const location = res.headers.get('location') || '';
        const hint = location ? ` location="${location}"` : '';
        throw new Error(
          `Binance API returned non-JSON response (${res.status}) content-type="${contentType}"${hint}: ${rawBody.slice(
            0,
            500,
          )}`,
        );
      }

      const result = parsed;
      return {
        subaccountId: result.subaccountId,
        email: result.email,
        tag: result.tag,
      };
    } catch (error) {
      this.logger.error('Failed to create Binance sub account', error);
      throw error;
    }
  }

  /**
   * Share KYC data with Binance eKYC (after Sumsub approved).
   * @see https://developers.binance.com/docs/binance_link/kyc-saas/kyc-integration
   * POST /bapi/ekyc/v2/public/ekyc/customer/share-kyc-data
   * X-SHA2-Signature: HMAC-SHA256 of request body (hex).
   */
  async shareKycData(
    params: BinanceShareKycDataParams,
    requestNo: string,
  ): Promise<void> {
    const baseUrl = process.env.BINANCE_KYC_BASE_URL;
    const bizEntityKey = process.env.BINANCE_KYC_BIZ_ENTITY_KEY;
    const secret = process.env.BINANCE_KYC_SECRET;

    if (!baseUrl || !bizEntityKey || !secret) {
      throw new Error(
        'Missing Binance KYC config. Set BINANCE_KYC_BASE_URL, BINANCE_KYC_BIZ_ENTITY_KEY, BINANCE_KYC_SECRET.',
      );
    }

    const body = {
      bizEntityKey,
      requestNo,
      kycInfo: {
        userInfo: {
          bizEntityKey,
          entityCustomerId: params.entityCustomerId,
          brokerMainAccountId: params.brokerMainAccountId,
          brokerSubAccountId: params.brokerSubAccountId,
          notifyUrl: params.notifyUrl,
        },
        basicInfo: {
          firstName: params.basicInfo.firstName,
          lastName: params.basicInfo.lastName,
          ...(params.basicInfo.middleName && {
            middleName: params.basicInfo.middleName,
          }),
          residentialCountry: params.basicInfo.residentialCountry,
          dob: params.basicInfo.dob,
          country: params.basicInfo.country,
          userSubmitIp: params.basicInfo.userSubmitIp,
          address: params.basicInfo.address.slice(0, 400),
          city: params.basicInfo.city.slice(0, 100),
          ...(params.basicInfo.postalCode && {
            postalCode: params.basicInfo.postalCode.slice(0, 50),
          }),
        },
        identityInfo: {
          documentType: params.identityInfo.documentType,
          selectCountry: params.identityInfo.selectCountry,
          frontFileUrl: params.identityInfo.frontFileUrl,
          ...(params.identityInfo.backFileUrl && {
            backFileUrl: params.identityInfo.backFileUrl,
          }),
          faceFileUrl: params.identityInfo.faceFileUrl,
          firstName: params.identityInfo.firstName,
          lastName: params.identityInfo.lastName,
          dob: params.identityInfo.dob,
          idType: params.identityInfo.idType,
          idCountry: params.identityInfo.idCountry,
          nationalityCountry: params.identityInfo.nationalityCountry,
          idNumber: params.identityInfo.idNumber,
          ...(params.identityInfo.idExpiry && {
            idExpiry: params.identityInfo.idExpiry,
          }),
          userSubmitIp: params.identityInfo.userSubmitIp,
        },
      },
    };

    const bodyStr = JSON.stringify(body);
    const signature = CryptoUtil.createHmacSignature(bodyStr, secret);

    const res = await fetch(
      `${baseUrl.replace(/\/$/, '')}/bapi/ekyc/v2/public/ekyc/customer/share-kyc-data`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-SHA2-Signature': signature,
        },
        body: bodyStr,
      },
    );

    const rawBody = await res.text();
    let parsed: any = null;
    try {
      parsed = rawBody ? JSON.parse(rawBody) : null;
    } catch {
      // ignore
    }

    if (!res.ok) {
      const msg =
        parsed?.message ??
        parsed?.messageDetail ??
        rawBody?.slice(0, 300) ??
        res.statusText;
      this.logger.error(`Binance KYC share failed (${res.status}): ${msg}`);
      throw new Error(`Binance KYC API (${res.status}): ${msg}`);
    }

    if (parsed && parsed.success === false) {
      const code = parsed?.code ?? '';
      const msg = parsed?.message ?? parsed?.messageDetail ?? 'Unknown error';
      this.logger.error(`Binance KYC share error: code=${code} ${msg}`);
      throw new Error(`Binance KYC: ${code} ${msg}`);
    }

    this.logger.debug(
      `Binance KYC data shared for entityCustomerId=${params.entityCustomerId}`,
    );
  }

  /**
   * Check KYC status for a user.
   * @see https://developers.binance.com/docs/binance_link/kyc-saas/kyc-querying
   * POST /bapi/ekyc/v2/public/ekyc/customer/check-kyc-status
   */
  async checkKycStatus(
    entityCustomerId: string,
    brokerSubAccountId: string,
  ): Promise<{
    kycStatus: 'PASS' | 'REJECT' | 'REFUSED' | 'PROCESS' | 'INITIAL' | 'REVIEW' | 'DISABLE';
    currentLevel: string;
  }> {
    const baseUrl = process.env.BINANCE_KYC_BASE_URL;
    const bizEntityKey = process.env.BINANCE_KYC_BIZ_ENTITY_KEY;
    const secret = process.env.BINANCE_KYC_SECRET;
    const brokerMainAccountId = process.env.BINANCE_BROKER_MAIN_ACCOUNT_ID;

    if (!baseUrl || !bizEntityKey || !secret || !brokerMainAccountId) {
      throw new Error(
        'Missing Binance KYC config. Set BINANCE_KYC_BASE_URL, BINANCE_KYC_BIZ_ENTITY_KEY, BINANCE_KYC_SECRET, BINANCE_BROKER_MAIN_ACCOUNT_ID.',
      );
    }

    const body = {
      bizEntityKey,
      entityCustomerId,
      kycType: 'USER',
      brokerMainAccountId,
      brokerSubAccountId,
    };

    const bodyStr = JSON.stringify(body);
    const signature = CryptoUtil.createHmacSignature(bodyStr, secret);

    const res = await fetch(
      `${baseUrl.replace(/\/$/, '')}/bapi/ekyc/v2/public/ekyc/customer/check-kyc-status`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-SHA2-Signature': signature,
        },
        body: bodyStr,
      },
    );

    const rawBody = await res.text();
    let parsed: any = null;
    try {
      parsed = rawBody ? JSON.parse(rawBody) : null;
    } catch {
      throw new Error(`Binance KYC check status: Invalid JSON response`);
    }

    if (!res.ok) {
      const msg =
        parsed?.message ??
        parsed?.messageDetail ??
        rawBody?.slice(0, 300) ??
        res.statusText;
      this.logger.error(`Binance KYC check status failed (${res.status}): ${msg}`);
      throw new Error(`Binance KYC check status (${res.status}): ${msg}`);
    }

    if (parsed && parsed.success === false) {
      const code = parsed?.code ?? '';
      const msg = parsed?.message ?? parsed?.messageDetail ?? 'Unknown error';
      this.logger.error(`Binance KYC check status error: code=${code} ${msg}`);
      throw new Error(`Binance KYC check status: ${code} ${msg}`);
    }

    const levelInfo = parsed?.data?.levelInfo;
    const currentLevel = levelInfo?.currentLevel;
    
    if (!currentLevel) {
      throw new Error('Binance KYC check status: No level info in response');
    }

    return {
      kycStatus: currentLevel.kycStatus || 'INITIAL',
      currentLevel: currentLevel.levelName || 'UNKNOWN',
    };
  }

  /**
   * Create API key for a sub-account (after KYC is approved).
   * @see https://developers.binance.com/docs/binance_link/exchange-link/account
   * POST /sapi/v1/broker/subAccountApi
   */
  async createSubAccountApiKey(
    subaccountId: string,
    options: {
      canTrade?: boolean;
      marginTrade?: boolean;
      futuresTrade?: boolean;
    } = {},
  ): Promise<{
    apiKey: string;
    secretKey: string;
    subaccountId: string;
  }> {
    const apiKey = process.env.BINANCE_API_KEY;
    const privateKeyPem = process.env.BINANCE_API_PRIVATE_KEY_PEM;

    if (!apiKey || !privateKeyPem) {
      throw new Error(
        'Missing Binance API credentials. Set BINANCE_API_KEY and BINANCE_API_PRIVATE_KEY_PEM',
      );
    }

    const baseUrl = process.env.BINANCE_API_BASE_URL;
    if (!baseUrl) {
      throw new Error(
        'Missing BINANCE_API_BASE_URL (e.g. https://api.binance.com)',
      );
    }

    const endpoint = '/sapi/v1/broker/subAccountApi';
    const timestamp = Date.now();

    const params: Record<string, string> = {
      subAccountId: subaccountId,
      canTrade: String(options.canTrade ?? true),
      timestamp: String(timestamp),
    };

    if (options.marginTrade !== undefined) {
      params.marginTrade = String(options.marginTrade);
    }
    if (options.futuresTrade !== undefined) {
      params.futuresTrade = String(options.futuresTrade);
    }

    const recvWindow = process.env.BINANCE_RECV_WINDOW;
    if (recvWindow) {
      params.recvWindow = recvWindow;
    }

    const payload = new URLSearchParams(params).toString();
    const privateKey = privateKeyPem.trim().replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    const key = createPrivateKey(privateKey);
    const buffer = Buffer.from(payload, 'utf8');
    const signature = sign(null, buffer, key).toString('base64');

    const body = new URLSearchParams({ ...params, signature });

    try {
      const res = await fetch(`${baseUrl}${endpoint}`, {
        method: 'POST',
        headers: {
          'X-MBX-APIKEY': apiKey,
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
          // Fall through
        }
      }

      if (!res.ok) {
        const msg =
          parsed?.msg ||
          parsed?.message ||
          rawBody?.slice(0, 500) ||
          'Unknown error response';
        throw new Error(
          `Binance API error (${res.status}) content-type="${contentType}": ${msg}`,
        );
      }

      if (!isJson || parsed == null) {
        const location = res.headers.get('location') || '';
        const hint = location ? ` location="${location}"` : '';
        throw new Error(
          `Binance API returned non-JSON response (${res.status}) content-type="${contentType}"${hint}: ${rawBody.slice(
            0,
            500,
          )}`,
        );
      }

      const result = parsed;
      return {
        apiKey: result.apiKey,
        secretKey: result.secretKey,
        subaccountId: result.subaccountId,
      };
    } catch (error) {
      this.logger.error('Failed to create Binance sub-account API key', error);
      throw error;
    }
  }

  /**
   * Link multiple sub-accounts to the same KYC record (one person, multiple accounts).
   * @see https://developers.binance.com/docs/binance_link/kyc-saas/kyc-integration/Link-Multiple-Accounts
   * POST /bapi/ekyc/v2/public/ekyc/customer/add-account-info-list
   */
  async linkMultipleAccounts(
    accountList: Array<{
      entityCustomerId: string;
      brokerMainAccountId: string;
      brokerSubAccountId: string;
    }>,
  ): Promise<void> {
    const baseUrl = process.env.BINANCE_KYC_BASE_URL;
    const bizEntityKey = process.env.BINANCE_KYC_BIZ_ENTITY_KEY;
    const secret = process.env.BINANCE_KYC_SECRET;

    if (!baseUrl || !bizEntityKey || !secret) {
      throw new Error(
        'Missing Binance KYC config. Set BINANCE_KYC_BASE_URL, BINANCE_KYC_BIZ_ENTITY_KEY, BINANCE_KYC_SECRET.',
      );
    }

    if (!accountList.length) {
      throw new Error('accountList must contain at least one entry');
    }

    const body = {
      bizEntityKey,
      accountList: accountList.map((a) => ({
        entityCustomerId: a.entityCustomerId,
        brokerMainAccountId: a.brokerMainAccountId,
        brokerSubAccountId: a.brokerSubAccountId,
      })),
    };

    const bodyStr = JSON.stringify(body);
    const signature = CryptoUtil.createHmacSignature(bodyStr, secret);

    const res = await fetch(
      `${baseUrl.replace(/\/$/, '')}/bapi/ekyc/v2/public/ekyc/customer/add-account-info-list`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-SHA2-Signature': signature,
        },
        body: bodyStr,
      },
    );

    const rawBody = await res.text();
    let parsed: any = null;
    try {
      parsed = rawBody ? JSON.parse(rawBody) : null;
    } catch {
      throw new Error('Binance link accounts: Invalid JSON response');
    }

    if (!res.ok) {
      const msg =
        parsed?.message ??
        parsed?.messageDetail ??
        rawBody?.slice(0, 300) ??
        res.statusText;
      this.logger.error(`Binance link accounts failed (${res.status}): ${msg}`);
      throw new Error(`Binance link accounts (${res.status}): ${msg}`);
    }

    if (parsed && parsed.success === false) {
      const code = parsed?.code ?? '';
      const msg = parsed?.message ?? parsed?.messageDetail ?? 'Unknown error';
      this.logger.error(`Binance link accounts error: code=${code} ${msg}`);
      throw new Error(`Binance link accounts: ${code} ${msg}`);
    }

    this.logger.debug(
      `Binance linked ${accountList.length} account(s) under bizEntityKey=${bizEntityKey}`,
    );
  }

  /**
   * Query existing API key(s) for a sub-account.
   * @see https://developers.binance.com/docs/binance_link/exchange-link/account/Query-Sub-Account-Api-Key
   * GET /sapi/v1/broker/subAccountApi
   */
  async querySubAccountApiKey(
    subaccountId: string,
    subAccountApiKey?: string,
  ): Promise<Array<{
    subaccountId: string;
    apiKey: string;
    canTrade: boolean;
    marginTrade: boolean;
    futuresTrade: boolean;
  }>> {
    const apiKey = process.env.BINANCE_API_KEY;
    const privateKeyPem = process.env.BINANCE_API_PRIVATE_KEY_PEM;

    if (!apiKey || !privateKeyPem) {
      throw new Error(
        'Missing Binance API credentials. Set BINANCE_API_KEY and BINANCE_API_PRIVATE_KEY_PEM',
      );
    }

    const baseUrl = process.env.BINANCE_API_BASE_URL;
    if (!baseUrl) {
      throw new Error(
        'Missing BINANCE_API_BASE_URL (e.g. https://api.binance.com)',
      );
    }

    const endpoint = '/sapi/v1/broker/subAccountApi';
    const timestamp = Date.now();

    const params: Record<string, string> = {
      subAccountId: subaccountId,
      timestamp: String(timestamp),
    };

    if (subAccountApiKey) {
      params.subAccountApiKey = subAccountApiKey;
    }

    const recvWindow = process.env.BINANCE_RECV_WINDOW;
    if (recvWindow) {
      params.recvWindow = recvWindow;
    }

    const payload = new URLSearchParams(params).toString();
    const privateKey = privateKeyPem.trim().replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    const key = createPrivateKey(privateKey);
    const buffer = Buffer.from(payload, 'utf8');
    const signature = sign(null, buffer, key).toString('base64');

    const queryString = new URLSearchParams({ ...params, signature }).toString();

    try {
      const res = await fetch(`${baseUrl}${endpoint}?${queryString}`, {
        method: 'GET',
        headers: {
          'X-MBX-APIKEY': apiKey,
        },
      });

      const contentType = res.headers.get('content-type') || '';
      const isJson = contentType.toLowerCase().includes('application/json');
      const rawBody = await res.text();

      let parsed: any | undefined;
      if (isJson) {
        try {
          parsed = JSON.parse(rawBody);
        } catch {
          // Fall through
        }
      }

      if (!res.ok) {
        const msg =
          parsed?.msg ||
          parsed?.message ||
          rawBody?.slice(0, 500) ||
          'Unknown error response';
        throw new Error(
          `Binance API error (${res.status}) content-type="${contentType}": ${msg}`,
        );
      }

      if (!isJson || parsed == null) {
        throw new Error(
          `Binance API returned non-JSON response (${res.status}) content-type="${contentType}": ${rawBody.slice(0, 500)}`,
        );
      }

      const results = Array.isArray(parsed) ? parsed : [parsed];
      return results.map((r: any) => ({
        subaccountId: r.subaccountId,
        apiKey: r.apiKey,
        canTrade: r.canTrade ?? false,
        marginTrade: r.marginTrade ?? false,
        futuresTrade: r.futuresTrade ?? false,
      }));
    } catch (error) {
      this.logger.error('Failed to query Binance sub-account API key', error);
      throw error;
    }
  }

  /**
   * Get coin information from Binance API
   * @see https://binance-docs.github.io/apidocs/spot/en/#all-coins-39-information-user_data
   * GET /sapi/v1/capital/config/getall
   */
  async getAllCoins(): Promise<Array<{
    coin: string;
    name: string;
    networkList: Array<{
      network: string;
      coin: string;
      withdrawIntegerMultiple: string;
      isDefault: boolean;
      depositEnable: boolean;
      withdrawEnable: boolean;
      depositDesc?: string;
      withdrawDesc?: string;
      name: string;
      resetAddressStatus: boolean;
      addressRegex: string;
      memoRegex: string;
      withdrawFee: string;
      withdrawMin: string;
      withdrawMax: string;
      minConfirm: number;
      unLockConfirm: number;
    }>;
  }>> {
    const apiKey = process.env.BINANCE_API_KEY;
    const privateKeyPem = process.env.BINANCE_API_PRIVATE_KEY_PEM;

    if (!apiKey || !privateKeyPem) {
      throw new Error(
        'Missing Binance API credentials. Set BINANCE_API_KEY and BINANCE_API_PRIVATE_KEY_PEM',
      );
    }

    const baseUrl = process.env.BINANCE_API_BASE_URL;
    if (!baseUrl) {
      throw new Error(
        'Missing BINANCE_API_BASE_URL (e.g. https://api.binance.com)',
      );
    }

    const endpoint = '/sapi/v1/capital/config/getall';
    const timestamp = Date.now();

    const params: Record<string, string> = {
      timestamp: String(timestamp),
    };

    const recvWindow = process.env.BINANCE_RECV_WINDOW;
    if (recvWindow) {
      params.recvWindow = recvWindow;
    }

    const payload = new URLSearchParams(params).toString();
    const privateKey = privateKeyPem.trim().replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    const key = createPrivateKey(privateKey);
    const buffer = Buffer.from(payload, 'utf8');
    const signature = sign(null, buffer, key).toString('base64');

    const queryString = new URLSearchParams({ ...params, signature }).toString();

    try {
      const res = await fetch(`${baseUrl}${endpoint}?${queryString}`, {
        method: 'GET',
        headers: {
          'X-MBX-APIKEY': apiKey,
        },
      });

      const contentType = res.headers.get('content-type') || '';
      const isJson = contentType.toLowerCase().includes('application/json');
      const rawBody = await res.text();

      let parsed: any | undefined;
      if (isJson) {
        try {
          parsed = JSON.parse(rawBody);
        } catch {
          // Fall through
        }
      }

      if (!res.ok) {
        const msg =
          parsed?.msg ||
          parsed?.message ||
          rawBody?.slice(0, 500) ||
          'Unknown error response';
        throw new Error(
          `Binance API error (${res.status}) content-type="${contentType}": ${msg}`,
        );
      }

      if (!isJson || parsed == null) {
        throw new Error(
          `Binance API returned non-JSON response (${res.status}) content-type="${contentType}": ${rawBody.slice(
            0,
            500,
          )}`,
        );
      }

      return parsed as Array<any>;
    } catch (error) {
      this.logger.error('Failed to fetch Binance coins', error);
      throw error;
    }
  }
}
