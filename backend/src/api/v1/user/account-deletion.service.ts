import {
  BadRequestException,
  Inject,
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, IsNull, LessThanOrEqual, MoreThan, Repository } from 'typeorm';
import {
  AdminNotificationType,
  AuthSessionEntity,
  OtpRequestEntity,
  SendPendingRequestEntity,
  SwapEntity,
  SwapStatus,
  TransactionEntity,
  TransactionStatus,
  UserEntity,
  UserSecurityEntity,
  WalletEntity,
} from '@common/database/model';
import { IAdminNotifier } from '@common/services/admin-notifier/admin-notifier.interface';
import { TrustedDeviceService } from '@common/services/trusted-device/trusted-device.service';
import { AuthService } from '../auth/auth.service';

/** Grace period promised in the app: logging in again within it cancels the deletion */
export const DELETION_GRACE_DAYS = 7;
/** How often the server looks for accounts whose grace period has ended */
const PURGE_INTERVAL_MS = 60 * 60 * 1000;

const HAS_BALANCE = {
  status: 'error',
  code: 'ACCOUNT_HAS_BALANCE',
  message:
    'You still have funds in your wallets. Please withdraw or transfer your entire balance before deleting your account.',
  message_ar:
    'لا يزال لديك رصيد في محافظك. يرجى سحب أو تحويل كامل رصيدك قبل حذف حسابك.',
};
const HAS_PENDING = {
  status: 'error',
  code: 'ACCOUNT_HAS_PENDING_ACTIVITY',
  message:
    'You have a transfer or swap in progress. Please wait until it finishes before deleting your account.',
  message_ar:
    'لديك عملية تحويل أو تبديل قيد التنفيذ. يرجى الانتظار حتى تكتمل قبل حذف حسابك.',
};

/**
 * Account deletion (stage 2).
 *
 * 1. POST /user/settings/request-deletion (passcode required): refused while the user has any
 *    balance or a transfer/swap in progress. Otherwise the deletion is scheduled for
 *    DELETION_GRACE_DAYS later, every session and remembered device is logged out.
 * 2. Logging in again before then cancels it (AuthService.passcodeLogin).
 * 3. Afterwards (checked hourly) personal data is erased: phone (the number can register
 *    again), email, photo, Binance API keys, passcode, sessions, devices, codes. Transactions,
 *    swaps, wallets and KYC records stay, tied to the anonymous user ID, for the legal retention
 *    period. The Binance sub-account and the Sumsub file are left as they are (frozen: no API
 *    keys on our side) and admins are told. If funds or activity appeared during the grace
 *    period, nothing is erased and admins are told instead.
 */
