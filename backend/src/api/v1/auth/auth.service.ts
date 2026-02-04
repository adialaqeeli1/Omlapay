import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  ConflictException,
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
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { ResendOtpDto } from './dto/resend-otp.dto';
import { EmailVerificationRequestDto } from './dto/email-verification-request.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';
import { LoginDto } from './dto/login.dto';
import { ForgotPasscodeDto } from './dto/forgot-passcode.dto';
import { ForgotPasscodeVerifyOtpDto } from './dto/forgot-passcode-verify-otp.dto';
import { ForgotPasscodeResendOtpDto } from './dto/forgot-passcode-resend-otp.dto';
import { OtpService } from '@common/services/otp/otp.service';
import { MailService } from '@common/services/mail/mail.service';

@Injectable()
export class AuthService {
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

  async verifyOtp(dto: VerifyOtpDto) {
    const fullMobileNumber = `${dto.country_code}${dto.mobile_number}`;

    // Find active OTP request
    const otpRequest = await this.otpRepository.findOne({
      where: {
        fullMobileNumber,
        purpose: OtpPurpose.REGISTER,
      },
      order: { createdAt: 'DESC' },
    });

    const now = new Date();

    if (!otpRequest) {
      throw new BadRequestException({
        status: 'error',
        message: 'OTP not found. Please request a new OTP.',
      });
    }

    // Check if OTP is already consumed
    if (otpRequest.isConsumed) {
      throw new BadRequestException({
        status: 'error',
        message: 'OTP has already been used. Please request a new OTP.',
      });
    }

    // Check if locked
    if (otpRequest.lockedUntil && otpRequest.lockedUntil > now) {
      throw new BadRequestException({
        status: 'error',
        message: 'Too many failed attempts. Please try again later.',
      });
    }

    // Check if expired
    if (otpRequest.expiresAt < now) {
      throw new BadRequestException({
        status: 'error',
        message: 'OTP has expired. Please request a new OTP.',
      });
    }

    // Verify OTP
    const otpHash = generateHash(dto.otp);
    if (otpHash !== otpRequest.otpHash) {
      otpRequest.attempts += 1;

      if (otpRequest.attempts >= otpRequest.maxAttempts) {
        const lockUntil = new Date();
        lockUntil.setMinutes(lockUntil.getMinutes() + 5); // 5 minutes lockout
        otpRequest.lockedUntil = lockUntil;
      }

      await this.otpRepository.save(otpRequest);
      throw new BadRequestException({
        status: 'error',
        message: 'Invalid OTP.',
      });
    }

    const countryCode = dto.country_code;
    const mobileNumber = dto.mobile_number;

    // Create or update user
    let user = await this.userRepository.findOne({
      where: { fullMobileNumber },
    });

    if (!user) {
      user = this.userRepository.create({
        countryCode,
        mobileNumber,
        fullMobileNumber,
        isMobileVerified: true,
        mobileVerifiedAt: new Date(),
      });
      user = await this.userRepository.save(user);
    } else {
      user.isMobileVerified = true;
      user.mobileVerifiedAt = new Date();
      user = await this.userRepository.save(user);
    }

    // Mark OTP as consumed instead of deleting
    otpRequest.isConsumed = true;
    await this.otpRepository.save(otpRequest);

    // Generate registration token
    const registrationToken = this.jwtService.sign(
      { userId: user.id, type: 'registration' },
      { expiresIn: '24h' },
    );

    return {
      status: 'success',
      message: 'Mobile number verified.',
      data: {
        registration_token: registrationToken,
      },
    };
  }

