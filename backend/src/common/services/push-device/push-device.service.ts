import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Not, Repository } from 'typeorm';
import { PushDeviceEntity } from '@common/database/model';

export interface PushDeviceInput {
  deviceToken: string;
  deviceUuid: string;
  deviceModel: string;
}

/** Push-notification devices (FCM tokens) of each user. */
@Injectable()
export class PushDeviceService {
  constructor(
    @InjectRepository(PushDeviceEntity)
    private readonly repo: Repository<PushDeviceEntity>,
  ) {}

  /**
   * Saves the token for this user and session. A token belongs to one install, so if another
   * account registered it on this phone before, it moves to this user. An older token of the
   * same phone (same device_uuid) for this user is removed.
   */
  async register(
    userId: string,
    sessionId: string | null,
    input: PushDeviceInput,
  ): Promise<PushDeviceEntity> {
    await this.repo.delete({
      userId,
      deviceUuid: input.deviceUuid,
      deviceToken: Not(input.deviceToken),
    });
    const existing = await this.repo.findOne({
      where: { deviceToken: input.deviceToken },
    });
    return this.repo.save({
      ...(existing ?? {}),
      userId,
      sessionId,
      deviceToken: input.deviceToken,
      deviceUuid: input.deviceUuid,
      deviceModel: input.deviceModel,
    });
  }

  /** Logout on one phone: forget that phone's token (if it is this user's). */
  async remove(userId: string, deviceToken: string): Promise<void> {
    if (!deviceToken) return;
    await this.repo.delete({ userId, deviceToken });
  }

  /** Logout everywhere / account deletion: forget every token of the user. */
  async removeAllForUser(userId: string): Promise<void> {
    await this.repo.delete({ userId });
  }
}
