import { ConfigService } from '@nestjs/config';
import { MailService } from './mail.service';

const config = (values: Record<string, string>) =>
  ({ get: (key: string) => values[key] }) as unknown as ConfigService;

const POSTMARK = {
  POSTMARK_SERVER_TOKEN: 'server-token',
  MAIL_FROM_EMAIL: 'noreply@omlapay.org',
};
const MAILGUN = {
  MAILGUN_API_KEY: 'key',
  MAILGUN_SANDBOX_DOMAIN: 'mg.example.com',
  MAILGUN_BASE_URL: 'https://api.mailgun.net',
};

describe('MailService', () => {
  let fetchMock: jest.Mock;

  beforeEach(() => {
    fetchMock = jest.fn();
    global.fetch = fetchMock;
  });

  const ok = (body: object) => ({
    ok: true,
    status: 200,
    statusText: 'OK',
    json: () => Promise.resolve(body),
  });

  it('sends through the Postmark API when POSTMARK_SERVER_TOKEN is set', async () => {
    fetchMock.mockResolvedValue(ok({ ErrorCode: 0, MessageID: 'abc' }));
    await new MailService(config(POSTMARK)).sendOTP(
      'user@example.com',
      '123456',
    );

    expect(fetchMock).toHaveBeenCalledTimes(1);
    const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(url).toBe('https://api.postmarkapp.com/email');
    expect(init.method).toBe('POST');
    expect(init.headers).toMatchObject({
      'X-Postmark-Server-Token': 'server-token',
      'Content-Type': 'application/json',
    });
    const body = JSON.parse(init.body as string) as Record<string, string>;
    expect(body).toMatchObject({
      From: 'Omlapay <noreply@omlapay.org>',
      To: 'user@example.com',
      MessageStream: 'outbound',
    });
    expect(body.TextBody).toContain('123456');
    expect(body.HtmlBody).toContain('123456');
  });

  it('uses POSTMARK_MESSAGE_STREAM, MAIL_FROM_NAME and POSTMARK_API_URL when set', async () => {
    fetchMock.mockResolvedValue(ok({ ErrorCode: 0, MessageID: 'abc' }));
    await new MailService(
      config({
        ...POSTMARK,
        POSTMARK_MESSAGE_STREAM: 'otp',
        MAIL_FROM_NAME: 'OmlaPay',
        POSTMARK_API_URL: 'http://localhost:9999/',
      }),
    ).sendOTP('user@example.com', '123456');

    const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(url).toBe('http://localhost:9999/email');
    expect(JSON.parse(init.body as string)).toMatchObject({
      From: 'OmlaPay <noreply@omlapay.org>',
      MessageStream: 'otp',
    });
  });

  it('throws when Postmark rejects the message', async () => {
    fetchMock.mockResolvedValue({
      ok: false,
      status: 422,
      statusText: 'Unprocessable Entity',
      json: () =>
        Promise.resolve({
          ErrorCode: 400,
          Message: 'Sender signature not defined',
        }),
    });
    await expect(
      new MailService(config(POSTMARK)).sendOTP('user@example.com', '123456'),
    ).rejects.toThrow(/ErrorCode 400.*Sender signature not defined/);
  });

  it('prefers Postmark when both providers are configured', async () => {
    fetchMock.mockResolvedValue(ok({ ErrorCode: 0, MessageID: 'abc' }));
    await new MailService(config({ ...MAILGUN, ...POSTMARK })).sendOTP(
      'u@example.com',
      '1',
    );
    expect(fetchMock).toHaveBeenCalledWith(
      'https://api.postmarkapp.com/email',
      expect.anything(),
    );
  });

  it('still sends through Mailgun when only Mailgun is configured', async () => {
    fetchMock.mockResolvedValue(ok({ id: 'mg-1' }));
    await new MailService(config(MAILGUN)).sendOTP('u@example.com', '1');
    expect(fetchMock).toHaveBeenCalledWith(
      'https://api.mailgun.net/v3/mg.example.com/messages',
      expect.anything(),
    );
  });

  it('sends nothing and does not fail when no provider is configured', async () => {
    await new MailService(config({})).sendOTP('u@example.com', '1');
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('sends nothing when the Postmark token is set without MAIL_FROM_EMAIL', async () => {
    await new MailService(
      config({ POSTMARK_SERVER_TOKEN: 'server-token' }),
    ).sendOTP('u@example.com', '1');
    expect(fetchMock).not.toHaveBeenCalled();
  });
});
