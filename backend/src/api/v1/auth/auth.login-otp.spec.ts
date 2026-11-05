/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-return --
   the in-memory repositories below are untyped stand-ins for TypeORM */
import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import * as bcrypt from 'bcryptjs';
import { OtpPurpose } from '@common/database/model';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { LoginDto } from './dto/login.dto';

/** Tiny in-memory stand-in for a TypeORM repository (findOne / save / delete on equal fields). */
class FakeRepo<T extends { id?: string; createdAt?: Date }> {
  rows: T[] = [];
  private seq = 0;
  private matches(row: T, where: Partial<T>) {
    return Object.entries(where).every(([k, v]) => (row as any)[k] === v);
  }
  findOne(opts: { where: Partial<T> }) {
    const found = this.rows.filter((r) => this.matches(r, opts.where));
    return Promise.resolve(found.length ? found[found.length - 1] : null);
  }
  save(entity: Partial<T>) {
    if (!entity.id) {
      entity.id = `id-${++this.seq}`;
      entity.createdAt = new Date();
      this.rows.push(entity as T);
    }
    return Promise.resolve(entity as T);
  }
  delete(where: Partial<T>) {
    const before = this.rows.length;
    this.rows = this.rows.filter((r) => !this.matches(r, where));
    return Promise.resolve({ affected: before - this.rows.length });
  }
}

const PHONE = { country_code: '+966', mobile_number: '0512345678' };
const FULL = '+966512345678';
const PASSCODE = '135790';

function setup() {
  const users = new FakeRepo<any>();
  const security = new FakeRepo<any>();
  const settings = new FakeRepo<any>();
  const sessions = new FakeRepo<any>();
  const otps = new FakeRepo<any>();
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
  );
  const lastCode = () => sms.sendOTP.mock.calls.at(-1)[1] as string;
  return { users, security, sessions, otps, jwt, sms, service, lastCode };
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

  describe('phone + passcode (POST /auth/login and /auth/login/passcode)', () => {
    it('still works and still enforces Saudi-only numbers', async () => {
      const t = setup();
      await withUser(t);
      const res = await t.service.login({ ...PHONE, passcode: PASSCODE });
      expect(res.data.access_token).toBeTruthy();
      await expect(
        t.service.login({
          country_code: '+1',
          mobile_number: '5551234567',
          passcode: PASSCODE,
        }),
      ).rejects.toMatchObject({ response: { code: 'PHONE_NOT_ALLOWED' } });
    });

    it('/login/passcode ignores a token and always checks the phone number', async () => {
      const t = setup();
      await withUser(t);
      const token = await codeToken(t);
      const controller = new AuthController(t.service);
      await expect(
        controller.loginPasscode({
          passcode: PASSCODE,
          otpVerificationToken: token,
        } as LoginDto),
      ).rejects.toMatchObject({ response: { code: 'PHONE_NOT_ALLOWED' } });
    });
  });

  describe('LoginDto validation', () => {
    const errors = async (body: object) =>
      (await validate(plainToInstance(LoginDto, body))).map((e) => e.property);

    it('token + passcode is enough', async () => {
      expect(
        await errors({ passcode: PASSCODE, otpVerificationToken: 'abc' }),
      ).toEqual([]);
    });
    it('without a token the phone number is required', async () => {
      expect(await errors({ passcode: PASSCODE })).toEqual([
        'country_code',
        'mobile_number',
      ]);
    });
    it('the passcode is always required', async () => {
      expect(await errors({ otpVerificationToken: 'abc' })).toEqual([
        'passcode',
      ]);
    });
  });
});
