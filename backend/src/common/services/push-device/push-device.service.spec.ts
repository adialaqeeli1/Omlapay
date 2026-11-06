/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-return --
   the in-memory repository is an untyped stand-in for TypeORM */
import { JwtService } from '@nestjs/jwt';
import { FakeRepo } from '@common/testing/fake-repo';
import { TrustedDeviceService } from '@common/services/trusted-device/trusted-device.service';
import { AuthService } from '../../../api/v1/auth/auth.service';
import { NotificationsController } from '../../../api/v1/notifications/notifications.controller';
import { PushDeviceService } from './push-device.service';

const phoneA = {
  deviceToken: 'fcm-A',
  deviceUuid: 'uuid-A',
  deviceModel: 'iPhone15,2',
};

describe('Push-notification devices (stage 4)', () => {
  it('POST /notifications/devices saves the token for this user and session', async () => {
    const repo = new FakeRepo<any>();
    const service = new PushDeviceService(repo as any);
    const controller = new NotificationsController({} as any, service);
    const res = await controller.registerDevice(
      { userId: 'u1', sessionId: 's1' },
      {
        device_token: 'fcm-A',
        device_uuid: 'uuid-A',
        device_model: 'iPhone15,2',
      },
    );
    expect(res.status).toBe('success');
    expect(repo.rows).toEqual([
      expect.objectContaining({
        userId: 'u1',
        sessionId: 's1',
        deviceToken: 'fcm-A',
        deviceUuid: 'uuid-A',
        deviceModel: 'iPhone15,2',
      }),
    ]);
  });

  it('registering the same token again updates it instead of adding a copy', async () => {
    const repo = new FakeRepo<any>();
    const service = new PushDeviceService(repo as any);
    await service.register('u1', 's1', phoneA);
    await service.register('u1', 's2', phoneA);
    expect(repo.rows).toHaveLength(1);
    expect(repo.rows[0].sessionId).toBe('s2');
  });

  it('a refreshed token replaces the old one of the same phone', async () => {
    const repo = new FakeRepo<any>();
    const service = new PushDeviceService(repo as any);
    await service.register('u1', 's1', phoneA);
    await service.register('u1', 's1', { ...phoneA, deviceToken: 'fcm-A2' });
    expect(repo.rows.map((r) => r.deviceToken)).toEqual(['fcm-A2']);
  });

  it("another user logging in on the same phone takes the token over (no pushes to the old account's phone)", async () => {
    const repo = new FakeRepo<any>();
    const service = new PushDeviceService(repo as any);
    await service.register('u1', 's1', phoneA);
    await service.register('u2', 's9', phoneA);
    expect(repo.rows).toHaveLength(1);
    expect(repo.rows[0]).toMatchObject({ userId: 'u2', sessionId: 's9' });
  });

  it("two phones of one user are both kept; another user's token is never removed by remove()", async () => {
    const repo = new FakeRepo<any>();
    const service = new PushDeviceService(repo as any);
    await service.register('u1', 's1', phoneA);
    await service.register('u1', 's2', {
      deviceToken: 'fcm-B',
      deviceUuid: 'uuid-B',
      deviceModel: 'Pixel 8',
    });
    await service.register('u2', 's3', {
      deviceToken: 'fcm-C',
      deviceUuid: 'uuid-C',
      deviceModel: 'Pixel 9',
    });
    expect(repo.rows).toHaveLength(3);
    await service.remove('u1', 'fcm-C'); // not u1's
    expect(repo.rows).toHaveLength(3);
    await service.removeAllForUser('u1');
    expect(repo.rows.map((r) => r.deviceToken)).toEqual(['fcm-C']);
  });

  describe('logout', () => {
    function setup() {
      const sessions = new FakeRepo<any>();
      const pushRepo = new FakeRepo<any>();
      const push = new PushDeviceService(pushRepo as any);
      const trusted = new TrustedDeviceService(new FakeRepo<any>() as any);
      const auth = new AuthService(
        {} as any,
        {} as any,
        {} as any,
        sessions as any,
        {} as any,
        new JwtService({ secret: 't' }),
        {} as any,
        {} as any,
        trusted,
        push,
      );
      return { sessions, pushRepo, push, auth };
    }

    it('logout with device_token stops pushes to that phone only', async () => {
      const t = setup();
      const s = await t.sessions.save({
        userId: 'u1',
        isRevoked: false,
        trustedDeviceId: null,
      });
      await t.push.register('u1', s.id, phoneA);
      await t.push.register('u1', 'other', {
        deviceToken: 'fcm-B',
        deviceUuid: 'uuid-B',
        deviceModel: 'Pixel 8',
      });
      await t.auth.logout('u1', s.id, 'fcm-A');
      expect(t.pushRepo.rows.map((r) => r.deviceToken)).toEqual(['fcm-B']);
    });

    it('logout without a token still logs out', async () => {
      const t = setup();
      const s = await t.sessions.save({
        userId: 'u1',
        isRevoked: false,
        trustedDeviceId: null,
      });
      await t.push.register('u1', s.id, phoneA);
      await expect(t.auth.logout('u1', s.id)).resolves.toMatchObject({
        status: 'success',
      });
      expect(s.isRevoked).toBe(true);
      expect(t.pushRepo.rows).toHaveLength(1);
    });

    it('logout everywhere forgets every phone of the user', async () => {
      const t = setup();
      await t.push.register('u1', 's1', phoneA);
      await t.push.register('u1', 's2', {
        deviceToken: 'fcm-B',
        deviceUuid: 'uuid-B',
        deviceModel: 'Pixel 8',
      });
      await t.auth.logoutAll('u1');
      expect(t.pushRepo.rows).toHaveLength(0);
    });
  });
});
