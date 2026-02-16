import { createHmac } from 'crypto';

/**
 * Shared crypto utilities for HMAC signatures and token generation.
 */
export class CryptoUtil {
  /**
   * Create HMAC signature (hex format).
   */
  static createHmacSignature(
    data: string,
    secret: string,
    algorithm: 'sha256' | 'sha1' = 'sha256',
  ): string {
    return createHmac(algorithm, secret).update(data, 'utf8').digest('hex');
  }

  /**
   * Verify HMAC signature (constant-time comparison).
   */
  static verifyHmacSignature(
    data: string,
    receivedSignature: string,
    secret: string,
    algorithm: 'sha256' | 'sha1' = 'sha256',
  ): boolean {
    const computed = CryptoUtil.createHmacSignature(data, secret, algorithm);
    return receivedSignature === computed;
  }

  /**
   * Create a signed token with expiration (base64url + hex signature).
   */
  static createSignedToken(
    payload: Record<string, any>,
    secret: string,
    ttlMs: number,
  ): string {
    const exp = Date.now() + ttlMs;
    const data = Buffer.from(JSON.stringify({ ...payload, exp })).toString('base64url');
    const sig = CryptoUtil.createHmacSignature(data, secret);
    return `${data}.${sig}`;
  }

  /**
   * Verify and decode a signed token.
   */
  static verifySignedToken<T = any>(
    token: string,
    secret: string,
  ): T {
    const [data, sig] = token.split('.');
    if (!data || !sig) throw new Error('Invalid token format');
    
    const expected = CryptoUtil.createHmacSignature(data, secret);
    if (expected !== sig) throw new Error('Invalid token signature');
    
    const payload = JSON.parse(Buffer.from(data, 'base64url').toString('utf8'));
    if (payload.exp < Date.now()) throw new Error('Token expired');
    
    return payload as T;
  }

  /**
   * Convert time string (e.g., "1d", "7d", "1h", "24h", "30m") to seconds.
   * Supports: s (seconds), m (minutes), h (hours), d (days)
   * @param timeString - Time string like "1d", "7d", "1h", "24h", "30m"
   * @returns Number of seconds
   */
  static timeStringToSeconds(timeString: string): number {
    if (!timeString || typeof timeString !== 'string') {
      throw new Error('Invalid time string');
    }

    const match = timeString.match(/^(\d+)([smhd])$/i);
    if (!match) {
      throw new Error(`Invalid time format: ${timeString}. Expected format: "1d", "7d", "1h", "24h", "30m", etc.`);
    }

    const value = parseInt(match[1], 10);
    const unit = match[2].toLowerCase();

    const multipliers: Record<string, number> = {
      s: 1,
      m: 60,
      h: 60 * 60,
      d: 24 * 60 * 60,
    };

    return value * multipliers[unit];
  }
}
