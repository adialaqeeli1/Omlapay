/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-return --
   the in-memory repositories below are untyped stand-ins for TypeORM */
import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import * as bcrypt from 'bcryptjs';
import { OtpPurpose } from '@common/database/model';
import { TrustedDeviceService } from '@common/services/trusted-device/trusted-device.service';
import { PushDeviceService } from '@common/services/push-device/push-device.service';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { FakeRepo } from '@common/testing/fake-repo';
import { LoginDto } from './dto/login.dto';
import { PasscodeLoginDto } from './dto/passcode-login.dto';

const PHONE = { country_code: '+966', mobile_number: '0512345678' };
const FULL = '+966512345678';
const PASSCODE = '135790';

function setup() {
  const users = new FakeRepo<any>();
  const security = new FakeRepo<any>();
  const settings = new FakeRepo<any>();
  const sessions = new FakeRepo<any>();
  const otps = new FakeRepo<any>();
  const devices = new FakeRepo<any>();
  const pushRepo = new FakeRepo<any>();
  const push = new PushDeviceService(pushRepo as any);
  const jwt = new JwtService({ secret: 'test-secret' });
  const sms = { sendOTP: jest.fn().mockResolvedValue(undefined) };
  const service = new AuthService(
    users as any,
    security as any,
    settings as any,
    sessions as any,
    otps as any,
    jwt,
    sms as any,
    {} as any,
    new TrustedDeviceService(devices as any),
    push,
  );
  const lastCode = () => sms.sendOTP.mock.calls.at(-1)[1] as string;
  return {
    users,
    security,
    sessions,
    otps,
    devices,
    jwt,
    sms,
    service,
    lastCode,
  };
}

async function withUser(t: ReturnType<typeof setup>, isActive = true) {
  const user = await t.users.save({ fullMobileNumber: FULL, isActive });
  await t.security.save({
    userId: user.id,
    passcodeHash: await bcrypt.hash(PASSCODE, 4),
    failedAttempts: 0,
    lockedUntil: null,
  });
  return user;
}

async function codeToken(t: ReturnType<typeof setup>) {
  await t.service.sendLoginOtp({ ...PHONE });
  const res = await t.service.verifyLoginOtp({ ...PHONE, otp: t.lastCode() });
  return res.data.otpVerificationToken;
}

