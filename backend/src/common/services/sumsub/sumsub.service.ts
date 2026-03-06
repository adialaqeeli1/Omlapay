/**
 * Sumsub KYC integration service.
 * - SDK access tokens for client-side WebSDK
 * - Applicant lookup by id or externalUserId (our user id)
 * - Webhook signature verification (HMAC SHA256/SHA1; Sumsub sends alg as "hmac_sha256_hex")
 * Requires: SUMSUB_BASE_URL, SUMSUB_APP_TOKEN, SUMSUB_SECRET_KEY (same key as Dashboard → Webhooks → Secret key).
 */
import { Injectable, Logger } from '@nestjs/common';
import { CryptoUtil } from '@common/utils/crypto.util';
import {
  SumsubAccessTokenResponse,
  SumsubApplicantResponse,
} from './dto/sumsub-webhook.dto';

interface CreateSdkAccessTokenParams {
  userId: string;
  levelName: string;
  email?: string;
  phone?: string;
  ttlInSecs?: number;
}

/** Individual applicant fixedInfo fields (Sumsub cross-validates with documents). */
export interface SumsubFixedInfo {
  firstName?: string;
  lastName?: string;
  dob?: string;
  country?: string;
  nationality?: string;
  addresses?: Array<{ street?: string; town?: string; state?: string; postCode?: string; country?: string }>;
}

/** Result of a Sumsub API call: response + parsed JSON (or null if non-JSON). */
interface SumsubApiResult<T = unknown> {
  ok: boolean;
  status: number;
  json: T | null;
  text: string;
}

@Injectable()
export class SumsubService {
  private readonly logger = new Logger(SumsubService.name);
  private readonly baseUrl = process.env.SUMSUB_BASE_URL;

  private getCredentials(): { appToken: string; secretKey: string } {
    const appToken = process.env.SUMSUB_APP_TOKEN;
    const secretKey = process.env.SUMSUB_SECRET_KEY;
    if (!appToken || !secretKey) {
      throw new Error(
        'Missing Sumsub credentials. Set SUMSUB_APP_TOKEN and SUMSUB_SECRET_KEY in .env (Dashboard → App Tokens / Webhooks → Secret key).',
      );
    }
    return { appToken, secretKey };
  }

  /** HMAC signature for Sumsub API (SHA256 over timestamp+method+path+body). */
  private signRequest(method: string, path: string, ts: number, body?: string): string {
    const { secretKey } = this.getCredentials();
    const payload = `${ts}${method}${path}${body ?? ''}`;
    return CryptoUtil.createHmacSignature(payload, secretKey);
  }

  /**
   * Map Sumsub webhook digest algorithm to Node crypto name.
   * Sumsub sends e.g. "hmac_sha256_hex" or "hmac_sha1_hex"; createHmac() expects "sha256" / "sha1".
   */
  private static digestAlgToNode(algorithm: string): string {
    const raw = (algorithm || 'sha256').toLowerCase();
    if (raw.includes('sha256')) return 'sha256';
    if (raw.includes('sha1')) return 'sha1';
    return raw;
  }

  /**
   * Verify webhook signature. Use raw request body and x-payload-digest / x-payload-digest-alg headers.
   * Secret must match Sumsub Dashboard → Webhooks → Secret key.
   */
  verifyWebhookSignature(
    rawBody: string,
    receivedDigest: string,
    algorithm: string = 'sha256',
  ): boolean {
    const { secretKey } = this.getCredentials();
    const alg = SumsubService.digestAlgToNode(algorithm) as 'sha256' | 'sha1';
    const isValid = CryptoUtil.verifyHmacSignature(rawBody, receivedDigest, secretKey, alg);
    if (!isValid) {
      this.logger.error('Webhook signature mismatch', {
        algorithm: alg,
        received: receivedDigest?.slice(0, 16) + '…',
      });
    }
    return isValid;
  }

  /** Single place for Sumsub API fetch + JSON parse. */
  private async fetchApi<T = unknown>(
    method: string,
    path: string,
    body?: string,
  ): Promise<SumsubApiResult<T>> {
    const { appToken } = this.getCredentials();
    const ts = Math.floor(Date.now() / 1000);
    const signature = this.signRequest(method, path, ts, body);

    const res = await fetch(`${this.baseUrl}${path}`, {
      method,
      headers: {
        'X-App-Token': appToken,
        'X-App-Access-Ts': String(ts),
        'X-App-Access-Sig': signature,
        ...(body ? { 'Content-Type': 'application/json' } : { Accept: 'application/json' }),
      },
      ...(body ? { body } : {}),
    });

    const text = await res.text();
    let json: T | null = null;
    try {
      json = text ? (JSON.parse(text) as T) : null;
    } catch {
      // non-JSON response
    }

    return { ok: res.ok, status: res.status, json, text };
  }

