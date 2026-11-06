/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-return --
   the in-memory repositories are untyped stand-ins for TypeORM */
import { BadRequestException, ConflictException } from '@nestjs/common';
import { FakeRepo } from '@common/testing/fake-repo';
import { EmailVerificationService } from './email-verification.service';

function setup() {
  const users = new FakeRepo<any>();
  const otps = new FakeRepo<any>();
  const mail = {
    isEnabled: true,
    sendVerificationEmail: jest.fn().mockResolvedValue(undefined),
  };
  const service = new EmailVerificationService(
    users as any,
    otps as any,
    mail as any,
  );
  const lastCode = () =>
    mail.sendVerificationEmail.mock.calls.at(-1)[1] as string;
  return { users, otps, mail, service, lastCode };
}

async function withUser(t: ReturnType<typeof setup>, extra: object = {}) {
  return t.users.save({
    fullMobileNumber: '+966512345678',
    email: null,
    isEmailVerified: false,
    ...extra,
  });
}

/** Lets the 30-second resend cooldown pass. */
function waitCooldown(t: ReturnType<typeof setup>) {
  t.otps.rows.forEach((r) => (r.lastResendAt = new Date(Date.now() - 31_000)));
}

describe('Email verification (stage 5a)', () => {
  const env = process.env.NODE_ENV;
  afterEach(() => (process.env.NODE_ENV = env));

  it('sends a code to the email; the email is saved only after the code is confirmed', async () => {
    const t = setup();
    const user = await withUser(t);
    process.env.NODE_ENV = 'production';
    const res = await t.service.request(user.id, ' Name@Example.com ');
    expect(t.mail.sendVerificationEmail).toHaveBeenCalledWith(
      'name@example.com',
      expect.stringMatching(/^\d{6}$/),
    );
    expect(res.data).toMatchObject({
      otp_expiry_seconds: 300,
      masked_email: expect.any(String),
    });
    expect(res.data).not.toHaveProperty('email_otp'); // only in development
    expect(t.otps.rows[0].otpHash).not.toBe(t.lastCode());
    expect(user.email).toBeNull();

    const ok = await t.service.verify(user.id, t.lastCode());
    expect(ok.message_ar).toBeTruthy();
    expect(user).toMatchObject({
      email: 'name@example.com',
      isEmailVerified: true,
    });
    expect(user.emailVerifiedAt).toBeInstanceOf(Date);
  });

  it('shows the code in the response only in development', async () => {
    const t = setup();
    const user = await withUser(t);
    process.env.NODE_ENV = 'development';
    const res = await t.service.request(user.id, 'a@b.co');
    expect((res.data as any).email_otp).toBe(t.lastCode());
  });

  it('refuses an email verified on another account (409, English/Arabic), at request and at verify', async () => {
    const t = setup();
    const user = await withUser(t);
    const other = await withUser(t, {
      fullMobileNumber: '+966598765432',
      email: 'taken@b.co',
      isEmailVerified: true,
    });
    await expect(
      t.service.request(user.id, 'TAKEN@b.co'),
    ).rejects.toMatchObject({
      response: { code: 'EMAIL_IN_USE', message_ar: expect.any(String) },
    });
    expect(t.mail.sendVerificationEmail).not.toHaveBeenCalled();

    // the other account verifies the same email after this user asked for a code
    await t.service.request(user.id, 'race@b.co');
    other.email = 'race@b.co';
    await expect(
      t.service.verify(user.id, t.lastCode()),
    ).rejects.toBeInstanceOf(ConflictException);
    expect(user.isEmailVerified).toBe(false);
  });

  it('an unverified email on another account does not block', async () => {
    const t = setup();
    const user = await withUser(t);
    await withUser(t, {
      fullMobileNumber: '+966598765432',
      email: 'a@b.co',
      isEmailVerified: false,
    });
    await t.service.request(user.id, 'a@b.co');
    await expect(
      t.service.verify(user.id, t.lastCode()),
    ).resolves.toMatchObject({ status: 'success' });
  });

  it('an account with a verified email must use Change email', async () => {
    const t = setup();
    const user = await withUser(t, {
      email: 'mine@b.co',
      isEmailVerified: true,
    });
    await expect(t.service.request(user.id, 'new@b.co')).rejects.toMatchObject({
      response: { code: 'EMAIL_ALREADY_VERIFIED' },
    });
  });

  it('a new code only after 30 seconds; the newest code replaces the old one', async () => {
    const t = setup();
    const user = await withUser(t);
    await t.service.request(user.id, 'a@b.co');
    const first = t.lastCode();
    await expect(t.service.request(user.id, 'a@b.co')).rejects.toThrow(
      /wait \d+ seconds/,
    );
    waitCooldown(t);
    await t.service.request(user.id, 'c@d.co');
    expect(t.otps.rows).toHaveLength(1);
    if (first !== t.lastCode()) {
      await expect(t.service.verify(user.id, first)).rejects.toBeInstanceOf(
        BadRequestException,
      );
    }
    await t.service.verify(user.id, t.lastCode());
    expect(user.email).toBe('c@d.co'); // the address of the newest request
  });

  it('3 wrong codes cancel the code', async () => {
    const t = setup();
    const user = await withUser(t);
    await t.service.request(user.id, 'a@b.co');
    const wrong = t.lastCode() === '000000' ? '111111' : '000000';
    await expect(t.service.verify(user.id, wrong)).rejects.toMatchObject({
      response: { code: 'EMAIL_OTP_INVALID', data: { remaining_attempts: 2 } },
    });
    await expect(t.service.verify(user.id, wrong)).rejects.toMatchObject({
      response: { data: { remaining_attempts: 1 } },
    });
    await expect(t.service.verify(user.id, wrong)).rejects.toMatchObject({
      response: { code: 'OTP_ATTEMPTS_EXCEEDED' },
    });
    await expect(t.service.verify(user.id, t.lastCode())).rejects.toThrow(
      /not found/,
    );
    expect(user.isEmailVerified).toBe(false);
  });

  it('an expired code is refused; a used code cannot be used again', async () => {
    const t = setup();
    const user = await withUser(t);
    await t.service.request(user.id, 'a@b.co');
    t.otps.rows[0].expiresAt = new Date(Date.now() - 1000);
    await expect(t.service.verify(user.id, t.lastCode())).rejects.toThrow(
      /expired/,
    );
    waitCooldown(t);
    await t.service.request(user.id, 'a@b.co');
    await t.service.verify(user.id, t.lastCode());
    await expect(t.service.verify(user.id, t.lastCode())).rejects.toMatchObject(
      {
        response: { code: 'EMAIL_ALREADY_VERIFIED' },
      },
    );
  });

  it('if the email cannot be sent, the user gets a clear error', async () => {
    const t = setup();
    const user = await withUser(t);
    t.mail.sendVerificationEmail.mockRejectedValueOnce(
      new Error('Postmark down'),
    );
    await expect(t.service.request(user.id, 'a@b.co')).rejects.toMatchObject({
      response: { message_ar: expect.any(String) },
    });
  });

  it('in production without an email provider, says email is not available (nothing is "sent")', async () => {
    const t = setup();
    const user = await withUser(t);
    process.env.NODE_ENV = 'production';
    t.mail.isEnabled = false;
    await expect(t.service.request(user.id, 'a@b.co')).rejects.toMatchObject({
      response: { code: 'EMAIL_NOT_AVAILABLE', message_ar: expect.any(String) },
    });
    expect(t.mail.sendVerificationEmail).not.toHaveBeenCalled();
    expect(t.otps.rows).toHaveLength(0);
  });
});
