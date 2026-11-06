import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  ConflictException,
  InternalServerErrorException,
  HttpException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { UserEntity } from '@common/database/model';
import { UserSecurityEntity } from '@common/database/model';
import { UserSettingsEntity } from '@common/database/model';
import { AuthSessionEntity } from '@common/database/model';
import {
  OtpRequestEntity,
  OtpPurpose,
} from '@common/database/model';
import { generateOTP, generateHash } from '@common/filters';
import {
  maskEmail,
  maskPhoneNumber,
  normalizePhoneDto,
  validateRequired,
  buildFullMobileNumber,
  validateAccountActive,
  validateToken,
  validatePasscodeMatch,
} from '@common/utils';
import { LoginDto } from './dto/login.dto';
import { PasscodeLoginDto } from './dto/passcode-login.dto';
import { ResendOtpDto } from './dto/resend-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { CheckUserDto } from './dto/check-user.dto';
import { SoftLoginDto } from './dto/soft-login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ForgotPasscodeDto } from './dto/forgot-passcode.dto';
import { ForgotPasscodeVerifyOtpDto } from './dto/forgot-passcode-verify-otp.dto';
import { ForgotPasscodeResendOtpDto } from './dto/forgot-passcode-resend-otp.dto';
import { ResetPasscodeDto } from '../user/dto/reset-passcode.dto';
import { OtpService } from '@common/services/otp/otp.service';
import { MailService } from '@common/services/mail/mail.service';
import {
  IssuedDeviceToken,
  TrustedDeviceService,
} from '@common/services/trusted-device/trusted-device.service';

