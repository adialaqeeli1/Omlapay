import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { randomBytes } from 'crypto';
import { TrustedDeviceEntity } from '@common/database/model';
import { generateHash } from '@common/filters';

/** How long a remembered device can log in with the passcode alone */
export const DEVICE_TOKEN_EXPIRY_DAYS = 30;

export interface IssuedDeviceToken {
  device_token: string;
  device_token_expires_in: number;
}

/**
 * Remembered devices: issued only after the user proved their number by SMS on that phone.
 * The token is bound to the user (and to the device_id the app sent, if any), expires after
 * DEVICE_TOKEN_EXPIRY_DAYS and is revoked by logout, logout-all and forgot-passcode reset.
 */
@Injectable()
export class TrustedDeviceService {
  constructor(
    @InjectRepository(TrustedDeviceEntity)
    private readonly repo: Repository<TrustedDeviceEntity>,
  ) {}

  async issue(
    userId: string,
    deviceId?: string | null,
  ): Promise<{ id: string; token: IssuedDeviceToken }> {
    const token = randomBytes(32).toString('base64url');
    const expiresIn = DEVICE_TOKEN_EXPIRY_DAYS * 24 * 60 * 60;
    const device = await this.repo.save({
      userId,
      tokenHash: generateHash(token),
      deviceId: deviceId || null,
      expiresAt: new Date(Date.now() + expiresIn * 1000),
      lastUsedAt: null,
      revokedAt: null,
    });
    return {
      id: device.id,
      token: { device_token: token, device_token_expires_in: expiresIn },
    };
  }

  /** The user's remembered device for this token, or null if unknown, expired, revoked or another device. */
  async find(
    userId: string,
    token: string | undefined,
    deviceId?: string | null,
  ): Promise<TrustedDeviceEntity | null> {
    if (!token) return null;
    const device = await this.repo.findOne({
      where: { tokenHash: generateHash(token), userId, revokedAt: IsNull() },
    });
    if (!device || device.expiresAt <= new Date()) return null;
    if (device.deviceId && device.deviceId !== deviceId) return null;
    return device;
  }

  async markUsed(id: string): Promise<void> {
    await this.repo.update({ id }, { lastUsedAt: new Date() });
  }

  async revoke(id: string): Promise<void> {
    await this.repo.update(
      { id, revokedAt: IsNull() },
      { revokedAt: new Date() },
    );
  }

  async revokeAllForUser(userId: string): Promise<void> {
    await this.repo.update(
      { userId, revokedAt: IsNull() },
      { revokedAt: new Date() },
    );
  }
}
