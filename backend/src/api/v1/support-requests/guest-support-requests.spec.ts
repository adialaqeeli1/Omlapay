/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-argument --
   the in-memory repositories are untyped stand-ins for TypeORM */
import { NotFoundException } from '@nestjs/common';
import { FakeRepo } from '@common/testing/fake-repo';
import { AdminTicketsService } from '../admin-tickets/admin-tickets.service';
import { SupportRequestsService } from './support-requests.service';

function setup() {
  const requests = new FakeRepo<any>();
  const responses = new FakeRepo<any>();
  const admins = { notifyAllAdmins: jest.fn().mockResolvedValue(undefined) };
  const service = new SupportRequestsService(
    requests as any,
    responses as any,
    new FakeRepo<any>() as any,
    admins as any,
  );
  return { requests, responses, admins, service };
}

const body = { title: 'Cannot log in', description: 'The code never arrives.' };

describe('Support without an account (stage 5b)', () => {
  it('the first request returns a new secret guest token, stored only as a hash', async () => {
    const t = setup();
    const res = await t.service.createGuestSupportRequest(body);
    const token = res.data.guest_token as string;
    expect(token).toMatch(/^[A-Za-z0-9_-]{43}$/);
    expect(t.requests.rows).toHaveLength(1);
    expect(t.requests.rows[0]).toMatchObject({
      userId: null,
      attachmentUrl: null,
      status: 'OPEN',
    });
    expect(t.requests.rows[0].guestTokenHash).toHaveLength(64);
    expect(JSON.stringify(t.requests.rows[0])).not.toContain(token);
    expect(t.admins.notifyAllAdmins).toHaveBeenCalledWith(
      expect.anything(),
      'New Support Ticket',
      expect.stringContaining('guest'),
    );
  });

  it('with its token, the same guest adds more requests (no new token)', async () => {
    const t = setup();
    const first = await t.service.createGuestSupportRequest(body);
    const token = first.data.guest_token;
    const second = await t.service.createGuestSupportRequest(body, token);
    expect(second.data).not.toHaveProperty('guest_token');
    expect(t.requests.rows[1].guestTokenHash).toBe(
      t.requests.rows[0].guestTokenHash,
    );
  });

  it('a made-up token is not accepted: the server issues its own', async () => {
    const t = setup();
    const made = 'A'.repeat(43);
    const res = await t.service.createGuestSupportRequest(body, made);
    expect(res.data.guest_token).toBeDefined();
    expect(res.data.guest_token).not.toBe(made);
  });

  it('a guest reads its own request with the token; nobody else can', async () => {
    const t = setup();
    const a = await t.service.createGuestSupportRequest(body);
    const b = await t.service.createGuestSupportRequest({
      ...body,
      title: 'Other guest',
    });
    const aId = a.data.request.id;
    await t.responses.save({
      ticketId: aId,
      adminId: 'admin-1',
      message: 'We are on it.',
    });

    const mine = await t.service.getGuestSupportRequestDetails(
      a.data.guest_token,
      aId,
    );
    expect(mine.data.request).toMatchObject({
      id: aId,
      title: 'Cannot log in',
    });
    expect(mine.data.request.responses).toEqual([
      expect.objectContaining({
        message: 'We are on it.',
        isAdminResponse: true,
      }),
    ]);

    // another guest's token, no token, or a made-up token: not found
    for (const token of [b.data.guest_token, undefined, 'A'.repeat(43)]) {
      await expect(
        t.service.getGuestSupportRequestDetails(token, aId),
      ).rejects.toBeInstanceOf(NotFoundException);
    }
  });

  it('the list without a known token is empty (no guessing other guests by device)', async () => {
    const t = setup();
    await t.service.createGuestSupportRequest(body);
    const res = await t.service.getGuestSupportRequests(undefined, {
      page: 1,
      limit: 10,
    });
    expect(res.data).toEqual({
      requests: [],
      pagination: { page: 1, limit: 10, total: 0, totalPages: 0 },
    });
  });

  it('an account user cannot read a guest request through the account route', async () => {
    const t = setup();
    const a = await t.service.createGuestSupportRequest(body);
    await expect(
      t.service.getSupportRequestDetails(
        '11111111-1111-4111-8111-111111111111',
        a.data.request.id,
      ),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  describe('admin panel', () => {
    it('shows a guest ticket as "Guest" and replies without sending an email', async () => {
      const t = setup();
      const a = await t.service.createGuestSupportRequest(body);
      const id = a.data.request.id;
      t.requests.rows[0].user = null;
      const mail = { sendTicketResponse: jest.fn() };
      const admin = new AdminTicketsService(
        t.requests as any,
        t.responses as any,
        new FakeRepo<any>() as any,
        mail as any,
        t.admins as any,
      );

      const details = await admin.getTicketDetails(id);
      expect(details.user).toEqual({
        email: '—',
        phoneNumber: '—',
        fullName: 'Guest (no account)',
      });

      await admin.addTicketResponse(id, 'admin-1', {
        message: 'Hello guest',
      } as any);
      expect(mail.sendTicketResponse).not.toHaveBeenCalled();
      expect(t.responses.rows.at(-1)).toMatchObject({
        ticketId: id,
        message: 'Hello guest',
      });
    });
  });
});