  /** Fetch binary (e.g. document image). Same auth as fetchApi. */
  private async fetchBinary(method: string, path: string): Promise<{ ok: boolean; status: number; buffer: Buffer; contentType: string }> {
    const { appToken } = this.getCredentials();
    const ts = Math.floor(Date.now() / 1000);
    const signature = this.signRequest(method, path, ts);

    const res = await fetch(`${this.baseUrl}${path}`, {
      method,
      headers: {
        'X-App-Token': appToken,
        'X-App-Access-Ts': String(ts),
        'X-App-Access-Sig': signature,
      },
    });
    const buffer = Buffer.from(await res.arrayBuffer());
    const contentType = res.headers.get('content-type') || 'application/octet-stream';
    return { ok: res.ok, status: res.status, buffer, contentType };
  }

  /** Build error message from Sumsub API result. */
  private static apiErrorMessage(
    result: SumsubApiResult,
    context: string,
  ): string {
    const desc =
      result.json &&
      typeof result.json === 'object' &&
      'description' in result.json
        ? (result.json as { description?: string }).description
        : ((result.json as { error?: string; message?: string })?.error ??
          (result.json as { message?: string })?.message ??
          result.text) ||
          result.status.toString();
    return `Sumsub API (${result.status}) ${context}: ${desc}`;
  }

  /**
   * Create SDK access token for the Sumsub WebSDK (client-side flow).
   * levelName must match a level in Dashboard → Settings → Levels.
   */
  async createSdkAccessToken(
    params: CreateSdkAccessTokenParams,
  ): Promise<SumsubAccessTokenResponse> {
    if (!params.levelName) {
      throw new Error(
        'levelName is required. Create a level in Sumsub Dashboard → Settings → Levels.',
      );
    }

    const path = '/resources/accessTokens/sdk';
    const body: Record<string, unknown> = {
      userId: params.userId,
      levelName: params.levelName,
      ttlInSecs: params.ttlInSecs ?? 600,
    };
    if (params.email || params.phone) {
      body.applicantIdentifiers = {
        ...(params.email && { email: params.email }),
        ...(params.phone && { phone: params.phone }),
      };
    }
    const bodyStr = JSON.stringify(body);
    const result = await this.fetchApi<SumsubAccessTokenResponse>('POST', path, bodyStr);

    if (!result.ok) {
      let msg = SumsubService.apiErrorMessage(result, 'create SDK token');
      if (result.status === 404) {
        msg += ' Hint: Create the level in the correct env (Sandbox/Production).';
      }
      if (result.status === 401) {
        msg += ' Hint: Check SUMSUB_APP_TOKEN and SUMSUB_SECRET_KEY match the env.';
      }
      this.logger.error(msg);
      throw new Error(msg);
    }

    this.logger.debug(`SDK token created for user ${params.userId}`);
    return result.json as SumsubAccessTokenResponse;
  }

  /**
   * Get verification levels (Dashboard → Settings → Levels).
   * Used by dev-tools; not required for production KYC flow.
   */
  async getVerificationLevels(): Promise<unknown> {
    const path = '/resources/applicants/-/levels';
    const result = await this.fetchApi('GET', path);

    if (!result.ok) {
      const msg = SumsubService.apiErrorMessage(
        result,
        'get levels',
      ) + ' Create a level in Dashboard → Settings → Levels if needed.';
      this.logger.error(msg);
      throw new Error(msg);
    }

    return result.json ?? { status: result.status, statusText: result.text };
  }

  /**
   * Create applicant with optional fixedInfo. Call before createSdkAccessToken if you want to pre-fill data.
   * levelName must match a level in Dashboard → Settings → Levels.
   */
  async createApplicant(
    externalUserId: string,
    levelName: string,
    opts: { email?: string; phone?: string; fixedInfo?: SumsubFixedInfo } = {},
  ): Promise<SumsubApplicantResponse> {
    const path = `/resources/applicants?levelName=${encodeURIComponent(levelName)}`;
    const body: Record<string, unknown> = { externalUserId };
    if (opts.email) body.email = opts.email;
    if (opts.phone) body.phone = opts.phone;
    if (opts.fixedInfo && Object.keys(opts.fixedInfo).length > 0) {
      body.fixedInfo = opts.fixedInfo;
      this.logger.debug(
        `[SumSub] Create applicant fixedInfo: firstName="${opts.fixedInfo.firstName ?? ''}", lastName="${opts.fixedInfo.lastName ?? ''}"`,
      );
    }
    const bodyStr = JSON.stringify(body);
    const result = await this.fetchApi<SumsubApplicantResponse>('POST', path, bodyStr);

    if (!result.ok) {
      const msg = SumsubService.apiErrorMessage(result, 'create applicant');
      this.logger.error(msg);
      throw new Error(msg);
    }
    this.logger.debug(`Applicant created for externalUserId=${externalUserId}`);
    return result.json as SumsubApplicantResponse;
  }

