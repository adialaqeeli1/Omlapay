import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  ConflictException,
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
  validateCountryCodeAndMobileNumber,
  validateRequired,
  buildFullMobileNumber,
  validateAccountActive,
  validateToken,
  validatePasscodeMatch,
} from '@common/utils';
import { LoginDto } from './dto/login.dto';
import { SoftLoginDto } from './dto/soft-login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ForgotPasscodeDto } from './dto/forgot-passcode.dto';
import { ForgotPasscodeVerifyOtpDto } from './dto/forgot-passcode-verify-otp.dto';
import { ForgotPasscodeResendOtpDto } from './dto/forgot-passcode-resend-otp.dto';
import { ResetPasscodeDto } from '../user/dto/reset-passcode.dto';
import { OtpService } from '@common/services/otp/otp.service';
import { MailService } from '@common/services/mail/mail.service';

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
  ) {}

  async login(dto: LoginDto) {
    try {
      // Validate input using utility functions
      validateCountryCodeAndMobileNumber(dto.country_code, dto.mobile_number);
      validateRequired(dto.passcode, 'Passcode');

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
          (userSecurity.lockedUntil.getTime() - new Date().getTime()) / 1000 / 60,
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

    // Reset failed attempts on successful login
    if (userSecurity.failedAttempts > 0) {
      userSecurity.failedAttempts = 0;
      userSecurity.lockedUntil = null;
      await this.userSecurityRepository.save(userSecurity);
    }

    // Create auth session first (1 day expiry)
    const accessExpiresSeconds = 86400; // 1 day
    const expiresAt = new Date();
    expiresAt.setSeconds(expiresAt.getSeconds() + accessExpiresSeconds);

    const session = await this.authSessionRepository.save({
      userId: user.id,
      accessTokenHash: '', // Temporary, will update after signing
      refreshTokenHash: '', // Temporary, will update after signing
      expiresAt,
      isRevoked: false,
    });

    // Generate access and refresh tokens with session ID
    const accessTokenPayload = {
      userId: user.id,
      sessionId: session.id,
      type: 'access',
    };

    const refreshTokenPayload = {
      userId: user.id,
      sessionId: session.id,
      type: 'refresh',
    };

    const accessToken = this.jwtService.sign(accessTokenPayload, {
      expiresIn: accessExpiresSeconds, // 1 day
    });

    const refreshToken = this.jwtService.sign(refreshTokenPayload, {
      expiresIn: '7d', // 7 days
    });

    // Update session with token hashes
    session.accessTokenHash = generateHash(accessToken);
    session.refreshTokenHash = generateHash(refreshToken);
    await this.authSessionRepository.save(session);

      return {
        status: 'success',
        message: 'Login successful',
        data: {
          access_token: accessToken,
          refresh_token: refreshToken,
          expires_in: accessExpiresSeconds,
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
        `Error in login: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new BadRequestException({
        status: 'error',
        message: 'Failed to process login request. Please try again later.',
      });
    }
  }

  async forgotPasscode(dto: ForgotPasscodeDto) {
    try {
      // Validate input using utility functions
      validateCountryCodeAndMobileNumber(dto.country_code, dto.mobile_number);

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
      const isIndian = fullMobileNumber.startsWith('+91');
      const mobileOtp = isIndian ? '666666' : generateOTP();
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
      // await Promise.all([
      //   this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp),
      //   this.mailService.sendPasscodeResetOTP(user.email!, emailOtp),
      // ]);

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
      const isIndian = fullMobileNumber.startsWith('+91');
      const mobileOtp = isIndian ? '666666' : generateOTP();
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
      // await this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp);

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

      throw new BadRequestException({
        status: 'error',
        message: 'Failed to process forgot passcode request. Please try again later.',
      });
    }
  }

  async verifyForgotPasscodeOtps(dto: ForgotPasscodeVerifyOtpDto) {
    try {
      // Validate input using utility functions
      validateCountryCodeAndMobileNumber(dto.country_code, dto.mobile_number);

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

      throw new BadRequestException({
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

      // Validate country code format
      if (!/^\+(966|91)$/.test(dto.country_code)) {
        throw new BadRequestException({
          status: 'error',
          message: 'Invalid country code. Allowed: +966, +91',
        });
      }

      // Validate mobile number format
      const mobileNumberRegex = dto.country_code === '+966' ? /^\d{9}$/ : /^\d{10}$/;
      if (!mobileNumberRegex.test(dto.mobile_number)) {
        const expectedLength = dto.country_code === '+966' ? '9' : '10';
        throw new BadRequestException({
          status: 'error',
          message: `Mobile number must be ${expectedLength} digits long.`,
        });
      }

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
      const isIndian = fullMobileNumber.startsWith('+91');
      const mobileOtp = isIndian ? '666666' : generateOTP();
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
      // await Promise.all([
      //   this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp),
      //   this.mailService.sendPasscodeResetOTP(user.email!, emailOtp),
      // ]);

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
      const isIndian = fullMobileNumber.startsWith('+91');
      const mobileOtp = isIndian ? '666666' : generateOTP();
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
      // await this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp);

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

      throw new BadRequestException({
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
        // Lock account for 30 minutes
        const lockDuration = 30 * 60 * 1000; // 30 minutes in ms
        userSecurity.lockedUntil = new Date(Date.now() + lockDuration);
        userSecurity.failedAttempts = failedAttempts;
        userSecurity.lastFailedAt = now;
        await this.userSecurityRepository.save(userSecurity);

        throw new UnauthorizedException({
          status: 'error',
          message:
            'Too many attempts. Try again in 1800 seconds.',
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

      throw new BadRequestException({
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
      session_id: session.id,
      expires_at: session.expiresAt,
      created_at: session.createdAt,
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

      throw new BadRequestException({
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

      throw new BadRequestException({
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

      return {
        status: 'success',
        message: 'Passcode reset successfully. Please login again.',
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

      throw new BadRequestException({
        status: 'error',
        message: 'Failed to reset passcode. Please try again later.',
      });
    }
  }
}