@Injectable()
export class AccountDeletionService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(AccountDeletionService.name);
  private timer: NodeJS.Timeout | null = null;

  constructor(
    @InjectRepository(UserEntity)
    private readonly users: Repository<UserEntity>,
    @InjectRepository(UserSecurityEntity)
    private readonly security: Repository<UserSecurityEntity>,
    @InjectRepository(AuthSessionEntity)
    private readonly sessions: Repository<AuthSessionEntity>,
    @InjectRepository(OtpRequestEntity)
    private readonly otps: Repository<OtpRequestEntity>,
    @InjectRepository(WalletEntity)
    private readonly wallets: Repository<WalletEntity>,
    @InjectRepository(TransactionEntity)
    private readonly transactions: Repository<TransactionEntity>,
    @InjectRepository(SwapEntity)
    private readonly swaps: Repository<SwapEntity>,
    @InjectRepository(SendPendingRequestEntity)
    private readonly pendingSends: Repository<SendPendingRequestEntity>,
    private readonly authService: AuthService,
    private readonly trustedDevices: TrustedDeviceService,
    @Inject(IAdminNotifier) private readonly adminNotifier: IAdminNotifier,
  ) {}

  onModuleInit() {
    if (process.env.NODE_ENV === 'test') return;
    this.timer = setInterval(() => void this.purgeDue(), PURGE_INTERVAL_MS);
    this.timer.unref();
  }

  onModuleDestroy() {
    if (this.timer) clearInterval(this.timer);
  }

  async requestDeletion(userId: string, sessionId: string, passcode: string) {
    // Checks the passcode; wrong tries count toward the 5-try lockout
    await this.authService.softLogin(userId, sessionId, { passcode });

    const blocker = await this.moneyBlocker(userId);
    if (blocker) throw new BadRequestException(blocker);

    const now = new Date();
    const scheduledFor = new Date(
      now.getTime() + DELETION_GRACE_DAYS * 24 * 60 * 60 * 1000,
    );
    await this.users.update(
      { id: userId },
      { deletionRequestedAt: now, deletionScheduledFor: scheduledFor },
    );
    await this.logOutEverywhere(userId);
    await this.notifyAdmins(
      'Account deletion requested',
      `User ${userId} asked to delete their account. It will be anonymized on ${scheduledFor.toISOString()} unless they log in again.`,
    );

    return {
      status: 'success',
      message:
        'Account deletion scheduled. You have 7 days to cancel by logging in again.',
      message_ar:
        'تمت جدولة حذف الحساب. لديك 7 أيام للإلغاء عن طريق تسجيل الدخول مرة أخرى.',
      data: { deletion_scheduled_for: scheduledFor.toISOString() },
    };
  }

  /** Anonymizes every account whose grace period has ended. Returns how many were erased. */
  async purgeDue(now = new Date()): Promise<number> {
    let erased = 0;
    try {
      const due = await this.users.find({
        where: {
          deletionScheduledFor: LessThanOrEqual(now),
          anonymizedAt: IsNull(),
        },
        take: 50,
      });
      for (const user of due) {
        if (await this.anonymize(user)) erased++;
      }
    } catch (error) {
      this.logger.error(
        `Account deletion run failed: ${error instanceof Error ? error.message : 'unknown error'}`,
      );
    }
    return erased;
  }

  private async anonymize(user: UserEntity): Promise<boolean> {
    const blocker = await this.moneyBlocker(user.id);
    if (blocker) {
      // Funds or activity appeared during the grace period: never erase an account holding money
      await this.users.update({ id: user.id }, { deletionScheduledFor: null });
      await this.notifyAdmins(
        'Account deletion stopped',
        `User ${user.id} was due for deletion but has ${blocker.code === 'ACCOUNT_HAS_BALANCE' ? 'a balance' : 'a transfer or swap in progress'}. Nothing was erased; please review.`,
      );
      return false;
    }

    const oldPhone = user.fullMobileNumber;
    await this.logOutEverywhere(user.id);
    await this.security.delete({ userId: user.id });
    await this.otps.delete({ fullMobileNumber: oldPhone });

    // 20 characters, never a valid phone number, unique per user
    const placeholder = `X${user.id.replace(/-/g, '').slice(0, 19)}`;
    const result = await this.users.update(
      { id: user.id, anonymizedAt: IsNull() },
      {
        countryCode: '',
        mobileNumber: '',
        fullMobileNumber: placeholder,
        email: null,
        isEmailVerified: false,
        emailVerifiedAt: null,
        profileImageUrl: null,
        profileImageUpdatedAt: null,
        binanceApiKey: null,
        binanceSecretKey: null,
        binanceApiKeyCreatedAt: null,
        isActive: false,
        anonymizedAt: new Date(),
      },
    );
    if (!result.affected) return false;

    await this.notifyAdmins(
      'Account deleted',
      `User ${user.id} was anonymized after the ${DELETION_GRACE_DAYS}-day grace period. ` +
        `Transactions and KYC records are kept. Binance sub-account ${user.binanceSubaccountId ?? '(none)'} is frozen (no API keys); close it at Binance if needed.`,
    );
    return true;
  }

  /** Why the account cannot be deleted now (money), or null */
  private async moneyBlocker(userId: string) {
    const funded = await this.wallets.count({
      where: [
        { userId, balance: MoreThan('0') },
        { userId, lockedBalance: MoreThan('0') },
      ],
    });
    if (funded > 0) return HAS_BALANCE;

    const [txs, swaps, sends] = await Promise.all([
      this.transactions.count({
        where: {
          userId,
          status: In([TransactionStatus.PENDING, TransactionStatus.PROCESSING]),
        },
      }),
      this.swaps.count({ where: { userId, status: SwapStatus.PENDING } }),
      this.pendingSends.count({
        where: { userId, expiresAt: MoreThan(new Date()) },
      }),
    ]);
    return txs + swaps + sends > 0 ? HAS_PENDING : null;
  }

  private async logOutEverywhere(userId: string) {
    await this.sessions.update(
      { userId, isRevoked: false },
      { isRevoked: true },
    );
    await this.trustedDevices.revokeAllForUser(userId);
  }

  private async notifyAdmins(title: string, detail: string) {
    try {
      await this.adminNotifier.notifyAllAdmins(
        AdminNotificationType.USER,
        title,
        detail,
      );
    } catch (error) {
      this.logger.error(
        `Failed to notify admins: ${error instanceof Error ? error.message : 'unknown error'}`,
      );
    }
  }
}