  /**
   * Update applicant fixedInfo (individual only). Only include fields you want to change.
   * Per https://docs.sumsub.com/reference/change-provided-info-fixedinfo - PATCH overwrites specified fields.
   */
  async updateApplicantFixedInfo(
    applicantId: string,
    fixedInfo: SumsubFixedInfo,
  ): Promise<unknown> {
    if (Object.keys(fixedInfo).length === 0) return {};
    this.logger.debug(
      `[SumSub] PATCH fixedInfo: applicantId=${applicantId}, firstName="${fixedInfo.firstName ?? ''}", lastName="${fixedInfo.lastName ?? ''}"`,
    );
    const path = `/resources/applicants/${encodeURIComponent(applicantId)}/fixedInfo`;
    const bodyStr = JSON.stringify(fixedInfo);
    const result = await this.fetchApi('PATCH', path, bodyStr);

    if (!result.ok) {
      const msg = SumsubService.apiErrorMessage(result, `update fixedInfo for applicant ${applicantId}`);
      this.logger.error(msg);
      throw new Error(msg);
    }
    this.logger.debug(`FixedInfo updated for applicant ${applicantId}`);
    return result.json ?? {};
  }

  /**
   * Get applicant by our internal user id (externalUserId in Sumsub).
   * Path: GET /resources/applicants/{externalUserId}/one
   * @see https://docs.sumsub.com/reference/get-applicant-data-via-externaluserid
   *
   * Note: SumSub returns 400 "Invalid parameters" when applicant does not exist yet (e.g. first-time user).
   * We treat both 400 and 404 as "not found" so the caller can proceed to create the applicant.
   */
  async getApplicantByExternalUserId(
    externalUserId: string,
  ): Promise<SumsubApplicantResponse | null> {
    const path = `/resources/applicants/${encodeURIComponent(externalUserId)}/one`;
    const result = await this.fetchApi<SumsubApplicantResponse>('GET', path);

    if (result.status === 404 || result.status === 400) {
      this.logger.debug(
        `No applicant for externalUserId=${externalUserId} (status ${result.status})`,
      );
      return null;
    }
    if (!result.ok) {
      const msg = SumsubService.apiErrorMessage(result, `get applicant by externalUserId ${externalUserId}`);
      this.logger.error(msg);
      throw new Error(msg);
    }

    return result.json;
  }

  /**
   * Get applicant by Sumsub applicant id (e.g. from webhook or KYC record).
   */
  async getApplicantById(applicantId: string): Promise<SumsubApplicantResponse | null> {
    const path = `/resources/applicants/${encodeURIComponent(applicantId)}/one`;
    const result = await this.fetchApi<SumsubApplicantResponse>('GET', path);

    if (result.status === 404) {
      this.logger.debug(`Applicant not found: ${applicantId}`);
      return null;
    }
    if (!result.ok) {
      const msg = SumsubService.apiErrorMessage(result, `get applicant ${applicantId}`);
      this.logger.error(msg);
      throw new Error(msg);
    }

    return result.json;
  }

  /**
   * List document image metadata for an applicant (for Binance KYC document URLs).
   * @see https://docs.sumsub.com/reference/get-information-about-document-images
   */
  async getApplicantMetadataResources(
    applicantId: string,
  ): Promise<Array<{ id: string; source?: string; idDocDef?: { idDocType?: string } }>> {
    const path = `/resources/applicants/${encodeURIComponent(applicantId)}/metadata/resources`;
    const result = await this.fetchApi<{ items?: Array<{ id: string; source?: string; idDocDef?: { idDocType?: string } }> }>('GET', path);

    if (!result.ok) {
      const msg = SumsubService.apiErrorMessage(result, `get metadata resources ${applicantId}`);
      this.logger.error(msg);
      throw new Error(msg);
    }

    const items = result.json?.items ?? [];
    return items;
  }

  /**
   * Get document image binary (for proxy to Binance). Requires applicant's inspectionId.
   */
  async getInspectionImage(
    inspectionId: string,
    imageId: string,
  ): Promise<{ buffer: Buffer; contentType: string }> {
    const path = `/resources/inspections/${encodeURIComponent(inspectionId)}/resources/${encodeURIComponent(imageId)}`;
    const result = await this.fetchBinary('GET', path);

    if (!result.ok) {
      this.logger.warn(`Sumsub image not found: inspection=${inspectionId} image=${imageId} status=${result.status}`);
      throw new Error(`Sumsub image: ${result.status}`);
    }

    return { buffer: result.buffer, contentType: result.contentType };
  }
}
