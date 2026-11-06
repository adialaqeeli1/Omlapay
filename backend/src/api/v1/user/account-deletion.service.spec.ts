/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-argument --
   the in-memory repositories are untyped stand-ins for TypeORM */
import { UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { SwapStatus, TransactionStatus } from '@common/database/model';
import { FakeRepo } from '@common/testing/fake-repo';
import { TrustedDeviceService } from '@common/services/trusted-device/trusted-device.service';
import { AuthService } from '../auth/auth.service';
import { AccountDeletionService } from './account-deletion.service';

const PASSCODE = '135790';
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
    wallets: new FakeRepo<any>(),
    transactions: new FakeRepo<any>(),
    swaps: new FakeRepo<any>(),
    pendingSends: new FakeRepo<any>(),
  };
  const jwt = new JwtService({ secret: 'test-secret' });
  const trusted = new TrustedDeviceService(repos.devices as any);
  const sms = { sendOTP: jest.fn().mockResolvedValue(undefined) };
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
  );
  const admins = { notifyAllAdmins: jest.fn().mockResolvedValue(undefined) };
  const service = new AccountDeletionService(
    repos.users as any,
    repos.security as any,
    repos.sessions as any,
    repos.otps as any,
    repos.wallets as any,
    repos.transactions as any,
    repos.swaps as any,
    repos.pendingSends as any,
    auth,
    trusted,
    admins as any,
  );
  return { ...repos, jwt, auth, sms, admins, service };
}

async function withUser(t: ReturnType<typeof setup>) {
  const user = await t.users.save({
    countryCode: '+966',
    mobileNumber: '512345678',
    fullMobileNumber: PHONE,
    isActive: true,
    email: 'user@example.com',
    isEmailVerified: true,
    profileImageUrl: 'https://files.omlapay.org/p.png',
    binanceSubaccountId: 'sub-1',
    binanceApiKey: 'key',
    binanceSecretKey: 'secret',
  });
  await t.security.save({
    userId: user.id,
    passcodeHash: await bcrypt.hash(PASSCODE, 4),
    failedAttempts: 0,
    lockedUntil: null,
  });
  const session = await t.sessions.save({ userId: user.id, isRevoked: false });
  await t.devices.save({
    userId: user.id,
    tokenHash: 'h',
    deviceId: null,
    expiresAt: new Date(Date.now() + DAY),
    revokedAt: null,
  });
  await t.wallets.save({
    userId: user.id,
    balance: '0.000000000000000000',
    lockedBalance: '0',
  });
  return { user, session };
}

