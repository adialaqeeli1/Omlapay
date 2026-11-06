/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-call --
   the in-memory repositories are untyped stand-ins for TypeORM */
import { JwtService } from '@nestjs/jwt';
import { FakeRepo } from '@common/testing/fake-repo';
import { TrustedDeviceService } from '@common/services/trusted-device/trusted-device.service';
import { AuthService } from '../auth/auth.service';
import { UserService } from './user.service';

function setup() {
  const users = new FakeRepo<any>();
  const sessions = new FakeRepo<any>();
  const settings = new FakeRepo<any>();
  const devices = new FakeRepo<any>();
  const jwt = new JwtService({ secret: 'test-secret' });
  const trusted = new TrustedDeviceService(devices as any);
  const auth = new AuthService(
    users as any,
    {} as any,
    settings as any,
    sessions as any,
    {} as any,
    jwt,
    {} as any,
    {} as any,
    trusted,
  );
  const deps: any[] = [
    users,
    {},
    sessions,
    {},
    settings,
    {},
    {},
    {},
    jwt,
    {},
    {},
    {},
    {},
    {},
    {},
    trusted,
    auth,
  ];
  const service = new (UserService as any)(...deps) as UserService;
  return { users, sessions, settings, jwt, service };
}

describe('Turning off 2FA (no passcode needed to stay logged in)', () => {
  it('logs out every session but returns a new one for this phone, on the same remembered device', async () => {
    const t = setup();
    const user = await t.users.save({
      fullMobileNumber: '+966512345678',
      isActive: true,
    });
    await t.settings.save({ userId: user.id, twoFactorEnabled: true });
    const here = await t.sessions.save({
      userId: user.id,
      isRevoked: false,
      trustedDeviceId: 'device-1',
    });
    const other = await t.sessions.save({
      userId: user.id,
      isRevoked: false,
      trustedDeviceId: 'device-2',
    });

    const res = await t.service.disable2FA(user.id, here.id);

    expect(t.settings.rows[0].twoFactorEnabled).toBe(false);
    expect(here.isRevoked).toBe(true);
    expect(other.isRevoked).toBe(true);
    const fresh = t.sessions.rows.at(-1);
    expect(fresh).toMatchObject({
      userId: user.id,
      isRevoked: false,
      trustedDeviceId: 'device-1',
    });
    const payload = t.jwt.verify(res.data.access_token);
    expect(payload).toMatchObject({
      userId: user.id,
      sessionId: fresh.id,
      type: 'access',
    });
    expect(t.jwt.verify(res.data.refresh_token).type).toBe('refresh');
    expect(res.data.expires_in).toBe(86400);
  });
});
