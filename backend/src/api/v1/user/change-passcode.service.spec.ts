/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-argument --
   the in-memory repositories are untyped stand-ins for TypeORM */
import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { FakeRepo } from '@common/testing/fake-repo';
import { TrustedDeviceService } from '@common/services/trusted-device/trusted-device.service';
import { PushDeviceService } from '@common/services/push-device/push-device.service';
import { AuthService } from '../auth/auth.service';
import { ChangePasscodeService } from './change-passcode.service';

const OLD = '135790';
const NEW = '246813';
const PHONE = '+966512345678';
const DAY = 24 * 60 * 60 * 1000;

function setup() {
  const repos = {
    users: new FakeRepo<any>(),
    security: new FakeRepo<any>(),
    settings: new FakeRepo<any>(),
    sessions: new FakeRepo<any>(),
    otps: new FakeRepo<any>(),
    devices: new FakeRepo<any>(),
  };
  const pushRepo = new FakeRepo<any>();
  const push = new PushDeviceService(pushRepo as any);
  const jwt = new JwtService({ secret: 'test-secret' });
  const trusted = new TrustedDeviceService(repos.devices as any);
  const sms = {
    sendOTP: jest.fn(),
    sendSms: jest.fn().mockResolvedValue(undefined),
  };
  const auth = new AuthService(
    repos.users as any,
    repos.security as any,
    repos.settings as any,
    repos.sessions as any,
    repos.otps as any,
    jwt,
    sms as any,
    {} as any,
    trusted,
    push,
  );
  const service = new ChangePasscodeService(
    repos.users as any,
    repos.security as any,
    repos.sessions as any,
    auth,
    trusted,
    sms as any,
  );
  return { ...repos, jwt, auth, sms, service };
}

async function withUser(t: ReturnType<typeof setup>) {
  const user = await t.users.save({ fullMobileNumber: PHONE, isActive: true });
  await t.security.save({
    userId: user.id,
    passcodeHash: await bcrypt.hash(OLD, 4),
    failedAttempts: 0,
    lockedUntil: null,
  });
  const device = (role: string) =>
    t.devices.save({
      userId: user.id,
      tokenHash: role,
      deviceId: null,
      expiresAt: new Date(Date.now() + DAY),
      revokedAt: null,
    });
  const here = await device('here');
  const other = await device('other');
  const session = await t.sessions.save({
    userId: user.id,
    isRevoked: false,
    trustedDeviceId: here.id,
  });
  const otherSession = await t.sessions.save({
    userId: user.id,
    isRevoked: false,
    trustedDeviceId: other.id,
  });
  return { user, here, other, session, otherSession };
}

const body = (current = OLD, next = NEW, confirm = next) => ({
  current_passcode: current,
  new_passcode: next,
  confirm_passcode: confirm,
});