  async resendOtp(dto: ResendOtpDto) {
    const fullMobileNumber = `${dto.country_code}${dto.mobile_number}`;

    // Find most recent non-consumed OTP request for this mobile number
    const existingOtp = await this.otpRepository.findOne({
      where: { fullMobileNumber, isConsumed: false },
      order: { createdAt: 'DESC' },
    });

    if (!existingOtp) {
      throw new BadRequestException({
        status: 'error',
        message: 'No active OTP request found. Please start the process again.',
      });
    }

    const purpose = existingOtp.purpose;

    // Check cooldown (30 seconds)
    if (existingOtp.lastResendAt) {
      const cooldownSeconds = 30;
      const timeSinceLastResend =
        (new Date().getTime() - existingOtp.lastResendAt.getTime()) / 1000;

      if (timeSinceLastResend < cooldownSeconds) {
        const waitTime = Math.ceil(cooldownSeconds - timeSinceLastResend);
        throw new BadRequestException({
          status: 'error',
          message: `Please wait ${waitTime} seconds before requesting a new OTP.`,
        });
      }
    }

    // Check max resends (3)
    if (existingOtp.resendAttempts >= 3) {
      throw new BadRequestException({
        status: 'error',
        message: 'Maximum resend attempts reached. Please try again later.',
      });
    }

    const resendAttempts = existingOtp.resendAttempts + 1;

    // For registration, check if user already exists and is verified
    if (purpose === OtpPurpose.REGISTER) {
      const existingUser = await this.userRepository.findOne({
        where: { fullMobileNumber },
      });

      if (existingUser && existingUser.isMobileVerified) {
        throw new ConflictException({
          status: 'error',
          message: 'This mobile number is already registered.',
        });
      }
    }

    // For forgot passcode, verify user exists
    if (
      purpose === OtpPurpose.FORGOT_PASSCODE_MOBILE ||
      purpose === OtpPurpose.FORGOT_PASSCODE_EMAIL
    ) {
      const user = await this.userRepository.findOne({
        where: { fullMobileNumber },
      });

      if (!user) {
        throw new BadRequestException({
          status: 'error',
          message: 'User not found with this mobile number.',
        });
      }
    }

    // Generate new OTP
    const otp = generateOTP();
    const otpHash = generateHash(otp);
    const expiresAt = new Date();
    
    // Set expiry based on purpose
    if (purpose === OtpPurpose.FORGOT_PASSCODE_MOBILE || 
        purpose === OtpPurpose.FORGOT_PASSCODE_EMAIL) {
      expiresAt.setSeconds(expiresAt.getSeconds() + 60); // 60 seconds for forgot passcode
    } else {
      expiresAt.setMinutes(expiresAt.getMinutes() + 5); // 5 minutes for others
    }

    // Delete old OTP
    await this.otpRepository.delete({
      fullMobileNumber,
      purpose,
    });

    // Save new OTP
    await this.otpRepository.save({
      fullMobileNumber,
      email: existingOtp.email,
      otpHash,
      purpose,
      expiresAt,
      attempts: 0,
      maxAttempts: 3,
      resendAttempts,
      lastResendAt: new Date(),
      isConsumed: false,
    });

    // Send OTP via SMS service
    // await this.otpService.sendOTP(fullMobileNumber, otp);
    console.log(`OTP for ${fullMobileNumber} (${purpose}): ${otp}`);

    return {
      status: 'success',
      message: 'OTP resent to your mobile number.',
    };
  }

