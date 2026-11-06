import {
  BadRequestException,
  ConflictException,
  Injectable,
  InternalServerErrorException,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  OtpPurpose,
  OtpRequestEntity,
  UserEntity,
} from '@common/database/model';
import { generateHash, generateOTP } from '@common/filters';
import { MailService } from '@common/services/mail/mail.service';
import { maskEmail } from '@common/utils';

/** The verification email says the code is valid for 5 minutes */
const EMAIL_OTP_EXPIRY_SECONDS = 5 * 60;
/** The app lets the user ask for a new code after 30 seconds */
const EMAIL_OTP_RESEND_COOLDOWN_SECONDS = 30;
const EMAIL_OTP_MAX_ATTEMPTS = 3;

const EMAIL_IN_USE = {
  status: 'error',
  code: 'EMAIL_IN_USE',
  message: 'This email is used by another account.',
  message_ar: 'هذا البريد الإلكتروني مستخدم في حساب آخر.',
};
const EMAIL_ALREADY_VERIFIED = {
  status: 'error',
  code: 'EMAIL_ALREADY_VERIFIED',
  message:
    'Your account already has a verified email. Use Change email in Settings to replace it.',
  message_ar:
    'لديك بريد إلكتروني موثّق بالفعل. استخدم "تغيير البريد الإلكتروني" في الإعدادات لاستبداله.',
};

/**
 * Adding an email to the account (stage 5): POST /user/email/request {email} sends a 6-digit
 * code to that address; POST /user/email/verify {otp} saves it as the account's verified email.
 * Only for accounts without a verified email (replacing one is Change email, stage 7). An email
 * verified on another account is refused. The email is saved only once the code is confirmed.
 */
@Injectable()
export class EmailVerificationService {
  private readonly logger = new Logger(EmailVerificationService.name);

  constructor(
    @InjectRepository(UserEntity)
    private readonly users: Repository<UserEntity>,
    @InjectRepository(OtpRequestEntity)
    private readonly otps: Repository<OtpRequestEntity>,
    private readonly mailService: MailService,
  ) {}

  async request(userId: string, rawEmail: string) {
    // In production, without Postmark nothing would be sent: say so instead of "code sent"
    if (process.env.NODE_ENV === 'production' && !this.mailService.isEnabled) {
      throw new ServiceUnavailableException({
        status: 'error',
        code: 'EMAIL_NOT_AVAILABLE',
        message:
          'Email verification is not available right now. Please try again later.',
        message_ar:
          'توثيق البريد الإلكتروني غير متاح حاليًا. يرجى المحاولة لاحقًا.',
      });
    }
    const email = rawEmail.trim().toLowerCase();
    const user = await this.getUser(userId);
    if (user.isEmailVerified && user.email) {
      throw new BadRequestException(EMAIL_ALREADY_VERIFIED);
    }
    await this.assertNotUsedElsewhere(email, user.id);

    const existing = await this.otps.findOne({
      where: {
        fullMobileNumber: user.fullMobileNumber,
        purpose: OtpPurpose.EMAIL_VERIFICATION,
      },
      order: { createdAt: 'DESC' },
    });
    if (existing?.lastResendAt) {
      const elapsed = (Date.now() - existing.lastResendAt.getTime()) / 1000;
      if (elapsed < EMAIL_OTP_RESEND_COOLDOWN_SECONDS) {
        const wait = Math.ceil(EMAIL_OTP_RESEND_COOLDOWN_SECONDS - elapsed);
        throw new BadRequestException({
          status: 'error',
          message: `Please wait ${wait} seconds before requesting a new code.`,
          message_ar: `يرجى الانتظار ${wait} ثانية قبل طلب رمز جديد.`,
        });
      }
    }

    const otp = generateOTP();
    await this.otps.delete({
      fullMobileNumber: user.fullMobileNumber,
      purpose: OtpPurpose.EMAIL_VERIFICATION,
    });
    await this.otps.save({
      fullMobileNumber: user.fullMobileNumber,
      email,
      otpHash: generateHash(otp),
      purpose: OtpPurpose.EMAIL_VERIFICATION,
      expiresAt: new Date(Date.now() + EMAIL_OTP_EXPIRY_SECONDS * 1000),
      attempts: 0,
      maxAttempts: EMAIL_OTP_MAX_ATTEMPTS,
      resendAttempts: 0,
      lastResendAt: new Date(),
    });

    try {
      await this.mailService.sendVerificationEmail(email, otp);
    } catch (error) {
      this.logger.error(
        `Email verification code could not be sent for user ${userId}: ${error instanceof Error ? error.message : 'unknown error'}`,
      );
      throw new InternalServerErrorException({
        status: 'error',
        message: 'We could not send the email. Please try again later.',
        message_ar: 'تعذّر إرسال البريد الإلكتروني. يرجى المحاولة لاحقًا.',
      });
    }

    return {
      status: 'success',
      message: 'Verification code sent to your email.',
      message_ar: 'تم إرسال رمز التحقق إلى بريدك الإلكتروني.',
      data: {
        masked_email: maskEmail(email),
        otp_expiry_seconds: EMAIL_OTP_EXPIRY_SECONDS,
        ...(process.env.NODE_ENV === 'development' && { email_otp: otp }),
      },
    };
  }