describe('Change passcode (stage 3)', () => {
  it('changes the passcode, logs out other phones, keeps this phone logged in and remembered', async () => {
    const t = setup();
    const { user, here, other, session, otherSession } = await withUser(t);

    const res = await t.service.changePasscode(user.id, session.id, body());

    expect(res.status).toBe('success');
    expect(res.message_ar).toBeTruthy();
    expect(await bcrypt.compare(NEW, t.security.rows[0].passcodeHash)).toBe(
      true,
    );
    expect(await bcrypt.compare(OLD, t.security.rows[0].passcodeHash)).toBe(
      false,
    );
    expect(t.security.rows[0].lastPasscodeChangedAt).toBeInstanceOf(Date);
    // every old session ends, including this one; a fresh one is returned for this phone
    expect(session.isRevoked).toBe(true);
    expect(otherSession.isRevoked).toBe(true);
    const fresh = t.sessions.rows.at(-1);
    expect(fresh).toMatchObject({ isRevoked: false, trustedDeviceId: here.id });
    expect(t.jwt.verify(res.data.access_token)).toMatchObject({
      userId: user.id,
      sessionId: fresh.id,
      type: 'access',
    });
    // this phone stays remembered, the other one is forgotten
    expect(here.revokedAt).toBeNull();
    expect(other.revokedAt).toBeInstanceOf(Date);
  });

  it('sends an SMS alert to the account phone', async () => {
    const t = setup();
    const { user, session } = await withUser(t);
    await t.service.changePasscode(user.id, session.id, body());
    expect(t.sms.sendSms).toHaveBeenCalledWith(
      PHONE,
      expect.stringContaining('passcode was changed'),
    );
  });

  it('a failed alert SMS does not undo the change', async () => {
    const t = setup();
    const { user, session } = await withUser(t);
    t.sms.sendSms.mockRejectedValueOnce(new Error('SMS down'));
    await expect(
      t.service.changePasscode(user.id, session.id, body()),
    ).resolves.toMatchObject({ status: 'success' });
    expect(await bcrypt.compare(NEW, t.security.rows[0].passcodeHash)).toBe(
      true,
    );
  });

  it('a wrong current passcode is refused and counts toward the lockout', async () => {
    const t = setup();
    const { user, session } = await withUser(t);
    await expect(
      t.service.changePasscode(user.id, session.id, body('000001')),
    ).rejects.toBeInstanceOf(UnauthorizedException);
    expect(t.security.rows[0].failedAttempts).toBe(1);
    expect(await bcrypt.compare(OLD, t.security.rows[0].passcodeHash)).toBe(
      true,
    );
    expect(t.sms.sendSms).not.toHaveBeenCalled();
  });

  it.each([
    [
      'confirmation does not match',
      body(OLD, NEW, '246814'),
      'Passcodes do not match',
    ],
    ['same as the current one', body(OLD, OLD), 'SAME_PASSCODE'],
    ['all the same digit', body(OLD, '444444'), 'WEAK_PASSCODE'],
    ['a straight run', body(OLD, '345678'), 'WEAK_PASSCODE'],
  ])(
    'refuses a new passcode when %s, and nothing changes',
    async (_label, dto, expected) => {
      const t = setup();
      const { user, session, otherSession } = await withUser(t);
      const err = await t.service
        .changePasscode(user.id, session.id, dto)
        .catch((e: unknown) => e);
      expect(err).toBeInstanceOf(BadRequestException);
      expect(
        JSON.stringify((err as BadRequestException).getResponse()),
      ).toContain(expected);
      expect(await bcrypt.compare(OLD, t.security.rows[0].passcodeHash)).toBe(
        true,
      );
      expect(otherSession.isRevoked).toBe(false);
    },
  );

  it('the new passcode works for the next login and the old one does not', async () => {
    const t = setup();
    const { user, session } = await withUser(t);
    const res = await t.service.changePasscode(user.id, session.id, body());
    const freshSessionId = t.jwt.verify(res.data.access_token).sessionId;
    await expect(
      t.auth.softLogin(user.id, freshSessionId, { passcode: OLD }),
    ).rejects.toBeInstanceOf(UnauthorizedException);
    await expect(
      t.auth.softLogin(user.id, freshSessionId, { passcode: NEW }),
    ).resolves.toMatchObject({
      status: 'success',
    });
  });
});

describe('Weak passcodes at registration and forgot-passcode reset', () => {
  it('forgot-passcode reset refuses 123456', async () => {
    const t = setup();
    const { user } = await withUser(t);
    const reset_token = t.jwt.sign({ userId: user.id, type: 'reset' });
    await expect(
      t.auth.resetPasscode({
        reset_token,
        new_passcode: '123456',
        confirm_passcode: '123456',
      }),
    ).rejects.toMatchObject({ response: { code: 'WEAK_PASSCODE' } });
    expect(await bcrypt.compare(OLD, t.security.rows[0].passcodeHash)).toBe(
      true,
    );
  });
});