  async requestEmailVerification(dto: EmailVerificationRequestDto) {
    // Verify registration token
    let payload: { userId: string; type: string };
    try {
      payload = this.jwtService.verify(dto.registration_token);
      if (payload.type !== 'registration') {
        throw new UnauthorizedException('Invalid registration token.');
      }
    } catch (error) {
      throw new UnauthorizedException({
        status: 'error',
        message: 'Invalid or expired registration token.',
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

    if (!user.isMobileVerified) {
      throw new BadRequestException({
        status: 'error',
        message: 'Mobile number must be verified first.',
      });
    }

    // Check if email already exists
    const existingUser = await this.userRepository.findOne({
      where: { email: dto.email },
    });

    if (existingUser && existingUser.id !== user.id) {
      throw new ConflictException({
        status: 'error',
        message: 'This email is already registered.',
      });
    }

    // Generate verification code
    const verificationCode = generateOTP();
    const codeHash = generateHash(verificationCode);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 5); // 5 minutes validity

    // Invalidate previous verification codes for this email
    await this.otpRepository.delete({
      email: dto.email,
      purpose: OtpPurpose.EMAIL_VERIFICATION,
    });

    // Save new verification code
    await this.otpRepository.save({
      fullMobileNumber: user.fullMobileNumber,
      email: dto.email,
      otpHash: codeHash,
      purpose: OtpPurpose.EMAIL_VERIFICATION,
      expiresAt,
      attempts: 0,
      maxAttempts: 3,
      resendAttempts: 0,
      lastResendAt: new Date(),
      isConsumed: false,
    });

    // Update user email (but not verified yet)
    user.email = dto.email;
    await this.userRepository.save(user);

    // Send verification email
    // await this.mailService.sendVerificationEmail(dto.email, verificationCode);
    console.log(
      `Email verification code for ${dto.email}: ${verificationCode}`,
    );

    return {
      status: 'success',
      message: 'Verification email has been sent.',
    };
  }

  async verifyEmail(dto: VerifyEmailDto) {
    // Find active verification request
    const verification = await this.otpRepository.findOne({
      where: {
        email: dto.email,
        purpose: OtpPurpose.EMAIL_VERIFICATION,
      },
      order: { createdAt: 'DESC' },
    });

    if (!verification) {
      throw new BadRequestException({
        status: 'error',
        message: 'Verification code not found. Please request a new code.',
      });
    }

    // Check if already consumed
    if (verification.isConsumed) {
      throw new BadRequestException({
        status: 'error',
        message: 'Verification code has already been used. Please request a new code.',
      });
    }

    // Check if locked
    if (verification.lockedUntil && verification.lockedUntil > new Date()) {
      throw new BadRequestException({
        status: 'error',
        message: 'Too many failed attempts. Please try again later.',
      });
    }

    // Check if expired
    if (verification.expiresAt < new Date()) {
      throw new BadRequestException({
        status: 'error',
        message: 'Verification code has expired. Please request a new code.',
      });
    }

    // Verify code
    const codeHash = generateHash(dto.verification_code);
    if (codeHash !== verification.otpHash) {
      verification.attempts += 1;

      if (verification.attempts >= verification.maxAttempts) {
        const lockUntil = new Date();
        lockUntil.setMinutes(lockUntil.getMinutes() + 5); // 5 minutes lockout
        verification.lockedUntil = lockUntil;
      }

      await this.otpRepository.save(verification);
      throw new BadRequestException({
        status: 'error',
        message: 'Invalid or expired verification code.',
      });
    }

    // Update user email verification status
    const user = await this.userRepository.findOne({
      where: { email: dto.email },
    });

    if (!user) {
      throw new BadRequestException({
        status: 'error',
        message: 'User not found.',
      });
    }

    user.isEmailVerified = true;
    user.emailVerifiedAt = new Date();
    await this.userRepository.save(user);

    // Mark verification as consumed
    verification.isConsumed = true;
    await this.otpRepository.save(verification);

    return {
      status: 'success',
      message: 'Email verified successfully.',
    };
  }

  async login(dto: LoginDto) {
    const fullMobileNumber = `${dto.country_code}${dto.mobile_number}`;

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

    // Check if user is active
    if (!user.isActive) {
      throw new UnauthorizedException({
        status: 'error',
        message: 'Account is inactive. Please contact support.',
      });
    }

    // Get user security record
    const userSecurity = await this.userSecurityRepository.findOne({
      where: { userId: user.id },
    });

    if (!userSecurity) {
      throw new UnauthorizedException({
        status: 'error',
        message: 'Incorrect passcode. Please try again.',
      });
    }

    // Check if account is locked
    if (userSecurity.lockedUntil && userSecurity.lockedUntil > new Date()) {
      throw new UnauthorizedException({
        status: 'error',
        message: 'Account is temporarily locked. Please try again later.',
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
      }

      await this.userSecurityRepository.save(userSecurity);

      throw new UnauthorizedException({
        status: 'error',
        message: 'Incorrect passcode. Please try again.',
      });
    }

    // Reset failed attempts on successful login
    if (userSecurity.failedAttempts > 0) {
      userSecurity.failedAttempts = 0;
      userSecurity.lockedUntil = null;
      await this.userSecurityRepository.save(userSecurity);
    }

    // Generate access and refresh tokens
    const accessTokenPayload = {
      userId: user.id,
      type: 'access',
    };

    const refreshTokenPayload = {
      userId: user.id,
      type: 'refresh',
    };

    const accessToken = this.jwtService.sign(accessTokenPayload, {
      expiresIn: '10m', // 10 minutes (600 seconds)
    });

    const refreshToken = this.jwtService.sign(refreshTokenPayload, {
      expiresIn: '7d', // 7 days
    });

    // Hash tokens for storage
    const accessTokenHash = generateHash(accessToken);
    const refreshTokenHash = generateHash(refreshToken);

    // Create auth session
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 10); // 10 minutes

    await this.authSessionRepository.save({
      userId: user.id,
      accessTokenHash,
      refreshTokenHash,
      expiresAt,
      isRevoked: false,
    });

    return {
      status: 'success',
      message: 'Login successful',
      data: {
        access_token: accessToken,
        refresh_token: refreshToken,
        expires_in: 600, // 10 minutes in seconds
        user: {
          id: user.id,
          mobile_number: fullMobileNumber,
        },
      },
    };
  }

  async forgotPasscode(dto: ForgotPasscodeDto) {
    const fullMobileNumber = `${dto.country_code}${dto.mobile_number}`;

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
      // await Promise.all([
      //   this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp),
      //   this.mailService.sendPasscodeResetOTP(user.email!, emailOtp),
      // ]);
      console.log(`Mobile OTP for ${fullMobileNumber}: ${mobileOtp}`);
      console.log(`Email OTP for ${user.email}: ${emailOtp}`);

      return {
        status: 'success',
        message: 'Verification codes sent to your mobile number and email.',
        data: {
          verification_type: 'both',
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
      // await this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp);
      console.log(`Mobile OTP for ${fullMobileNumber}: ${mobileOtp}`);

      return {
        status: 'success',
        message: 'Verification code sent to your mobile number.',
        data: {
          verification_type: 'mobile',
        },
      };
    }
  }

  async verifyForgotPasscodeOtps(dto: ForgotPasscodeVerifyOtpDto) {
    const fullMobileNumber = `${dto.country_code}${dto.mobile_number}`;

    // Get user
    const user = await this.userRepository.findOne({
      where: { fullMobileNumber },
    });

    if (!user) {
      throw new BadRequestException({
        status: 'error',
        message: 'User not found.',
      });
    }

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

        throw new BadRequestException({
          status: 'error',
          message: 'Invalid verification code. Please try again.',
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
  }

  async resendForgotPasscodeOtps(dto: ForgotPasscodeResendOtpDto) {
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

      // Check cooldown (10 seconds)
      if (existingMobileOtp?.lastResendAt) {
        const cooldownSeconds = 10;
        const timeSinceLastResend =
          (new Date().getTime() - existingMobileOtp.lastResendAt.getTime()) /
          1000;

        if (timeSinceLastResend < cooldownSeconds) {
          throw new BadRequestException({
            status: 'error',
            message: 'Please wait before requesting a new OTP.',
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
      // await Promise.all([
      //   this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp),
      //   this.mailService.sendPasscodeResetOTP(user.email!, emailOtp),
      // ]);
      console.log(`Mobile OTP for ${fullMobileNumber}: ${mobileOtp}`);
      console.log(`Email OTP for ${user.email}: ${emailOtp}`);

      return {
        status: 'success',
        message: 'Verification codes resent to your mobile number and email.',
        data: {
          verification_type: 'both',
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

      // Check cooldown (10 seconds)
      if (existingMobileOtp?.lastResendAt) {
        const cooldownSeconds = 10;
        const timeSinceLastResend =
          (new Date().getTime() - existingMobileOtp.lastResendAt.getTime()) /
          1000;

        if (timeSinceLastResend < cooldownSeconds) {
          throw new BadRequestException({
            status: 'error',
            message: 'Please wait before requesting a new OTP.',
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
      // await this.otpService.sendPasscodeResetOTP(fullMobileNumber, mobileOtp);
      console.log(`Mobile OTP for ${fullMobileNumber}: ${mobileOtp}`);

      return {
        status: 'success',
        message: 'Verification code resent to your mobile number.',
        data: {
          verification_type: 'mobile',
        },
      };
    }
  }
}