describe('Login with SMS code (stage 1)', () => {
  const env = process.env.NODE_ENV;
  afterEach(() => {
    process.env.NODE_ENV = env;
  });

  describe('send-otp / resend-otp', () => {
    it('sends a code to an existing Saudi user and returns what the app reads', async () => {
      const t = setup();
      await withUser(t);
      process.env.NODE_ENV = 'production';
      const res = await t.service.sendLoginOtp({ ...PHONE });
      expect(t.sms.sendOTP).toHaveBeenCalledWith(
        FULL,
        expect.stringMatching(/^\d{6}$/),
      );
      expect(res.status).toBe('success');
      expect(res.data.otp_expiry_seconds).toBe(60);
      expect(res.data).not.toHaveProperty('mobile_otp'); // never outside development
      expect(t.otps.rows).toHaveLength(1);
      expect(t.otps.rows[0].purpose).toBe(OtpPurpose.LOGIN);
      expect(t.otps.rows[0].otpHash).not.toBe(t.lastCode()); // stored hashed
    });

    it('shows the code only in development', async () => {
      const t = setup();
      await withUser(t);
      process.env.NODE_ENV = 'development';
      const res = await t.service.sendLoginOtp({ ...PHONE });
      expect((res.data as any).mobile_otp).toBe(t.lastCode());
    });

    it('rejects non-Saudi numbers before anything is sent', async () => {
      const t = setup();
      await expect(
        t.service.sendLoginOtp({
          country_code: '+91',
          mobile_number: '9876543210',
        }),
      ).rejects.toMatchObject({ response: { code: 'PHONE_NOT_ALLOWED' } });
      expect(t.sms.sendOTP).not.toHaveBeenCalled();
    });

    it('rejects unknown and deactivated users', async () => {
      const t = setup();
      await expect(t.service.sendLoginOtp({ ...PHONE })).rejects.toBeInstanceOf(
        BadRequestException,
      );
      await withUser(t, false);
      await expect(t.service.sendLoginOtp({ ...PHONE })).rejects.toThrow(
        /deactivated/,
      );
      expect(t.sms.sendOTP).not.toHaveBeenCalled();
    });

    it('resend: 60-second cooldown, then at most 3 resends', async () => {
      const t = setup();
      await withUser(t);
      await t.service.sendLoginOtp({ ...PHONE });
      await expect(t.service.sendLoginOtp({ ...PHONE }, true)).rejects.toThrow(
        /wait \d+ seconds/,
      );
      for (let i = 1; i <= 3; i++) {
        t.otps.rows[0].lastResendAt = new Date(Date.now() - 61_000);
        const res = await t.service.sendLoginOtp({ ...PHONE }, true);
        expect(res.message).toMatch(/resent/);
        expect(t.otps.rows[0].resendAttempts).toBe(i);
      }
      t.otps.rows[0].lastResendAt = new Date(Date.now() - 61_000);
      await expect(t.service.sendLoginOtp({ ...PHONE }, true)).rejects.toThrow(
        /Maximum resend/,
      );
      expect(t.otps.rows).toHaveLength(1); // only the newest code exists
    });
  });

  describe('verify-otp', () => {
    it('returns otpVerificationToken for the right code, once', async () => {
      const t = setup();
      const user = await withUser(t);
      await t.service.sendLoginOtp({ ...PHONE });
      const code = t.lastCode();
      const res = await t.service.verifyLoginOtp({ ...PHONE, otp: code });
      const payload = t.jwt.verify(res.data.otpVerificationToken);
      expect(payload).toMatchObject({ userId: user.id, type: 'login_otp' });
      expect(payload.exp - payload.iat).toBe(300);
      await expect(
        t.service.verifyLoginOtp({ ...PHONE, otp: code }),
      ).rejects.toThrow(/already been used/);
    });

    it('cancels the code after 3 wrong tries', async () => {
      const t = setup();
      await withUser(t);
      await t.service.sendLoginOtp({ ...PHONE });
      const wrong = t.lastCode() === '000000' ? '111111' : '000000';
      await expect(
        t.service.verifyLoginOtp({ ...PHONE, otp: wrong }),
      ).rejects.toMatchObject({
        response: {
          code: 'MOBILE_OTP_INVALID',
          data: { remaining_attempts: 2 },
        },
      });
      await expect(
        t.service.verifyLoginOtp({ ...PHONE, otp: wrong }),
      ).rejects.toMatchObject({
        response: { data: { remaining_attempts: 1 } },
      });
      await expect(
        t.service.verifyLoginOtp({ ...PHONE, otp: wrong }),
      ).rejects.toMatchObject({
        response: { code: 'OTP_ATTEMPTS_EXCEEDED' },
      });
      // even the right code no longer works
      await expect(
        t.service.verifyLoginOtp({ ...PHONE, otp: t.lastCode() }),
      ).rejects.toThrow(/not found/);
    });

    it('rejects an expired code', async () => {
      const t = setup();
      await withUser(t);
      await t.service.sendLoginOtp({ ...PHONE });
      t.otps.rows[0].expiresAt = new Date(Date.now() - 1000);
      await expect(
        t.service.verifyLoginOtp({ ...PHONE, otp: t.lastCode() }),
      ).rejects.toThrow(/expired/);
    });
  });

  describe('POST /auth/login with otpVerificationToken', () => {
    it('logs in with token + passcode and returns the tokens and user the app reads', async () => {
      const t = setup();
      const user = await withUser(t);
      const token = await codeToken(t);
      const res = await t.service.login({
        passcode: PASSCODE,
        otpVerificationToken: token,
      });
      expect(res.data.access_token).toBeTruthy();
      expect(res.data.refresh_token).toBeTruthy();
      expect(res.data.user).toMatchObject({ id: user.id, mobile_number: FULL });
      expect(t.jwt.verify(res.data.access_token).type).toBe('access');
      expect(t.sessions.rows).toHaveLength(1);
    });

    it('a token works for one login only', async () => {
      const t = setup();
      await withUser(t);
      const token = await codeToken(t);
      await t.service.login({
        passcode: PASSCODE,
        otpVerificationToken: token,
      });
      await expect(
        t.service.login({ passcode: PASSCODE, otpVerificationToken: token }),
      ).rejects.toMatchObject({ response: { code: 'LOGIN_TOKEN_INVALID' } });
    });

    it('a wrong passcode keeps the token and counts toward the 5-try lockout', async () => {
      const t = setup();
      await withUser(t);
      const token = await codeToken(t);
      await expect(
        t.service.login({ passcode: '000000', otpVerificationToken: token }),
      ).rejects.toThrow(/4 attempt/);
      expect(t.security.rows[0].failedAttempts).toBe(1);
      const res = await t.service.login({
        passcode: PASSCODE,
        otpVerificationToken: token,
      });
      expect(res.status).toBe('success');
      expect(t.security.rows[0].failedAttempts).toBe(0);
    });

    it('rejects forged, expired, wrong-type and replaced tokens', async () => {
      const t = setup();
      const user = await withUser(t);
      const login = (otpVerificationToken: string) =>
        t.service.login({ passcode: PASSCODE, otpVerificationToken });

      await expect(login('not-a-jwt')).rejects.toBeInstanceOf(
        UnauthorizedException,
      );
      const forged = new JwtService({ secret: 'other' }).sign({
        userId: user.id,
        otpId: 'x',
        type: 'login_otp',
      });
      await expect(login(forged)).rejects.toBeInstanceOf(UnauthorizedException);
      // an access token is not a login token
      await expect(
        login(t.jwt.sign({ userId: user.id, sessionId: 's', type: 'access' })),
      ).rejects.toBeInstanceOf(UnauthorizedException);
      const token = await codeToken(t);
      const { otpId } = t.jwt.verify(token);
      await expect(
        login(
          t.jwt.sign(
            { userId: user.id, otpId, type: 'login_otp' },
            { expiresIn: -1 },
          ),
        ),
      ).rejects.toBeInstanceOf(UnauthorizedException);
      // asking for a new code cancels the old token
      await t.service.sendLoginOtp({ ...PHONE });
      await expect(login(token)).rejects.toMatchObject({
        response: { code: 'LOGIN_TOKEN_INVALID' },
      });
    });

    it('a token from verify-otp only (code not consumed) is not accepted', async () => {
      const t = setup();
      const user = await withUser(t);
      await t.service.sendLoginOtp({ ...PHONE });
      const otpId = t.otps.rows[0].id; // not verified yet
      const guessed = t.jwt.sign({ userId: user.id, otpId, type: 'login_otp' });
      await expect(
        t.service.login({ passcode: PASSCODE, otpVerificationToken: guessed }),
      ).rejects.toBeInstanceOf(UnauthorizedException);
    });

    it('a deactivated user cannot use a token', async () => {
      const t = setup();
      const user = await withUser(t);
      const token = await codeToken(t);
      user.isActive = false;
      await expect(
        t.service.login({ passcode: PASSCODE, otpVerificationToken: token }),
      ).rejects.toThrow(/deactivated/);
    });
  });

  describe('POST /auth/login/passcode (remembered device only)', () => {
    const DEVICE = 'AA:BB:CC:DD:EE:FF';
    async function smsLogin(t: ReturnType<typeof setup>, device_id?: string) {
      const otpVerificationToken = await codeToken(t);
      const res = await t.service.login({
        passcode: PASSCODE,
        otpVerificationToken,
        device_id,
      });
      return res.data as typeof res.data & {
        device_token: string;
        device_token_expires_in: number;
      };
    }
    const passcodeLogin = (
      t: ReturnType<typeof setup>,
      extra: Partial<PasscodeLoginDto>,
    ) =>
      t.service.loginWithDevice({
        ...PHONE,
        passcode: PASSCODE,
        device_token: '',
        ...extra,
      });

    it('SMS login remembers the phone: device_token valid 30 days, stored hashed', async () => {
      const t = setup();
      await withUser(t);
      const data = await smsLogin(t, DEVICE);
      expect(data.device_token).toMatch(/^[\w-]{43}$/);
      expect(data.device_token_expires_in).toBe(30 * 24 * 3600);
      expect(t.devices.rows).toHaveLength(1);
      expect(t.devices.rows[0]).toMatchObject({
        deviceId: DEVICE,
        revokedAt: null,
      });
      expect(t.devices.rows[0].tokenHash).not.toContain(data.device_token);
      expect(t.sessions.rows[0].trustedDeviceId).toBe(t.devices.rows[0].id);
    });

    it('a remembered phone logs in with phone + passcode + device_token', async () => {
      const t = setup();
      await withUser(t);
      const { device_token } = await smsLogin(t, DEVICE);
      const res = await passcodeLogin(t, { device_token, device_id: DEVICE });
      expect(res.data.access_token).toBeTruthy();
      expect(res.data).not.toHaveProperty('device_token'); // no new token without an SMS check
      expect(t.devices.rows[0].lastUsedAt).toBeInstanceOf(Date);
      expect(t.sessions.rows.at(-1).trustedDeviceId).toBe(t.devices.rows[0].id);
    });

    it('without a device token: 401 DEVICE_NOT_TRUSTED, and the passcode is not even checked', async () => {
      const t = setup();
      await withUser(t);
      for (const device_token of ['', 'made-up-token']) {
        await expect(passcodeLogin(t, { device_token })).rejects.toMatchObject({
          response: {
            code: 'DEVICE_NOT_TRUSTED',
            message_ar: expect.any(String),
          },
        });
        await expect(
          passcodeLogin(t, { device_token, passcode: '000000' }),
        ).rejects.toMatchObject({
          response: { code: 'DEVICE_NOT_TRUSTED' },
        });
      }
      expect(t.security.rows[0].failedAttempts).toBe(0);
      expect(t.sessions.rows).toHaveLength(0);
    });

    it("another user's device token does not work", async () => {
      const t = setup();
      await withUser(t);
      const { device_token } = await smsLogin(t);
      const other = await t.users.save({
        fullMobileNumber: '+966598765432',
        isActive: true,
      });
      await t.security.save({
        userId: other.id,
        passcodeHash: await bcrypt.hash(PASSCODE, 4),
        failedAttempts: 0,
      });
      await expect(
        passcodeLogin(t, { device_token, mobile_number: '598765432' }),
      ).rejects.toMatchObject({ response: { code: 'DEVICE_NOT_TRUSTED' } });
    });

    it('is bound to the device_id it was issued with', async () => {
      const t = setup();
      await withUser(t);
      const { device_token } = await smsLogin(t, DEVICE);
      for (const device_id of [undefined, '11:22:33:44:55:66']) {
        await expect(
          passcodeLogin(t, { device_token, device_id }),
        ).rejects.toMatchObject({
          response: { code: 'DEVICE_NOT_TRUSTED' },
        });
      }
    });

    it('expires', async () => {
      const t = setup();
      await withUser(t);
      const { device_token } = await smsLogin(t);
      t.devices.rows[0].expiresAt = new Date(Date.now() - 1000);
      await expect(passcodeLogin(t, { device_token })).rejects.toMatchObject({
        response: { code: 'DEVICE_NOT_TRUSTED' },
      });
    });

    it('logout forgets this phone; logout-all forgets every phone', async () => {
      const t = setup();
      const user = await withUser(t);
      const a = await smsLogin(t);
      const b = await smsLogin(t);
      const sessionA = t.sessions.rows[0];
      await t.service.logout(user.id, sessionA.id);
      await expect(
        passcodeLogin(t, { device_token: a.device_token }),
      ).rejects.toMatchObject({
        response: { code: 'DEVICE_NOT_TRUSTED' },
      });
      expect(
        (await passcodeLogin(t, { device_token: b.device_token })).status,
      ).toBe('success');
      await t.service.logoutAll(user.id);
      await expect(
        passcodeLogin(t, { device_token: b.device_token }),
      ).rejects.toMatchObject({
        response: { code: 'DEVICE_NOT_TRUSTED' },
      });
    });

    it('forgot-passcode reset forgets every phone and remembers only the one that reset', async () => {
      const t = setup();
      const user = await withUser(t);
      const old = await smsLogin(t);
      const reset_token = t.jwt.sign({ userId: user.id, type: 'reset' });
      const res = await t.service.resetPasscode({
        reset_token,
        new_passcode: '246802',
        confirm_passcode: '246802',
        device_id: DEVICE,
      });
      await expect(
        passcodeLogin(t, {
          device_token: old.device_token,
          passcode: '246802',
        }),
      ).rejects.toMatchObject({ response: { code: 'DEVICE_NOT_TRUSTED' } });
      const ok = await passcodeLogin(t, {
        device_token: res.data.device_token,
        device_id: DEVICE,
        passcode: '246802',
      });
      expect(ok.status).toBe('success');
    });

    it('a wrong passcode on a remembered phone counts toward the 5-try lockout', async () => {
      const t = setup();
      await withUser(t);
      const { device_token } = await smsLogin(t);
      for (let i = 1; i <= 4; i++) {
        await expect(
          passcodeLogin(t, { device_token, passcode: '000000' }),
        ).rejects.toThrow(/Incorrect passcode/);
      }
      await expect(
        passcodeLogin(t, { device_token, passcode: '000000' }),
      ).rejects.toThrow(/locked/);
      await expect(passcodeLogin(t, { device_token })).rejects.toThrow(
        /temporarily locked/,
      );
    });

    it('still enforces Saudi-only numbers', async () => {
      const t = setup();
      await withUser(t);
      const { device_token } = await smsLogin(t);
      await expect(
        passcodeLogin(t, {
          device_token,
          country_code: '+1',
          mobile_number: '5551234567',
        }),
      ).rejects.toMatchObject({ response: { code: 'PHONE_NOT_ALLOWED' } });
    });

    it('the /login/passcode route uses the device check', async () => {
      const t = setup();
      await withUser(t);
      const controller = new AuthController(t.service);
      await expect(
        controller.loginPasscode({
          ...PHONE,
          passcode: PASSCODE,
          device_token: 'x',
        }),
      ).rejects.toMatchObject({ response: { code: 'DEVICE_NOT_TRUSTED' } });
    });
  });

  describe('request validation', () => {
    const errors = async (cls: new () => object, body: object) =>
      (await validate(plainToInstance(cls, body))).map((e) => e.property);

    it('/login: token + passcode is enough', async () => {
      expect(
        await errors(LoginDto, {
          passcode: PASSCODE,
          otpVerificationToken: 'abc',
        }),
      ).toEqual([]);
    });
    it('/login: phone + passcode without a token is refused (no passcode-only login)', async () => {
      expect(await errors(LoginDto, { ...PHONE, passcode: PASSCODE })).toEqual([
        'otpVerificationToken',
      ]);
    });
    it('/login/passcode: a missing device_token is left to the device check (401 DEVICE_NOT_TRUSTED)', async () => {
      expect(
        await errors(PasscodeLoginDto, { ...PHONE, passcode: PASSCODE }),
      ).toEqual([]);
      expect(
        await errors(PasscodeLoginDto, {
          ...PHONE,
          passcode: PASSCODE,
          device_token: 't',
          device_id: 'x'.repeat(129),
        }),
      ).toEqual(['device_id']);
    });

    it('/login/passcode without device_token: 401 DEVICE_NOT_TRUSTED', async () => {
      const t = setup();
      await withUser(t);
      await expect(
        t.service.loginWithDevice({ ...PHONE, passcode: PASSCODE }),
      ).rejects.toMatchObject({
        response: { code: 'DEVICE_NOT_TRUSTED' },
      });
    });
  });
});