describe('Account deletion (stage 2)', () => {
  describe('POST /user/settings/request-deletion', () => {
    it('schedules deletion in 7 days and logs out every session and device', async () => {
      const t = setup();
      const { user, session } = await withUser(t);
      const res = await t.service.requestDeletion(
        user.id,
        session.id,
        PASSCODE,
      );

      expect(res.status).toBe('success');
      expect(res.message_ar).toBeTruthy();
      const due = new Date(res.data.deletion_scheduled_for).getTime();
      expect(due - Date.now()).toBeGreaterThan(7 * DAY - 60_000);
      expect(due - Date.now()).toBeLessThanOrEqual(7 * DAY);
      expect(user.deletionRequestedAt).toBeInstanceOf(Date);
      expect(t.sessions.rows.every((s) => s.isRevoked)).toBe(true);
      expect(t.devices.rows.every((d) => d.revokedAt)).toBe(true);
      expect(user.fullMobileNumber).toBe(PHONE); // nothing erased yet
      expect(t.admins.notifyAllAdmins).toHaveBeenCalled();
    });

    it('needs the right passcode; wrong tries count toward the lockout', async () => {
      const t = setup();
      const { user, session } = await withUser(t);
      await expect(
        t.service.requestDeletion(user.id, session.id, '000000'),
      ).rejects.toBeInstanceOf(UnauthorizedException);
      expect(t.security.rows[0].failedAttempts).toBe(1);
      expect(user.deletionScheduledFor).toBeUndefined();
    });

    it.each([
      [
        'a balance',
        (t: ReturnType<typeof setup>, id: string) =>
          t.wallets.save({
            userId: id,
            balance: '0.00000001',
            lockedBalance: '0',
          }),
        'ACCOUNT_HAS_BALANCE',
      ],
      [
        'a locked balance',
        (t: ReturnType<typeof setup>, id: string) =>
          t.wallets.save({ userId: id, balance: '0', lockedBalance: '5' }),
        'ACCOUNT_HAS_BALANCE',
      ],
      [
        'a pending transaction',
        (t: ReturnType<typeof setup>, id: string) =>
          t.transactions.save({
            userId: id,
            status: TransactionStatus.PENDING,
          }),
        'ACCOUNT_HAS_PENDING_ACTIVITY',
      ],
      [
        'a processing transaction',
        (t: ReturnType<typeof setup>, id: string) =>
          t.transactions.save({
            userId: id,
            status: TransactionStatus.PROCESSING,
          }),
        'ACCOUNT_HAS_PENDING_ACTIVITY',
      ],
      [
        'a pending swap',
        (t: ReturnType<typeof setup>, id: string) =>
          t.swaps.save({ userId: id, status: SwapStatus.PENDING }),
        'ACCOUNT_HAS_PENDING_ACTIVITY',
      ],
      [
        'a send waiting for its code',
        (t: ReturnType<typeof setup>, id: string) =>
          t.pendingSends.save({
            userId: id,
            expiresAt: new Date(Date.now() + 60_000),
          }),
        'ACCOUNT_HAS_PENDING_ACTIVITY',
      ],
    ])('is refused with %s', async (_label, add, code) => {
      const t = setup();
      const { user, session } = await withUser(t);
      await add(t, user.id);
      await expect(
        t.service.requestDeletion(user.id, session.id, PASSCODE),
      ).rejects.toMatchObject({
        response: { code, message_ar: expect.any(String) },
      });
      expect(user.deletionScheduledFor).toBeUndefined();
      expect(t.sessions.rows.some((s) => !s.isRevoked)).toBe(true);
    });

    it('finished, failed or expired activity does not block it', async () => {
      const t = setup();
      const { user, session } = await withUser(t);
      await t.transactions.save({
        userId: user.id,
        status: TransactionStatus.COMPLETED,
      });
      await t.transactions.save({
        userId: user.id,
        status: TransactionStatus.FAILED,
      });
      await t.swaps.save({ userId: user.id, status: SwapStatus.COMPLETED });
      await t.pendingSends.save({
        userId: user.id,
        expiresAt: new Date(Date.now() - 1000),
      });
      await expect(
        t.service.requestDeletion(user.id, session.id, PASSCODE),
      ).resolves.toMatchObject({
        status: 'success',
      });
    });
  });

  describe('logging in again during the 7 days', () => {
    it('cancels the deletion', async () => {
      const t = setup();
      const { user, session } = await withUser(t);
      await t.service.requestDeletion(user.id, session.id, PASSCODE);

      await t.auth.sendLoginOtp({
        country_code: '+966',
        mobile_number: '512345678',
      });
      const code = t.sms.sendOTP.mock.calls.at(-1)[1];
      const v = await t.auth.verifyLoginOtp({
        country_code: '+966',
        mobile_number: '512345678',
        otp: code,
      });
      const res = await t.auth.login({
        passcode: PASSCODE,
        otpVerificationToken: v.data.otpVerificationToken,
      });

      expect((res.data as any).deletion_cancelled).toBe(true);
      expect(user.deletionScheduledFor).toBeNull();
      expect(await t.service.purgeDue(new Date(Date.now() + 8 * DAY))).toBe(0);
      expect(user.fullMobileNumber).toBe(PHONE);
    });
  });

  describe('after 7 days', () => {
    it('erases personal data, keeps records, frees the phone number, tells admins', async () => {
      const t = setup();
      const { user, session } = await withUser(t);
      await t.transactions.save({
        userId: user.id,
        status: TransactionStatus.COMPLETED,
        amount: '10',
      });
      await t.otps.save({ fullMobileNumber: PHONE, purpose: 'LOGIN' });
      await t.service.requestDeletion(user.id, session.id, PASSCODE);

      expect(await t.service.purgeDue(new Date(Date.now() + 6 * DAY))).toBe(0); // still in grace period
      expect(
        await t.service.purgeDue(new Date(Date.now() + 7 * DAY + 1000)),
      ).toBe(1);

      expect(user).toMatchObject({
        countryCode: '',
        mobileNumber: '',
        email: null,
        isEmailVerified: false,
        profileImageUrl: null,
        binanceApiKey: null,
        binanceSecretKey: null,
        isActive: false,
        binanceSubaccountId: 'sub-1', // kept for admins (frozen)
      });
      expect(user.fullMobileNumber).not.toBe(PHONE);
      expect(user.fullMobileNumber).toHaveLength(20);
      expect(user.anonymizedAt).toBeInstanceOf(Date);
      expect(t.security.rows).toHaveLength(0); // passcode hash gone
      expect(t.otps.rows).toHaveLength(0);
      expect(t.transactions.rows).toHaveLength(1); // records kept
      expect(t.wallets.rows).toHaveLength(1);
      expect(t.admins.notifyAllAdmins).toHaveBeenLastCalledWith(
        expect.anything(),
        'Account deleted',
        expect.stringContaining('sub-1'),
      );

      // the number can register again and nobody can log in to the old account
      expect(
        await t.users.findOne({ where: { fullMobileNumber: PHONE } }),
      ).toBeNull();
      expect(await t.service.purgeDue(new Date(Date.now() + 30 * DAY))).toBe(0); // only once
    });

    it('never erases an account that received funds during the grace period', async () => {
      const t = setup();
      const { user, session } = await withUser(t);
      await t.service.requestDeletion(user.id, session.id, PASSCODE);
      t.wallets.rows[0].balance = '25';

      expect(await t.service.purgeDue(new Date(Date.now() + 8 * DAY))).toBe(0);
      expect(user.fullMobileNumber).toBe(PHONE);
      expect(user.anonymizedAt).toBeUndefined();
      expect(user.deletionScheduledFor).toBeNull();
      expect(t.admins.notifyAllAdmins).toHaveBeenLastCalledWith(
        expect.anything(),
        'Account deletion stopped',
        expect.stringContaining('a balance'),
      );
    });
  });

  it('a scheduled user who logs in with the wrong passcode keeps the schedule', async () => {
    const t = setup();
    const { user, session } = await withUser(t);
    await t.service.requestDeletion(user.id, session.id, PASSCODE);
    await t.auth.sendLoginOtp({
      country_code: '+966',
      mobile_number: '512345678',
    });
    const code = t.sms.sendOTP.mock.calls.at(-1)[1];
    const v = await t.auth.verifyLoginOtp({
      country_code: '+966',
      mobile_number: '512345678',
      otp: code,
    });
    await expect(
      t.auth.login({
        passcode: '000000',
        otpVerificationToken: v.data.otpVerificationToken,
      }),
    ).rejects.toBeInstanceOf(UnauthorizedException);
    expect(user.deletionScheduledFor).toBeInstanceOf(Date);
  });
});
