import { createHmac, randomBytes, createCipheriv, createDecipheriv } from 'crypto';

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
   * AES-256-GCM encryption key from env. Must be exactly 64 hex chars (32 bytes).
   * Generate with: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   */
  private static getEncryptionKey(): Buffer {
    const hex = process.env.FIELD_ENCRYPTION_KEY;
    if (!hex || hex.length !== 64) {
      throw new Error(
        'FIELD_ENCRYPTION_KEY must be set to a 64-char hex string (32 bytes). ' +
        'Generate with: node -e "console.log(require(\'crypto\').randomBytes(32).toString(\'hex\'))"',
      );
    }
    return Buffer.from(hex, 'hex');
  }

  /**
   * Encrypt a plaintext string with AES-256-GCM.
   * @returns `iv:authTag:ciphertext` (all base64)
   */
  static encryptField(plaintext: string): string {
    const key = CryptoUtil.getEncryptionKey();
    const iv = randomBytes(12);
    const cipher = createCipheriv('aes-256-gcm', key, iv);
    const encrypted = Buffer.concat([
      cipher.update(plaintext, 'utf8'),
      cipher.final(),
    ]);
    const authTag = cipher.getAuthTag();
    return `${iv.toString('base64')}:${authTag.toString('base64')}:${encrypted.toString('base64')}`;
  }

  /**
   * Decrypt an AES-256-GCM ciphertext produced by encryptField.
   * @param ciphertext - Format: `iv:authTag:encrypted` (all base64)
   */
  static decryptField(ciphertext: string): string {
    const parts = ciphertext.split(':');
    if (parts.length !== 3) {
      throw new Error('Invalid encrypted field format');
    }
    const [ivB64, authTagB64, encryptedB64] = parts;
    const key = CryptoUtil.getEncryptionKey();
    const iv = Buffer.from(ivB64, 'base64');
    const authTag = Buffer.from(authTagB64, 'base64');
    const encrypted = Buffer.from(encryptedB64, 'base64');
    const decipher = createDecipheriv('aes-256-gcm', key, iv);
    decipher.setAuthTag(authTag);
    return Buffer.concat([
      decipher.update(encrypted),
      decipher.final(),
    ]).toString('utf8');
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