// Login with an SMS code (POST /auth/login/send-otp, resend-otp, verify-otp, then /auth/login)
const LOGIN_OTP_EXPIRY_SECONDS = 60;
const LOGIN_OTP_RESEND_COOLDOWN_SECONDS = 60;
const LOGIN_OTP_MAX_RESENDS = 3;
const LOGIN_OTP_MAX_ATTEMPTS = 3;
const LOGIN_TOKEN_EXPIRY_SECONDS = 300;
const DEVICE_NOT_TRUSTED = {
  status: 'error',
  code: 'DEVICE_NOT_TRUSTED',
  message: 'Please log in with a verification code sent by SMS.',
  message_ar: 'يرجى تسجيل الدخول برمز التحقق المرسل عبر رسالة نصية.',
};
const LOGIN_TOKEN_INVALID = {
  status: 'error',
  code: 'LOGIN_TOKEN_INVALID',
  message: 'Your verification has expired. Please request a new code.',
  message_ar: 'انتهت صلاحية التحقق. يرجى طلب رمز جديد.',
};

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(UserSecurityEntity)
    private userSecurityRepository: Repository<UserSecurityEntity>,
    @InjectRepository(UserSettingsEntity)
    private userSettingsRepository: Repository<UserSettingsEntity>,
    @InjectRepository(AuthSessionEntity)
    private authSessionRepository: Repository<AuthSessionEntity>,
    @InjectRepository(OtpRequestEntity)
    private otpRepository: Repository<OtpRequestEntity>,
    private jwtService: JwtService,
    private otpService: OtpService,
    private mailService: MailService,
    private trustedDevices: TrustedDeviceService,
  ) {}

  /**
   * Check if a user exists for the given phone number (two-step login flow).
   * Returns userExists so client can show passcode screen or registration screen.
   */
  async checkUser(dto: CheckUserDto) {
    normalizePhoneDto(dto);

    const fullMobileNumber = buildFullMobileNumber(
      dto.country_code,
      dto.mobile_number,
    );

    const user = await this.userRepository.findOne({
      where: { fullMobileNumber },
    });

    if (!user) {
      return { status: 'success', data: { userExists: false } };
    }

    const userSecurity = await this.userSecurityRepository.findOne({
      where: { userId: user.id },
    });

    const hasPasscode = !!userSecurity?.passcodeHash;

    return {
      status: 'success',
      data: {
        userExists: true,
        hasPasscode,
      },
    };
  }

  /** POST /auth/login: passcode + otpVerificationToken (SMS code). Remembers this device. */
  async login(dto: LoginDto) {
    return this.passcodeLogin(dto, 'sms');
  }

  /** POST /auth/login/passcode: phone + passcode + device_token of a remembered device. */
  async loginWithDevice(dto: PasscodeLoginDto) {
    return this.passcodeLogin(dto, 'device');
  }

  private async passcodeLogin(
    dto: LoginDto | PasscodeLoginDto,
    mode: 'sms' | 'device',
  ) {
    try {
      validateRequired(dto.passcode, 'Passcode');

      // 'sms': the user is the one the SMS code was sent to.
      // 'device': the phone number, plus a device_token this phone got after an SMS check.
      let user: UserEntity | null;
      let loginOtpId: string | null = null;
      if (mode === 'sms') {
        ({ user, otpId: loginOtpId } = await this.resolveLoginOtpToken(
          (dto as LoginDto).otpVerificationToken,
        ));
      } else {
        const phone = dto as PasscodeLoginDto;
        normalizePhoneDto(phone);
        user = await this.userRepository.findOne({
          where: {
            fullMobileNumber: buildFullMobileNumber(
              phone.country_code,
              phone.mobile_number,
            ),
          },
        });
      }

      if (!user) {
        throw new BadRequestException({
          status: 'error',
          message: 'User not found with this mobile number.',
        });
      }
      const fullMobileNumber = user.fullMobileNumber;

      // Check if user account is active
      validateAccountActive(user.isActive);

      // Passcode only from a remembered device; anywhere else the user needs an SMS code.
      // Checked before the passcode, so without a device token passcodes cannot be guessed here.
      let trustedDeviceId: string | null = null;
      if (mode === 'device') {
        const device = await this.trustedDevices.find(
          user.id,
          (dto as PasscodeLoginDto).device_token,
          dto.device_id,
        );
        if (!device) {
          throw new UnauthorizedException(DEVICE_NOT_TRUSTED);
        }
        trustedDeviceId = device.id;
      }

      // Get user security record
      const userSecurity = await this.userSecurityRepository.findOne({
        where: { userId: user.id },
      });

      if (!userSecurity) {
        throw new UnauthorizedException({
          status: 'error',
          message: 'Passcode not set. Please set your passcode first.',
        });
      }

      // Check if account is locked
      if (userSecurity.lockedUntil && userSecurity.lockedUntil > new Date()) {
        const lockTimeRemaining = Math.ceil(
          (userSecurity.lockedUntil.getTime() - new Date().getTime()) /
            1000 /
            60,
        );
        throw new UnauthorizedException({
          status: 'error',
          message: `Account is temporarily locked. Please try again in ${lockTimeRemaining} minute(s).`,
        });
      }

      // Verify passcode
      const isPasscodeValid = await bcrypt.compare(
        dto.passcode,
        userSecurity.passcodeHash,
      );

      if (!isPasscodeValid) {
        // Increment failed attempts
        userSecurity.failedAttempts += 1;
        userSecurity.lastFailedAt = new Date();

        // Lock account after 5 failed attempts
        if (userSecurity.failedAttempts >= 5) {
          const lockUntil = new Date();
          lockUntil.setMinutes(lockUntil.getMinutes() + 15); // 15 minutes lockout
          userSecurity.lockedUntil = lockUntil;
          await this.userSecurityRepository.save(userSecurity);

          throw new UnauthorizedException({
            status: 'error',
            message: 'Too many failed attempts. Account locked for 15 minutes.',
          });
        }

        await this.userSecurityRepository.save(userSecurity);

        const remainingAttempts = 5 - userSecurity.failedAttempts;
        throw new UnauthorizedException({
          status: 'error',
          message: `Incorrect passcode. ${remainingAttempts > 0 ? `You have ${remainingAttempts} attempt(s) remaining.` : 'Account will be locked.'}`,
        });
      }

      // A login code token works for one login only
      if (loginOtpId) {
        const used = await this.otpRepository.delete({
          id: loginOtpId,
          purpose: OtpPurpose.LOGIN,
        });
        if (!used.affected) {
          throw new UnauthorizedException(LOGIN_TOKEN_INVALID);
        }
      }

      // Logging in during the deletion grace period cancels the deletion
      let deletionCancelled = false;
      if (user.deletionScheduledFor && !user.anonymizedAt) {
        await this.userRepository.update(
          { id: user.id },
          { deletionRequestedAt: null, deletionScheduledFor: null },
        );
        deletionCancelled = true;
      }

      // The SMS check makes this phone a remembered device; a device login refreshes lastUsedAt
      let issuedDevice: IssuedDeviceToken | null = null;
      if (mode === 'sms') {
        const issued = await this.trustedDevices.issue(user.id, dto.device_id);
        trustedDeviceId = issued.id;
        issuedDevice = issued.token;
      } else if (trustedDeviceId) {
        await this.trustedDevices.markUsed(trustedDeviceId);
      }

      // Reset failed attempts on successful login
      if (userSecurity.failedAttempts > 0) {
        userSecurity.failedAttempts = 0;
        userSecurity.lockedUntil = null;
        await this.userSecurityRepository.save(userSecurity);
      }

      const session = await this.createSession(user.id, trustedDeviceId);

      return {
        status: 'success',
        message: 'Login successful',
        data: {
          ...session,
          ...issuedDevice,
          ...(deletionCancelled && { deletion_cancelled: true }),
          user: {
            id: user.id,
            mobile_number: fullMobileNumber,
            status: user.isActive ? 'ACTIVE' : 'BLOCKED',
          },
        },
      };
    } catch (error) {
      // Re-throw BadRequestException and UnauthorizedException as-is
      if (
        error instanceof BadRequestException ||
        error instanceof UnauthorizedException
      ) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in passcodeLogin: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new InternalServerErrorException({
        status: 'error',
        message: 'Failed to process login request. Please try again later.',
      });
    }
  }

  /**
   * Opens a session (access token 1 day, refresh token 7 days). Also used to hand a fresh session
   * to the caller when an account change revokes all sessions (e.g. turning off 2FA), so the app
   * does not need the passcode to log in again.
   */
  async createSession(
    userId: string,
    trustedDeviceId: string | null = null,
  ): Promise<{
    access_token: string;
    refresh_token: string;
    expires_in: number;
  }> {
    const accessExpiresSeconds = 86400; // 1 day
    const session = await this.authSessionRepository.save({
      userId,
      accessTokenHash: '', // set below, after signing
      refreshTokenHash: '',
      expiresAt: new Date(Date.now() + accessExpiresSeconds * 1000),
      isRevoked: false,
      trustedDeviceId,
    });

    const accessToken = this.jwtService.sign(
      { userId, sessionId: session.id, type: 'access' },
      { expiresIn: accessExpiresSeconds },
    );
    const refreshToken = this.jwtService.sign(
      { userId, sessionId: session.id, type: 'refresh' },
      { expiresIn: '7d' },
    );

    session.accessTokenHash = generateHash(accessToken);
    session.refreshTokenHash = generateHash(refreshToken);
    await this.authSessionRepository.save(session);

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: accessExpiresSeconds,
    };
  }

  /**
   * Login step 1 (and resend): send a 6-digit code by SMS to an existing, active user.
   * Resend has a 60-second cooldown and at most 3 resends per code.
   */
  async sendLoginOtp(dto: ResendOtpDto, isResend = false) {
    try {
      normalizePhoneDto(dto);
      const fullMobileNumber = buildFullMobileNumber(
        dto.country_code,
        dto.mobile_number,
      );

      const user = await this.userRepository.findOne({
        where: { fullMobileNumber },
      });
      if (!user) {
        throw new BadRequestException({
          status: 'error',
          message: 'User not found with this mobile number.',
        });
      }
      validateAccountActive(user.isActive);

      let resendAttempts = 0;
      if (isResend) {
        const existing = await this.otpRepository.findOne({
          where: { fullMobileNumber, purpose: OtpPurpose.LOGIN },
          order: { createdAt: 'DESC' },
        });
        if (existing?.lastResendAt) {
          const elapsed = (Date.now() - existing.lastResendAt.getTime()) / 1000;
          if (elapsed < LOGIN_OTP_RESEND_COOLDOWN_SECONDS) {
            const wait = Math.ceil(LOGIN_OTP_RESEND_COOLDOWN_SECONDS - elapsed);
            throw new BadRequestException({
              status: 'error',
              message: `Please wait ${wait} seconds before requesting a new OTP.`,
            });
          }
        }
        if (existing && existing.resendAttempts >= LOGIN_OTP_MAX_RESENDS) {
          throw new BadRequestException({
            status: 'error',
            message: 'Maximum resend attempts reached. Please try again later.',
          });
        }
        resendAttempts = (existing?.resendAttempts ?? 0) + 1;
      }

      const otp = generateOTP();
      const expiresAt = new Date(Date.now() + LOGIN_OTP_EXPIRY_SECONDS * 1000);

      // Only the newest code (and the token made from it) is valid
      await this.otpRepository.delete({
        fullMobileNumber,
        purpose: OtpPurpose.LOGIN,
      });
      await this.otpRepository.save({
        fullMobileNumber,
        email: null,
        otpHash: generateHash(otp),
        purpose: OtpPurpose.LOGIN,
        expiresAt,
        attempts: 0,
        maxAttempts: LOGIN_OTP_MAX_ATTEMPTS,
        resendAttempts,
        lastResendAt: new Date(),
      });

      await this.otpService.sendOTP(fullMobileNumber, otp);

      return {
        status: 'success',
        message: isResend
          ? 'Verification code resent to your mobile number.'
          : 'Verification code sent to your mobile number.',
        data: {
          masked_mobile: maskPhoneNumber(fullMobileNumber),
          otp_expiry_seconds: LOGIN_OTP_EXPIRY_SECONDS,
          ...(process.env.NODE_ENV === 'development' && { mobile_otp: otp }),
        },
      };
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }
      this.logger.error(
        `Error in sendLoginOtp: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );
      throw new InternalServerErrorException({
        status: 'error',
        message: 'Failed to send verification code. Please try again later.',
      });
    }
  }

  /**
   * Login step 2: check the SMS code. Returns otpVerificationToken (5 minutes, one login),
   * which POST /auth/login takes with the passcode. 3 wrong codes cancel the code.
   */
  async verifyLoginOtp(dto: VerifyOtpDto) {
    try {
      normalizePhoneDto(dto);
      const fullMobileNumber = buildFullMobileNumber(
        dto.country_code,
        dto.mobile_number,
      );

      const user = await this.userRepository.findOne({
        where: { fullMobileNumber },
      });
      if (!user) {
        throw new BadRequestException({
          status: 'error',
          message: 'User not found with this mobile number.',
        });
      }
      validateAccountActive(user.isActive);

      const otpRequest = await this.otpRepository.findOne({
        where: { fullMobileNumber, purpose: OtpPurpose.LOGIN },
        order: { createdAt: 'DESC' },
      });
      if (!otpRequest) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP not found. Please request a new OTP.',
        });
      }
      if (otpRequest.isConsumed) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP has already been used. Please request a new OTP.',
        });
      }
      if (otpRequest.expiresAt < new Date()) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP has expired. Please request a new OTP.',
        });
      }

      if (generateHash(dto.otp) !== otpRequest.otpHash) {
        otpRequest.attempts += 1;
        const remainingAttempts = otpRequest.maxAttempts - otpRequest.attempts;
        if (remainingAttempts <= 0) {
          await this.otpRepository.delete({ id: otpRequest.id });
          throw new BadRequestException({
            status: 'error',
            code: 'OTP_ATTEMPTS_EXCEEDED',
            message: 'Too many incorrect codes. Please request a new OTP.',
          });
        }
        await this.otpRepository.save(otpRequest);
        throw new BadRequestException({
          status: 'error',
          message: 'Invalid verification code. Please try again.',
          code: 'MOBILE_OTP_INVALID',
          data: { remaining_attempts: remainingAttempts },
        });
      }

      otpRequest.isConsumed = true;
      await this.otpRepository.save(otpRequest);

      const otpVerificationToken = this.jwtService.sign(
        { userId: user.id, otpId: otpRequest.id, type: 'login_otp' },
        { expiresIn: LOGIN_TOKEN_EXPIRY_SECONDS },
      );

      return {
        status: 'success',
        message: 'OTP verification successful.',
        data: {
          otpVerificationToken,
          token_expiry_seconds: LOGIN_TOKEN_EXPIRY_SECONDS,
        },
      };
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }
      this.logger.error(
        `Error in verifyLoginOtp: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );
      throw new InternalServerErrorException({
        status: 'error',
        message: 'Failed to verify OTP. Please try again later.',
      });
    }
  }

  /** The user and code behind an otpVerificationToken; 401 if it is expired, used or replaced. */
  private async resolveLoginOtpToken(
    token: string,
  ): Promise<{ user: UserEntity; otpId: string }> {
    let payload: { userId?: string; otpId?: string; type?: string };
    try {
      payload = this.jwtService.verify(token);
    } catch {
      throw new UnauthorizedException(LOGIN_TOKEN_INVALID);
    }
    if (payload?.type !== 'login_otp' || !payload.userId || !payload.otpId) {
      throw new UnauthorizedException(LOGIN_TOKEN_INVALID);
    }

    const otpRequest = await this.otpRepository.findOne({
      where: { id: payload.otpId, purpose: OtpPurpose.LOGIN, isConsumed: true },
    });
    const user = otpRequest
      ? await this.userRepository.findOne({ where: { id: payload.userId } })
      : null;
    if (
      !otpRequest ||
      !user ||
      user.fullMobileNumber !== otpRequest.fullMobileNumber
    ) {
      throw new UnauthorizedException(LOGIN_TOKEN_INVALID);
    }
    validateAccountActive(user.isActive);
    return { user, otpId: otpRequest.id };
  }

  async forgotPasscode(dto: ForgotPasscodeDto) {
    try {
      // Validate input using utility functions
      normalizePhoneDto(dto);

      const fullMobileNumber = buildFullMobileNumber(
        dto.country_code,
        dto.mobile_number,
      );

      // Find user by mobile number
      const user = await this.userRepository.findOne({
        where: { fullMobileNumber },
      });

      if (!user) {
        throw new BadRequestException({
          status: 'error',
          message: 'User not found with this mobile number.',
        });
      }

      // Check if user account is active
      validateAccountActive(user.isActive);

    // Get user settings to check 2FA status
    const userSettings = await this.userSettingsRepository.findOne({
      where: { userId: user.id },
    });

    // Default to false if user settings not found
    const is2FAEnabled = userSettings?.twoFactorEnabled ?? false;

    // If 2FA is enabled, ensure user has a verified email
    if (is2FAEnabled && (!user.email || !user.isEmailVerified)) {
      throw new BadRequestException({
        status: 'error',
        message: 'No verified email found. Please contact support.',
      });
    }

    const expiresAt = new Date();
    expiresAt.setSeconds(expiresAt.getSeconds() + 60); // 60 seconds validity

    if (is2FAEnabled) {
      // 2FA enabled: Send OTP to both mobile and email
      const mobileOtp = generateOTP();
      const emailOtp = generateOTP();
      const mobileOtpHash = generateHash(mobileOtp);
      const emailOtpHash = generateHash(emailOtp);

      // Invalidate previous OTPs
      await this.otpRepository.delete({
        fullMobileNumber,
        purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
      });
      await this.otpRepository.delete({
        email: user.email!,
        purpose: OtpPurpose.FORGOT_PASSCODE_EMAIL,
      });

      // Save mobile OTP
      await this.otpRepository.save({
        fullMobileNumber,
        email: null,
        otpHash: mobileOtpHash,
        purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts: 0,
        lastResendAt: new Date(),
      });

      // Save email OTP
      await this.otpRepository.save({
        fullMobileNumber,
        email: user.email,
        otpHash: emailOtpHash,
        purpose: OtpPurpose.FORGOT_PASSCODE_EMAIL,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts: 0,
        lastResendAt: new Date(),
      });

      // Send OTPs via SMS and Email services
      await Promise.all([
        this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp),
        this.mailService.sendPasscodeResetOTP(user.email!, emailOtp),
      ]);

      return {
        status: 'success',
        message: 'Verification codes sent to your mobile number and email.',
        data: {
          verification_type: 'both',
          masked_mobile: maskPhoneNumber(fullMobileNumber),
          masked_email: maskEmail(user.email!),
          otp_expiry_seconds: 60,
          ...(process.env.NODE_ENV === 'development' && { mobile_otp: mobileOtp, email_otp: emailOtp }),
        },
      };
    } else {
      // 2FA disabled: Only send mobile OTP
      const mobileOtp = generateOTP();
      const mobileOtpHash = generateHash(mobileOtp);

      // Invalidate previous mobile OTP
      await this.otpRepository.delete({
        fullMobileNumber,
        purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
      });

      // Save mobile OTP
      await this.otpRepository.save({
        fullMobileNumber,
        email: null,
        otpHash: mobileOtpHash,
        purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts: 0,
        lastResendAt: new Date(),
      });

      // Send OTP via SMS service
      await this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp);

      return {
        status: 'success',
        message: 'Verification code sent to your mobile number.',
        data: {
          verification_type: 'mobile',
          masked_mobile: maskPhoneNumber(fullMobileNumber),
          otp_expiry_seconds: 60,
          ...(process.env.NODE_ENV === 'development' && { mobile_otp: mobileOtp }),
        },
      };
      }
    } catch (error) {
      // Re-throw BadRequestException as-is
      if (error instanceof BadRequestException) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in forgotPasscode: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new InternalServerErrorException({
        status: 'error',
        message: 'Failed to process forgot passcode request. Please try again later.',
      });
    }
  }

  async verifyForgotPasscodeOtps(dto: ForgotPasscodeVerifyOtpDto) {
    try {
      // Validate input using utility functions
      normalizePhoneDto(dto);

      const fullMobileNumber = buildFullMobileNumber(
        dto.country_code,
        dto.mobile_number,
      );

      // Get user
      const user = await this.userRepository.findOne({
        where: { fullMobileNumber },
      });

      if (!user) {
        throw new BadRequestException({
          status: 'error',
          message: 'User not found with this mobile number.',
        });
      }

      // Check if user account is active
      validateAccountActive(user.isActive);

    // Get user settings to check 2FA status
    const userSettings = await this.userSettingsRepository.findOne({
      where: { userId: user.id },
    });

    // Default to false if user settings not found
    const is2FAEnabled = userSettings?.twoFactorEnabled ?? false;

    if (is2FAEnabled) {
      // 2FA enabled: Verify both mobile and email OTPs
      if (!dto.mobile_otp || !dto.email_otp) {
        throw new BadRequestException({
          status: 'error',
          message: 'Both mobile and email OTPs are required.',
        });
      }

      if (!user.email) {
        throw new BadRequestException({
          status: 'error',
          message: 'User email not found.',
        });
      }

      // Find mobile OTP request
      const mobileOtpRequest = await this.otpRepository.findOne({
        where: {
          fullMobileNumber,
          purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
        },
        order: { createdAt: 'DESC' },
      });

      if (!mobileOtpRequest) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP not found. Please request a new OTP.',
        });
      }

      // Check if mobile OTP is already consumed
      if (mobileOtpRequest.isConsumed) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP has already been used. Please request a new OTP.',
        });
      }

      // Find email OTP request
      const emailOtpRequest = await this.otpRepository.findOne({
        where: {
          email: user.email,
          purpose: OtpPurpose.FORGOT_PASSCODE_EMAIL,
        },
        order: { createdAt: 'DESC' },
      });

      if (!emailOtpRequest) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP not found. Please request a new OTP.',
        });
      }

      // Check if email OTP is already consumed
      if (emailOtpRequest.isConsumed) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP has already been used. Please request a new OTP.',
        });
      }

      // Check if mobile OTP is locked
      if (
        mobileOtpRequest.lockedUntil &&
        mobileOtpRequest.lockedUntil > new Date()
      ) {
        throw new BadRequestException({
          status: 'error',
          message: 'Too many failed attempts. Account locked for 1 minute.',
        });
      }

      // Check if email OTP is locked
      if (
        emailOtpRequest.lockedUntil &&
        emailOtpRequest.lockedUntil > new Date()
      ) {
        throw new BadRequestException({
          status: 'error',
          message: 'Too many failed attempts. Account locked for 1 minute.',
        });
      }

      // Check if mobile OTP expired
      if (mobileOtpRequest.expiresAt < new Date()) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP has expired. Please request a new OTP.',
        });
      }

      // Check if email OTP expired
      if (emailOtpRequest.expiresAt < new Date()) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP has expired. Please request a new OTP.',
        });
      }

      // Verify mobile OTP
      const mobileOtpHash = generateHash(dto.mobile_otp);
      const isMobileOtpValid = mobileOtpHash === mobileOtpRequest.otpHash;

      // Verify email OTP
      const emailOtpHash = generateHash(dto.email_otp);
      const isEmailOtpValid = emailOtpHash === emailOtpRequest.otpHash;

      if (!isMobileOtpValid || !isEmailOtpValid) {
        // Increment attempts for both OTPs
        mobileOtpRequest.attempts += 1;
        const mobileRemainingAttempts = mobileOtpRequest.maxAttempts - mobileOtpRequest.attempts;
        
        if (mobileOtpRequest.attempts >= mobileOtpRequest.maxAttempts) {
          const lockUntil = new Date();
          lockUntil.setMinutes(lockUntil.getMinutes() + 1);
          mobileOtpRequest.lockedUntil = lockUntil;

          // Also lock user_security on max attempts
          const userSecurity = await this.userSecurityRepository.findOne({
            where: { userId: user.id },
          });
          if (userSecurity) {
            userSecurity.lockedUntil = lockUntil;
            await this.userSecurityRepository.save(userSecurity);
          }
        }
        await this.otpRepository.save(mobileOtpRequest);

        emailOtpRequest.attempts += 1;
        const emailRemainingAttempts = emailOtpRequest.maxAttempts - emailOtpRequest.attempts;
        
        if (emailOtpRequest.attempts >= emailOtpRequest.maxAttempts) {
          const lockUntil = new Date();
          lockUntil.setMinutes(lockUntil.getMinutes() + 1);
          emailOtpRequest.lockedUntil = lockUntil;

          // Also lock user_security on max attempts
          const userSecurity = await this.userSecurityRepository.findOne({
            where: { userId: user.id },
          });
          if (userSecurity) {
            userSecurity.lockedUntil = lockUntil;
            await this.userSecurityRepository.save(userSecurity);
          }
        }
        await this.otpRepository.save(emailOtpRequest);

        // Determine which OTP is invalid for specific error code
        let errorCode = 'INVALID_OTP';
        if (!isMobileOtpValid && !isEmailOtpValid) {
          errorCode = 'BOTH_OTP_INVALID';
        } else if (!isMobileOtpValid) {
          errorCode = 'MOBILE_OTP_INVALID';
        } else if (!isEmailOtpValid) {
          errorCode = 'EMAIL_OTP_INVALID';
        }

        throw new BadRequestException({
          status: 'error',
          message: 'Invalid verification code. Please try again.',
          code: errorCode,
          data: {
            remaining_attempts: Math.min(mobileRemainingAttempts, emailRemainingAttempts),
          },
        });
      }

      // Mark OTPs as consumed instead of deleting
      mobileOtpRequest.isConsumed = true;
      emailOtpRequest.isConsumed = true;
      await this.otpRepository.save(mobileOtpRequest);
      await this.otpRepository.save(emailOtpRequest);
    } else {
      // 2FA disabled: Verify mobile OTP only
      if (!dto.mobile_otp) {
        throw new BadRequestException({
          status: 'error',
          message: 'Mobile OTP is required.',
        });
      }

      // Find mobile OTP request
      const mobileOtpRequest = await this.otpRepository.findOne({
        where: {
          fullMobileNumber,
          purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
        },
        order: { createdAt: 'DESC' },
      });

      if (!mobileOtpRequest) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP not found. Please request a new OTP.',
        });
      }

      // Check if mobile OTP is already consumed
      if (mobileOtpRequest.isConsumed) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP has already been used. Please request a new OTP.',
        });
      }

      // Check if locked
      if (
        mobileOtpRequest.lockedUntil &&
        mobileOtpRequest.lockedUntil > new Date()
      ) {
        throw new BadRequestException({
          status: 'error',
          message: 'Too many failed attempts. Account locked for 1 minute.',
        });
      }

      // Check if expired
      if (mobileOtpRequest.expiresAt < new Date()) {
        throw new BadRequestException({
          status: 'error',
          message: 'OTP has expired. Please request a new OTP.',
        });
      }

      // Verify mobile OTP
      const mobileOtpHash = generateHash(dto.mobile_otp);
      const isMobileOtpValid = mobileOtpHash === mobileOtpRequest.otpHash;

      if (!isMobileOtpValid) {
        mobileOtpRequest.attempts += 1;
        const remainingAttempts = mobileOtpRequest.maxAttempts - mobileOtpRequest.attempts;
        
        if (mobileOtpRequest.attempts >= mobileOtpRequest.maxAttempts) {
          const lockUntil = new Date();
          lockUntil.setMinutes(lockUntil.getMinutes() + 1);
          mobileOtpRequest.lockedUntil = lockUntil;

          // Also lock user_security on max attempts
          const userSecurity = await this.userSecurityRepository.findOne({
            where: { userId: user.id },
          });
          if (userSecurity) {
            userSecurity.lockedUntil = lockUntil;
            await this.userSecurityRepository.save(userSecurity);
          }
        }
        await this.otpRepository.save(mobileOtpRequest);

        throw new BadRequestException({
          status: 'error',
          message: 'Invalid verification code. Please try again.',
          code: 'MOBILE_OTP_INVALID',
          data: {
            remaining_attempts: remainingAttempts,
          },
        });
      }

      // Mark OTP as consumed instead of deleting
      mobileOtpRequest.isConsumed = true;
      await this.otpRepository.save(mobileOtpRequest);
    }

    // Generate reset token (short-lived: 10 minutes)
    const resetToken = this.jwtService.sign(
      { userId: user.id, type: 'reset' },
      { expiresIn: '10m' },
    );

      return {
        status: 'success',
        message: 'OTP verification successful.',
        reset_token: resetToken,
      };
    } catch (error) {
      // Re-throw BadRequestException as-is
      if (error instanceof BadRequestException) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in verifyForgotPasscodeOtps: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new InternalServerErrorException({
        status: 'error',
        message: 'Failed to verify OTP. Please try again later.',
      });
    }
  }

  async resendForgotPasscodeOtps(dto: ForgotPasscodeResendOtpDto) {
    try {
      // Validate input
      if (!dto.country_code || !dto.country_code.trim()) {
        throw new BadRequestException({
          status: 'error',
          message: 'Country code is required.',
        });
      }

      if (!dto.mobile_number || !dto.mobile_number.trim()) {
        throw new BadRequestException({
          status: 'error',
          message: 'Mobile number is required.',
        });
      }

      // Saudi mobile numbers only (ALLOWED_PHONE_COUNTRY_CODES); normalizes dto in place
      normalizePhoneDto(dto);

      const fullMobileNumber = `${dto.country_code}${dto.mobile_number}`;

      // Find user
      const user = await this.userRepository.findOne({
        where: { fullMobileNumber },
      });

      if (!user) {
        throw new BadRequestException({
          status: 'error',
          message: 'User not found with this mobile number.',
        });
      }

      // Check if user account is active
      if (!user.isActive) {
        throw new BadRequestException({
          status: 'error',
          message: 'Your account has been deactivated. Please contact support.',
        });
      }

    // Get user settings to check 2FA status
    const userSettings = await this.userSettingsRepository.findOne({
      where: { userId: user.id },
    });

    // Default to false if user settings not found
    const is2FAEnabled = userSettings?.twoFactorEnabled ?? false;

    // If 2FA is enabled, ensure user has email
    if (is2FAEnabled && (!user.email || !user.isEmailVerified)) {
      throw new BadRequestException({
        status: 'error',
        message: 'No verified email found. Please contact support.',
      });
    }

    const expiresAt = new Date();
    expiresAt.setSeconds(expiresAt.getSeconds() + 60); // 60 seconds validity

    if (is2FAEnabled) {
      // 2FA enabled: Resend both mobile and email OTPs
      const existingMobileOtp = await this.otpRepository.findOne({
        where: {
          fullMobileNumber,
          purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
        },
        order: { createdAt: 'DESC' },
      });

      // Check cooldown (60 seconds)
      if (existingMobileOtp?.lastResendAt) {
        const cooldownSeconds = 60;
        const timeSinceLastResend =
          (new Date().getTime() - existingMobileOtp.lastResendAt.getTime()) /
          1000;

        if (timeSinceLastResend < cooldownSeconds) {
          const waitTime = Math.ceil(cooldownSeconds - timeSinceLastResend);
          throw new BadRequestException({
            status: 'error',
            message: `Please wait ${waitTime} seconds before requesting a new OTP.`,
          });
        }
      }

      // Check max resends (3)
      if (existingMobileOtp && existingMobileOtp.resendAttempts >= 3) {
        throw new BadRequestException({
          status: 'error',
          message: 'Maximum resend attempts reached. Please try again later.',
        });
      }

      const resendAttempts = existingMobileOtp
        ? existingMobileOtp.resendAttempts + 1
        : 1;

      // Generate new OTPs
      const mobileOtp = generateOTP();
      const emailOtp = generateOTP();
      const mobileOtpHash = generateHash(mobileOtp);
      const emailOtpHash = generateHash(emailOtp);

      // Delete old OTPs
      await this.otpRepository.delete({
        fullMobileNumber,
        purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
      });
      await this.otpRepository.delete({
        email: user.email!,
        purpose: OtpPurpose.FORGOT_PASSCODE_EMAIL,
      });

      // Save new mobile OTP
      await this.otpRepository.save({
        fullMobileNumber,
        email: null,
        otpHash: mobileOtpHash,
        purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts,
        lastResendAt: new Date(),
      });

      // Save new email OTP
      await this.otpRepository.save({
        fullMobileNumber,
        email: user.email,
        otpHash: emailOtpHash,
        purpose: OtpPurpose.FORGOT_PASSCODE_EMAIL,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts,
        lastResendAt: new Date(),
      });

      // Send OTPs via SMS and Email services
      await Promise.all([
        this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp),
        this.mailService.sendPasscodeResetOTP(user.email!, emailOtp),
      ]);

      return {
        status: 'success',
        message: 'Verification codes resent to your mobile number and email.',
        data: {
          verification_type: 'both',
          masked_mobile: maskPhoneNumber(fullMobileNumber),
          masked_email: maskEmail(user.email!),
          otp_expiry_seconds: 60,
          ...(process.env.NODE_ENV === 'development' && { mobile_otp: mobileOtp, email_otp: emailOtp }),
        },
      };
    } else {
      // 2FA disabled: Resend mobile OTP only
      const existingMobileOtp = await this.otpRepository.findOne({
        where: {
          fullMobileNumber,
          purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
        },
        order: { createdAt: 'DESC' },
      });

      // Check cooldown (60 seconds)
      if (existingMobileOtp?.lastResendAt) {
        const cooldownSeconds = 60;
        const timeSinceLastResend =
          (new Date().getTime() - existingMobileOtp.lastResendAt.getTime()) /
          1000;

        if (timeSinceLastResend < cooldownSeconds) {
          const waitTime = Math.ceil(cooldownSeconds - timeSinceLastResend);
          throw new BadRequestException({
            status: 'error',
            message: `Please wait ${waitTime} seconds before requesting a new OTP.`,
          });
        }
      }

      // Check max resends (3)
      if (existingMobileOtp && existingMobileOtp.resendAttempts >= 3) {
        throw new BadRequestException({
          status: 'error',
          message: 'Maximum resend attempts reached. Please try again later.',
        });
      }

      const resendAttempts = existingMobileOtp
        ? existingMobileOtp.resendAttempts + 1
        : 1;

      // Generate new mobile OTP
      const mobileOtp = generateOTP();
      const mobileOtpHash = generateHash(mobileOtp);

      // Delete old mobile OTP
      await this.otpRepository.delete({
        fullMobileNumber,
        purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
      });

      // Save new mobile OTP
      await this.otpRepository.save({
        fullMobileNumber,
        email: null,
        otpHash: mobileOtpHash,
        purpose: OtpPurpose.FORGOT_PASSCODE_MOBILE,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts,
        lastResendAt: new Date(),
      });

      // Send OTP via SMS service
      await this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp);

      return {
        status: 'success',
        message: 'Verification code resent to your mobile number.',
        data: {
          verification_type: 'mobile',
          masked_mobile: maskPhoneNumber(fullMobileNumber),
          otp_expiry_seconds: 60,
          ...(process.env.NODE_ENV === 'development' && { mobile_otp: mobileOtp }),
        },
      };
      }
    } catch (error) {
      // Re-throw BadRequestException as-is
      if (error instanceof BadRequestException) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in resendForgotPasscodeOtps: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new InternalServerErrorException({
        status: 'error',
        message: 'Failed to resend OTP. Please try again later.',
      });
    }
  }

  /**
   * Soft Login - Verify passcode for existing session
   */
  async softLogin(userId: string, sessionId: string, dto: SoftLoginDto) {
    try {
      // Validate input
      if (!dto.passcode || !dto.passcode.trim()) {
        throw new BadRequestException({
          status: 'error',
          message: 'Passcode is required.',
        });
      }

      if (!userId || !userId.trim()) {
        throw new BadRequestException({
          status: 'error',
          message: 'User ID is required.',
        });
      }

      if (!sessionId || !sessionId.trim()) {
        throw new BadRequestException({
          status: 'error',
          message: 'Session ID is required.',
        });
      }
    // Verify session exists and is valid
    const session = await this.authSessionRepository.findOne({
      where: { id: sessionId, userId },
    });

    if (!session) {
      throw new UnauthorizedException({
        status: 'error',
        message: "You've been logged out. Please login again.",
        code: 'SESSION_NOT_FOUND',
      });
    }

    // Check if session is revoked (forced logout)
    if (session.isRevoked) {
      throw new UnauthorizedException({
        status: 'error',
        message: "You've been logged out. Please login again.",
        code: 'SESSION_REVOKED',
      });
    }

    // Check if session is expired
    const now = new Date();
    if (session.expiresAt < now) {
      throw new UnauthorizedException({
        status: 'error',
        message: 'Session expired. Please login again.',
        code: 'SESSION_EXPIRED',
      });
    }

    // Get user security
    const userSecurity = await this.userSecurityRepository.findOne({
      where: { userId },
    });

      if (!userSecurity) {
        throw new UnauthorizedException({
          status: 'error',
          message: 'User security record not found.',
        });
      }

    // Check if account is locked
    if (userSecurity.lockedUntil && userSecurity.lockedUntil > now) {
      const remainingSeconds = Math.ceil(
        (userSecurity.lockedUntil.getTime() - now.getTime()) / 1000,
      );
      throw new UnauthorizedException({
        status: 'error',
        message: `Too many attempts. Try again in ${remainingSeconds} seconds.`,
        code: 'ACCOUNT_LOCKED',
        data: { locked_until: userSecurity.lockedUntil },
      });
    }

    // Verify passcode
    const isValidPasscode = await bcrypt.compare(
      dto.passcode,
      userSecurity.passcodeHash,
    );

    if (!isValidPasscode) {
      // Increment failed attempts
      const failedAttempts = (userSecurity.failedAttempts || 0) + 1;
      const maxAttempts = 5;

      if (failedAttempts >= maxAttempts) {
        // Lock account for 30 seconds
        const lockDuration = 30 * 1000; // 30 seconds in ms
        userSecurity.lockedUntil = new Date(Date.now() + lockDuration);
        userSecurity.failedAttempts = failedAttempts;
        userSecurity.lastFailedAt = now;
        await this.userSecurityRepository.save(userSecurity);

        throw new UnauthorizedException({
          status: 'error',
          message:
            'Too many attempts. Try again in 30 seconds.',
          code: 'ACCOUNT_LOCKED',
          data: { locked_until: userSecurity.lockedUntil },
        });
      }

      // Update failed attempts
      userSecurity.failedAttempts = failedAttempts;
      userSecurity.lastFailedAt = now;
      await this.userSecurityRepository.save(userSecurity);

      const remainingAttempts = maxAttempts - failedAttempts;
      throw new UnauthorizedException({
        status: 'error',
        message: 'Incorrect passcode. Try again.',
        code: 'INVALID_PASSCODE',
        data: { remaining_attempts: remainingAttempts },
      });
    }

    // Reset failed attempts on successful login
    if (userSecurity.failedAttempts > 0 || userSecurity.lockedUntil) {
      userSecurity.failedAttempts = 0;
      userSecurity.lockedUntil = null;
      await this.userSecurityRepository.save(userSecurity);
    }

      return {
        status: 'success',
        message: 'Passcode verified successfully',
        data: {
          user_id: userId,
        },
      };
    } catch (error) {
      // Re-throw BadRequestException and UnauthorizedException as-is
      if (
        error instanceof BadRequestException ||
        error instanceof UnauthorizedException
      ) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in softLogin: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new InternalServerErrorException({
        status: 'error',
        message: 'Failed to verify passcode. Please try again later.',
      });
    }
  }

  /**
   * Refresh Token - Issue new access token using refresh token
   */
  async refreshToken(dto: RefreshTokenDto) {
    try {
      // Validate input
      if (!dto.refresh_token || !dto.refresh_token.trim()) {
        throw new BadRequestException({
          status: 'error',
          message: 'Refresh token is required.',
        });
      }

      // Verify refresh token
      let payload: any;
      try {
        payload = this.jwtService.verify(dto.refresh_token);
      } catch (error) {
        if (error.name === 'JsonWebTokenError') {
          throw new UnauthorizedException({
            status: 'error',
            message: 'Invalid refresh token.',
          });
        }
        if (error.name === 'TokenExpiredError') {
          throw new UnauthorizedException({
            status: 'error',
            message: 'Refresh token has expired. Please login again.',
          });
        }
        throw new UnauthorizedException({
          status: 'error',
          message: 'Invalid refresh token.',
        });
      }

      // Check if it's a refresh token
      if (payload.type !== 'refresh') {
        throw new UnauthorizedException({
          status: 'error',
          message: 'Invalid token type.',
        });
      }

      // Get session from database
      const session = await this.authSessionRepository.findOne({
        where: { id: payload.sessionId },
        relations: ['user'],
      });

      if (!session) {
        throw new UnauthorizedException({
          status: 'error',
          message: 'Session not found. Please login again.',
        });
      }

      // Check if session is revoked
      if (session.isRevoked) {
        throw new UnauthorizedException({
          status: 'error',
          message: 'Session has been revoked. Please login again.',
        });
      }

      // Check if session is expired
      if (session.expiresAt < new Date()) {
        throw new UnauthorizedException({
          status: 'error',
          message: 'Session has expired. Please login again.',
        });
      }

      // Check if user account is locked
      const userSecurity = await this.userSecurityRepository.findOne({
        where: { userId: session.userId },
      });

      const now = new Date();
      if (userSecurity?.lockedUntil && userSecurity.lockedUntil > now) {
        const lockTimeRemaining = Math.ceil(
          (userSecurity.lockedUntil.getTime() - now.getTime()) / 1000 / 60,
        );
        throw new UnauthorizedException({
          status: 'error',
          message: `Account is locked. Please try again in ${lockTimeRemaining} minute(s).`,
        });
      }

      // Generate new access token (1 day expiry, matching login)
      const accessToken = this.jwtService.sign(
        {
          userId: session.userId,
          sessionId: session.id,
          type: 'access',
        },
        {
          expiresIn: 86400, // 1 day in seconds
        },
      );

      return {
        status: 'success',
        message: 'Token refreshed successfully',
        data: {
          access_token: accessToken,
          token_type: 'Bearer',
          expires_in: 86400, // 1 day in seconds
        },
      };
    } catch (error) {
      // Re-throw BadRequestException and UnauthorizedException as-is
      if (
        error instanceof BadRequestException ||
        error instanceof UnauthorizedException
      ) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in refreshToken: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new UnauthorizedException({
        status: 'error',
        message: 'Failed to refresh token. Please login again.',
      });
    }
  }

  /**
   * Get Session Status - Check if current session is valid
   */
  async getSessionStatus(userId: string, sessionId: string) {
    const session = await this.authSessionRepository.findOne({
      where: { id: sessionId, userId },
    });

    if (!session) {
      return {
        status: 'invalid',
        reason: 'Session not found',
      };
    }

    if (session.isRevoked) {
      return {
        status: 'invalid',
        reason: 'Session has been revoked',
      };
    }

    const now = new Date();
    if (session.expiresAt < now) {
      return {
        status: 'invalid',
        reason: 'Session has expired',
      };
    }

    const userSecurity = await this.userSecurityRepository.findOne({
      where: { userId },
    });

    if (userSecurity?.lockedUntil && userSecurity.lockedUntil > now) {
      return {
        status: 'invalid',
        reason: 'Account is locked',
      };
    }

    return {
      status: 'valid',
      sessionId: session.id,
      expiresAt: session.expiresAt,
      createdAt: session.createdAt,
    };
  }

  /**
   * Logout - Revoke current session
   */
  async logout(userId: string, sessionId: string) {
    try {
      // Validate input
      if (!userId || !userId.trim()) {
        throw new BadRequestException({
          status: 'error',
          message: 'User ID is required.',
        });
      }

      if (!sessionId || !sessionId.trim()) {
        throw new BadRequestException({
          status: 'error',
          message: 'Session ID is required.',
        });
      }

      const session = await this.authSessionRepository.findOne({
        where: { id: sessionId, userId },
      });

      if (!session) {
        throw new UnauthorizedException({
          status: 'error',
          message: 'Session not found.',
        });
      }

      // Revoke the session
      session.isRevoked = true;
      await this.authSessionRepository.save(session);

      // Logging out forgets this phone: the next login needs an SMS code
      if (session.trustedDeviceId) {
        await this.trustedDevices.revoke(session.trustedDeviceId);
      }

      return {
        status: 'success',
        message: 'Logged out successfully',
      };
    } catch (error) {
      // Re-throw BadRequestException and UnauthorizedException as-is
      if (
        error instanceof BadRequestException ||
        error instanceof UnauthorizedException
      ) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in logout: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new InternalServerErrorException({
        status: 'error',
        message: 'Failed to logout. Please try again later.',
      });
    }
  }

  /**
   * Logout All - Revoke all sessions for a user
   */
  async logoutAll(userId: string) {
    try {
      // Validate input
      if (!userId || !userId.trim()) {
        throw new BadRequestException({
          status: 'error',
          message: 'User ID is required.',
        });
      }

      await this.authSessionRepository.update(
        { userId, isRevoked: false },
        { isRevoked: true },
      );
      await this.trustedDevices.revokeAllForUser(userId);

      return {
        status: 'success',
        message: 'All sessions logged out successfully',
      };
    } catch (error) {
      // Re-throw BadRequestException as-is
      if (error instanceof BadRequestException) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in logoutAll: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new InternalServerErrorException({
        status: 'error',
        message: 'Failed to logout all sessions. Please try again later.',
      });
    }
  }

  /**
   * Reset Passcode - Complete forgot passcode flow
   */
  async resetPasscode(dto: ResetPasscodeDto) {
    try {
      // Validate input using utility functions
      validateToken(dto.reset_token, 'Reset token');
      validatePasscodeMatch(dto.new_passcode, dto.confirm_passcode);

      // Verify reset token
      let payload: { userId: string; type: string };
      try {
        payload = this.jwtService.verify(dto.reset_token);
        if (payload.type !== 'reset') {
          throw new UnauthorizedException({
            status: 'error',
            message: 'Invalid reset token.',
          });
        }
      } catch (error) {
        throw new UnauthorizedException({
          status: 'error',
          message: 'Invalid or expired reset token.',
        });
      }

      // Get user
      const user = await this.userRepository.findOne({
        where: { id: payload.userId },
      });

      if (!user) {
        throw new BadRequestException({
          status: 'error',
          message: 'User not found.',
        });
      }

      // Get user security record
      const userSecurity = await this.userSecurityRepository.findOne({
        where: { userId: user.id },
      });

      if (!userSecurity) {
        throw new BadRequestException({
          status: 'error',
          message: 'User security record not found.',
        });
      }

      // Hash new passcode
      const passcodeHash = await bcrypt.hash(dto.new_passcode, 10);

      // Update passcode
      userSecurity.passcodeHash = passcodeHash;
      userSecurity.lastPasscodeChangedAt = new Date();
      userSecurity.failedAttempts = 0;
      userSecurity.lockedUntil = null;
      await this.userSecurityRepository.save(userSecurity);

      // Revoke all active sessions for security
      await this.authSessionRepository.update(
        { userId: user.id, isRevoked: false },
        { isRevoked: true },
      );

      // Forget every remembered phone; only this one (which just passed the SMS check) is remembered
      await this.trustedDevices.revokeAllForUser(user.id);
      const { token: device } = await this.trustedDevices.issue(
        user.id,
        dto.device_id,
      );

      return {
        status: 'success',
        message: 'Passcode reset successfully. Please login again.',
        data: device,
      };
    } catch (error) {
      // Re-throw BadRequestException and UnauthorizedException as-is
      if (
        error instanceof BadRequestException ||
        error instanceof UnauthorizedException
      ) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in resetPasscode: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new InternalServerErrorException({
        status: 'error',
        message: 'Failed to reset passcode. Please try again later.',
      });
    }
  }
}