  async verify(userId: string, otp: string) {
    const user = await this.getUser(userId);
    if (user.isEmailVerified && user.email) {
      throw new BadRequestException(EMAIL_ALREADY_VERIFIED);
    }
    const request = await this.otps.findOne({
      where: {
        fullMobileNumber: user.fullMobileNumber,
        purpose: OtpPurpose.EMAIL_VERIFICATION,
      },
      order: { createdAt: 'DESC' },
    });
    if (!request || !request.email || request.isConsumed) {
      throw new BadRequestException({
        status: 'error',
        message: 'Code not found. Please request a new code.',
        message_ar: 'لم يتم العثور على الرمز. يرجى طلب رمز جديد.',
      });
    }
    if (request.expiresAt < new Date()) {
      throw new BadRequestException({
        status: 'error',
        message: 'The code has expired. Please request a new code.',
        message_ar: 'انتهت صلاحية الرمز. يرجى طلب رمز جديد.',
      });
    }
    if (generateHash(otp) !== request.otpHash) {
      request.attempts += 1;
      const remaining = request.maxAttempts - request.attempts;
      if (remaining <= 0) {
        await this.otps.delete({ id: request.id });
        throw new BadRequestException({
          status: 'error',
          code: 'OTP_ATTEMPTS_EXCEEDED',
          message: 'Too many incorrect codes. Please request a new code.',
          message_ar: 'محاولات خاطئة كثيرة. يرجى طلب رمز جديد.',
        });
      }
      await this.otps.save(request);
      throw new BadRequestException({
        status: 'error',
        code: 'EMAIL_OTP_INVALID',
        message: 'Invalid verification code. Please try again.',
        message_ar: 'رمز التحقق غير صحيح. يرجى المحاولة مرة أخرى.',
        data: { remaining_attempts: remaining },
      });
    }

    // Someone else may have verified the same email in the meantime
    await this.assertNotUsedElsewhere(request.email, user.id);

    request.isConsumed = true;
    await this.otps.save(request);
    await this.users.update(
      { id: user.id },
      {
        email: request.email,
        isEmailVerified: true,
        emailVerifiedAt: new Date(),
      },
    );

    return {
      status: 'success',
      message: 'Your email has been verified.',
      message_ar: 'تم توثيق بريدك الإلكتروني.',
      data: { email: request.email },
    };
  }

  private async getUser(userId: string): Promise<UserEntity> {
    const user = await this.users.findOne({ where: { id: userId } });
    if (!user) {
      throw new BadRequestException({
        status: 'error',
        message: 'User not found.',
      });
    }
    return user;
  }

  private async assertNotUsedElsewhere(email: string, userId: string) {
    const owner = await this.users.findOne({
      where: { email, isEmailVerified: true },
    });
    if (owner && owner.id !== userId) {
      throw new ConflictException(EMAIL_IN_USE);
    }
  }
}
