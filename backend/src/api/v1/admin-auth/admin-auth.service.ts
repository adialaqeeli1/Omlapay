import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { AdminEntity } from '@common/database/model';
import { AdminSecurityEntity } from '@common/database/model';
import { AdminOtpEntity } from '@common/database/model';
import { AdminSessionEntity } from '@common/database/model';
import { AdminAuditLogEntity } from '@common/database/model';
import { AdminLoginDto } from './dto/admin-login.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { AdminVerifyOtpDto } from './dto/verify-otp.dto';
import { AdminResendOtpDto } from './dto/resend-otp.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { CreateSuperAdminDto } from './dto/create-super-admin.dto';
import { AdminRefreshTokenDto } from './dto/refresh-token.dto';
import { generateOTP, generateHash } from '@common/filters';
import { MailService } from '@common/services/mail/mail.service';
import { OtpService } from '@common/services/otp/otp.service';
import {
  validateRequired,
  validateAccountActive,
  validatePasswordMatch,
  validateOTP,
  validateToken,
} from '@common/utils';
import { AdminRole } from '@common/database/model/admin.entity';
import { ConfigService } from '@nestjs/config';
import { CryptoUtil } from '@common/utils/crypto.util';

@Injectable()
export class AdminAuthService {
  private readonly logger = new Logger(AdminAuthService.name);

  constructor(
    @InjectRepository(AdminEntity)
    private adminRepository: Repository<AdminEntity>,
    @InjectRepository(AdminSecurityEntity)
    private adminSecurityRepository: Repository<AdminSecurityEntity>,
    @InjectRepository(AdminOtpEntity)
    private adminOtpRepository: Repository<AdminOtpEntity>,
    @InjectRepository(AdminSessionEntity)
    private adminSessionRepository: Repository<AdminSessionEntity>,
    @InjectRepository(AdminAuditLogEntity)
    private adminAuditLogRepository: Repository<AdminAuditLogEntity>,
    private jwtService: JwtService,
    private mailService: MailService,
    private otpService: OtpService,
    private configService: ConfigService,
  ) {}

  private async createAuditLog(
    action: string,
    adminId: string | null,
    metadata: Record<string, any> | null,
    ipAddress: string | null,
  ) {
    await this.adminAuditLogRepository.save({
      adminId,
      action,
      metadata,
      ipAddress,
    });
  }

  private normalizeIdentifier(identifier: string): string {
    // Trim whitespace
    let normalized = identifier.trim();

    // Check if it's an email (contains @)
    if (normalized.includes('@')) {
      // Normalize email: lowercase
      return normalized.toLowerCase();
    }

    // Check if it's a Saudi phone number starting with 05 (without country code)
    if (/^05\d{8}$/.test(normalized)) {
      // Auto-format: 05XXXXXXXX → +9665XXXXXXXX
      return '+966' + normalized.substring(1);
    }

    // Check if it's an Indian phone number (10 digits starting with 6-9)
    if (/^[6-9]\d{9}$/.test(normalized)) {
      // Auto-format: 9XXXXXXXXX → +919XXXXXXXXX
      return '+91' + normalized;
    }

    // Return as-is if already formatted (+966 or +91) or other format
    return normalized;
  }

  /**
   * Step 1: Send OTP for login
   * Verifies that admin exists and sends OTP to their registered email or phone
   */
  async sendOtpForLogin(dto: { identifier: string }, ipAddress?: string) {
    try {
      // Validate input using utility functions
      validateRequired(dto.identifier, 'Email or phone number');

      // Normalize identifier (trim, lowercase for email, auto-format phone)
      const normalizedIdentifier = this.normalizeIdentifier(dto.identifier);

      // Determine if identifier is email or phone
      const isEmail = normalizedIdentifier.includes('@');

      // Find admin by email or phone
      const admin = await this.adminRepository.findOne({
        where: [{ email: normalizedIdentifier }, { phoneNumber: normalizedIdentifier }],
      });

      if (!admin) {
        // Provide meaningful error message based on identifier type
        if (isEmail) {
          throw new BadRequestException({
            status: 'error',
            message: 'No admin account found with this email address.',
          });
        } else {
          throw new BadRequestException({
            status: 'error',
            message: 'No admin account found with this phone number.',
          });
        }
      }

      // Check if admin is active
      validateAccountActive(admin.isActive, 'admin account');

      // Validate that admin has the required contact method configured
      if (isEmail && !admin.email) {
        throw new BadRequestException({
          status: 'error',
          message: 'Email address is not configured for this admin account.',
        });
      }

      if (!isEmail && !admin.phoneNumber) {
        throw new BadRequestException({
          status: 'error',
          message: 'Phone number is not configured for this admin account.',
        });
      }

      // Invalidate previous login OTPs
      await this.adminOtpRepository.update(
        { adminId: admin.adminId, isUsed: false },
        { isUsed: true },
      );

      // Generate OTP
      const isIndian = admin?.phoneNumber?.startsWith('+91'); // Temporary fix for Indian numbers
      const otp = isIndian ? '666666' : generateOTP();
      const otpHash = generateHash(otp);
      const expiresAt = new Date();
      expiresAt.setMinutes(expiresAt.getMinutes() + 1); // 1 minute validity

      // Save OTP
      await this.adminOtpRepository.save({
        adminId: admin.adminId,
        otpCode: otpHash,
        sentTo: normalizedIdentifier,
        expiresAt,
        attemptCount: 0,
        isUsed: false,
      });

      // Send OTP via email or SMS with error handling
      let otpSent = false;
      let sendError: string | null = null;

      try {
        if (isEmail && admin.email) {
          await this.mailService.sendOTP(admin.email, otp);
          otpSent = true;
        } else if (!isEmail && admin.phoneNumber) {
          await this.otpService.sendOTP(admin.phoneNumber, otp);
          otpSent = true;
        } else {
          throw new Error('No contact method available to send OTP');
        }
      } catch (error) {
        otpSent = false;
        sendError = error instanceof Error ? error.message : 'Failed to send OTP';
        // Log the error but don't fail the request - OTP is saved in DB
        this.logger.error(`Failed to send OTP to ${normalizedIdentifier}:`, error);
      }

      await this.createAuditLog(
        'LOGIN_OTP_SENT',
        admin.adminId,
        { sentTo: normalizedIdentifier, otpSent, sendError },
        ipAddress || null,
      );

      if (!otpSent) {
        return {
          status: 'error',
          message: 'Failed to send OTP. Please try again later or contact support.',
          ...(sendError && { error: sendError }),
          ...(process.env.NODE_ENV === 'development' && { otp }),
        };
      }

      return {
        status: 'success',
        message: 'OTP sent successfully. || OTP : ' + otp + ' ||',
        termsRequired: !admin.termsAcceptedAt, // Return whether terms need to be accepted
      };
    } catch (error) {
      // Re-throw BadRequestException and UnauthorizedException as-is
      if (error instanceof BadRequestException || error instanceof UnauthorizedException) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(`Error in sendOtpForLogin: ${error instanceof Error ? error.message : 'Unknown error'}`, error instanceof Error ? error.stack : undefined);

      // Return generic error for unexpected failures
      throw new BadRequestException({
        status: 'error',
        message: 'Failed to process OTP request. Please try again later.',
      });
    }
  }

  /**
   * Step 2: Complete login with password + OTP + terms
   */
  async login(dto: AdminLoginDto, ipAddress?: string) {
    try {
      // Validate input using utility functions
      validateRequired(dto.identifier, 'Email or phone number');
      validateRequired(dto.password, 'Password');
      validateOTP(dto.otp);

      if (dto.acceptTerms === undefined || dto.acceptTerms === null) {
        throw new BadRequestException({
          status: 'error',
          message: 'You must accept the terms and conditions.',
        });
      }

      // Normalize identifier (trim, lowercase for email, auto-format phone)
      const normalizedIdentifier = this.normalizeIdentifier(dto.identifier);
      const isEmail = normalizedIdentifier.includes('@');

      // Find admin by email or phone
      const admin = await this.adminRepository.findOne({
        where: [{ email: normalizedIdentifier }, { phoneNumber: normalizedIdentifier }],
      });

      if (!admin) {
        // Log failed login attempt
        await this.createAuditLog(
          'LOGIN_FAILED',
          null,
          { identifier: normalizedIdentifier, reason: 'admin_not_found' },
          ipAddress || null,
        );
        // Provide meaningful error based on identifier type
        if (isEmail) {
          throw new BadRequestException({
            status: 'error',
            message: 'No admin account found with this email address.',
          });
        } else {
          throw new BadRequestException({
            status: 'error',
            message: 'No admin account found with this phone number.',
          });
        }
      }

      // Check if admin is active
      try {
        validateAccountActive(admin.isActive, 'admin account');
      } catch (error) {
        await this.createAuditLog(
          'LOGIN_FAILED',
          admin.adminId,
          { reason: 'account_inactive' },
          ipAddress || null,
        );
        throw error;
      }

    // Get or create admin security record
    let adminSecurity = await this.adminSecurityRepository.findOne({
      where: { adminId: admin.adminId },
    });

    if (!adminSecurity) {
      adminSecurity = this.adminSecurityRepository.create({
        adminId: admin.adminId,
        failedLoginAttempts: 0,
      });
      await this.adminSecurityRepository.save(adminSecurity);
    }

    // Check if account is locked
    if (adminSecurity.lockedUntil && adminSecurity.lockedUntil > new Date()) {
      await this.createAuditLog(
        'LOGIN_FAILED',
        admin.adminId,
        { reason: 'account_locked' },
        ipAddress || null,
      );
      throw new HttpException(
        'Your account is temporarily locked. Please try again later.',
        HttpStatus.LOCKED,
      );
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(
      dto.password,
      admin.passwordHash,
    );

    if (!isPasswordValid) {
      // Increment failed attempts
      adminSecurity.failedLoginAttempts += 1;
      adminSecurity.lastFailedLoginAt = new Date();

      // Lock account after 5 failed attempts
      if (adminSecurity.failedLoginAttempts >= 5) {
        const lockUntil = new Date();
        lockUntil.setMinutes(lockUntil.getMinutes() + 30); // 30 minutes lockout
        adminSecurity.lockedUntil = lockUntil;
      }

      await this.adminSecurityRepository.save(adminSecurity);

      await this.createAuditLog(
        'LOGIN_FAILED',
        admin.adminId,
        {
          reason: 'invalid_password',
          attempts: adminSecurity.failedLoginAttempts,
        },
        ipAddress || null,
      );

        throw new BadRequestException({
          status: 'error',
          message: 'Invalid password. Please try again.',
        });
      }

      // Verify OTP
      const otpRequest = await this.adminOtpRepository.findOne({
        where: {
          adminId: admin.adminId,
          isUsed: false,
        },
        order: { createdAt: 'DESC' },
      });

      if (!otpRequest) {
        await this.createAuditLog(
          'LOGIN_OTP_VERIFICATION_FAILED',
          admin.adminId,
          { reason: 'otp_not_found' },
          ipAddress || null,
        );
        throw new BadRequestException({
          status: 'error',
          message: 'OTP not found. Please request a new OTP.',
        });
      }

      // Check if OTP expired
      if (otpRequest.expiresAt < new Date()) {
        await this.createAuditLog(
          'LOGIN_OTP_VERIFICATION_FAILED',
          admin.adminId,
          { reason: 'otp_expired' },
          ipAddress || null,
        );
        throw new BadRequestException({
          status: 'error',
          message: 'OTP has expired. Please request a new one.',
        });
      }

      // Check max attempts (3)
      if (otpRequest.attemptCount >= 3) {
        await this.createAuditLog(
          'LOGIN_OTP_VERIFICATION_FAILED',
          admin.adminId,
          { reason: 'max_attempts_exceeded' },
          ipAddress || null,
        );
        throw new BadRequestException({
          status: 'error',
          message: 'Too many OTP attempts. Please request a new OTP.',
        });
      }

      // Verify OTP
      const otpHash = generateHash(dto.otp);
      if (otpHash !== otpRequest.otpCode) {
        otpRequest.attemptCount += 1;
        await this.adminOtpRepository.save(otpRequest);

        await this.createAuditLog(
          'LOGIN_OTP_VERIFICATION_FAILED',
          admin.adminId,
          { reason: 'invalid_otp', attempts: otpRequest.attemptCount },
          ipAddress || null,
        );

        const remainingAttempts = 3 - otpRequest.attemptCount;
        throw new BadRequestException({
          status: 'error',
          message: `Invalid OTP. ${remainingAttempts > 0 ? `You have ${remainingAttempts} attempt(s) remaining.` : 'Please request a new OTP.'}`,
        });
      }

      // Verify terms acceptance
      if (!dto.acceptTerms) {
        throw new BadRequestException({
          status: 'error',
          message: 'You must accept the terms and conditions to login.',
        });
      }

    // Mark OTP as used
    otpRequest.isUsed = true;
    await this.adminOtpRepository.save(otpRequest);

    // Update terms accepted timestamp if not already accepted
    if (!admin.termsAcceptedAt) {
      admin.termsAcceptedAt = new Date();
      await this.adminRepository.save(admin);
    }

    // Reset failed attempts on successful login
    if (adminSecurity.failedLoginAttempts > 0) {
      adminSecurity.failedLoginAttempts = 0;
      adminSecurity.lockedUntil = null;
    }
    adminSecurity.lastLoginAt = new Date();
    await this.adminSecurityRepository.save(adminSecurity);

    // Generate access token (short-lived)
    const accessTokenPayload = {
      adminId: admin.adminId,
      email: admin.email,
      type: 'admin',
    };

    const accessToken = this.jwtService.sign(accessTokenPayload, {
      expiresIn: this.configService.get<string>('JWT_EXP_TIME', '1h'), // 1 hour
    });

    // Generate refresh token (long-lived)
    const refreshTokenPayload = {
      adminId: admin.adminId,
      type: 'admin_refresh',
    };

    const refreshToken = this.jwtService.sign(refreshTokenPayload, {
      expiresIn: this.configService.get<string>('JWT_REFRESH_EXP_TIME', '7d'), // 7 days
    });

    // Hash tokens for storage
    const accessTokenHash = generateHash(accessToken);
    const refreshTokenHash = generateHash(refreshToken);

    // Create admin session
    const now = new Date();
    // Calculate session expiry from JWT_REFRESH_EXP_TIME (refresh token lifetime)
    const refreshExpTime = this.configService.get<string>('JWT_REFRESH_EXP_TIME', '7d');
    const refreshExpSeconds = CryptoUtil.timeStringToSeconds(refreshExpTime);
    const expiresAt = new Date(now.getTime() + refreshExpSeconds * 1000);

    await this.adminSessionRepository.save({
      adminId: admin.adminId,
      tokenHash: accessTokenHash,
      refreshTokenHash,
      ipAddress: ipAddress || null,
      userAgent: null,
      expiresAt,
      lastActivityAt: now,
    });

    await this.createAuditLog(
      'LOGIN_SUCCESS',
      admin.adminId,
      null,
      ipAddress || null,
    );

    // Calculate access token expiry in seconds for response
    const accessExpTime = this.configService.get<string>('JWT_EXP_TIME', '1h');
    const accessExpSeconds = CryptoUtil.timeStringToSeconds(accessExpTime);

      return {
        accessToken,
        refreshToken,
        expiresIn: accessExpSeconds, // Access token expiry in seconds from env
      };
    } catch (error) {
      // Re-throw BadRequestException, UnauthorizedException, and HttpException as-is
      if (
        error instanceof BadRequestException ||
        error instanceof UnauthorizedException ||
        error instanceof HttpException
      ) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in login: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      // Return generic error for unexpected failures
      throw new BadRequestException({
        status: 'error',
        message: 'Failed to process login request. Please try again later.',
      });
    }
  }

  async logout(adminId: string) {
    // Revoke all active sessions for this admin
    const sessions = await this.adminSessionRepository.find({
      where: { adminId },
    });

    for (const session of sessions) {
      session.revokedAt = new Date();
    }

    await this.adminSessionRepository.save(sessions);

    await this.createAuditLog('LOGOUT', adminId, null, null);

    return {
      message: 'Logged out successfully',
    };
  }

  async forgotPassword(dto: ForgotPasswordDto, ipAddress?: string) {
    try {
      // Validate input
      validateRequired(dto.identifier, 'Email or phone number');

      // Always return generic success message for security (prevents user enumeration)
      const genericResponse = {
        status: 'success',
        message: 'If the account exists, an OTP has been sent.',
      };

      // Normalize identifier
      const normalizedIdentifier = this.normalizeIdentifier(dto.identifier);
      const isEmail = normalizedIdentifier.includes('@');

      // Find admin by email or phone
      const admin = await this.adminRepository.findOne({
        where: [{ email: normalizedIdentifier }, { phoneNumber: normalizedIdentifier }],
      });

      if (!admin) {
        // Don't reveal that admin doesn't exist (security best practice)
        await this.createAuditLog(
          'FORGOT_PASSWORD_FAILED',
          null,
          { identifier: normalizedIdentifier, reason: 'admin_not_found' },
          ipAddress || null,
        );
        return genericResponse;
      }

      // Check if admin is active
      if (!admin.isActive) {
        await this.createAuditLog(
          'FORGOT_PASSWORD_FAILED',
          admin.adminId,
          { reason: 'account_inactive' },
          ipAddress || null,
        );
        // Still return generic response for security
        return genericResponse;
      }

      // Validate that admin has the required contact method configured
      if (isEmail && !admin.email) {
        await this.createAuditLog(
          'FORGOT_PASSWORD_FAILED',
          admin.adminId,
          { reason: 'email_not_configured' },
          ipAddress || null,
        );
        return genericResponse;
      }

      if (!isEmail && !admin.phoneNumber) {
        await this.createAuditLog(
          'FORGOT_PASSWORD_FAILED',
          admin.adminId,
          { reason: 'phone_not_configured' },
          ipAddress || null,
        );
        return genericResponse;
      }

      // Generate OTP
      const isIndian = admin?.phoneNumber?.startsWith('+91'); // Temporary fix for Indian numbers
      const otp = isIndian ? '666666' : generateOTP();
      const otpHash = generateHash(otp);
      const expiresAt = new Date();
      expiresAt.setMinutes(expiresAt.getMinutes() + 10); // 10 minutes validity

      // Invalidate previous OTPs for this admin
      await this.adminOtpRepository.update(
        { adminId: admin.adminId, isUsed: false },
        { isUsed: true },
      );

      // Save new OTP
      await this.adminOtpRepository.save({
        adminId: admin.adminId,
        otpCode: otpHash,
        sentTo: normalizedIdentifier,
        expiresAt,
        attemptCount: 0,
        isUsed: false,
      });

      // Send OTP via email or SMS with error handling
      let otpSent = false;
      try {
        if (isEmail && admin.email) {
          await this.mailService.sendOTP(admin.email, otp);
          otpSent = true;
        } else if (!isEmail && admin.phoneNumber) {
          await this.otpService.sendOTP(admin.phoneNumber, otp);
          otpSent = true;
        }
      } catch (error) {
        this.logger.error(`Failed to send forgot password OTP to ${normalizedIdentifier}:`, error);
        // Still return generic response even if sending fails
      }

      await this.createAuditLog(
        'FORGOT_PASSWORD_INITIATED',
        admin.adminId,
        { sentTo: normalizedIdentifier, otpSent },
        ipAddress || null,
      );

      return genericResponse;
    } catch (error) {
      // Re-throw BadRequestException as-is
      if (error instanceof BadRequestException) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in forgotPassword: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      // Return generic response even on error (security best practice)
      return {
        status: 'success',
        message: 'If the account exists, an OTP has been sent.',
      };
    }
  }

  async verifyOtp(dto: AdminVerifyOtpDto, ipAddress?: string) {
    try {
      // Validate input
      validateRequired(dto.identifier, 'Email or phone number');

      validateOTP(dto.otp);

      // Normalize identifier
      const normalizedIdentifier = this.normalizeIdentifier(dto.identifier);
      const isEmail = normalizedIdentifier.includes('@');

      // Find admin by email or phone
      const admin = await this.adminRepository.findOne({
        where: [{ email: normalizedIdentifier }, { phoneNumber: normalizedIdentifier }],
      });

      if (!admin) {
        throw new BadRequestException({
          status: 'error',
          message: isEmail
            ? 'No admin account found with this email address.'
            : 'No admin account found with this phone number.',
        });
      }

      // Check if admin is active
      validateAccountActive(admin.isActive, 'admin account');

      // Find the latest unused OTP
      const otpRequest = await this.adminOtpRepository.findOne({
        where: {
          adminId: admin.adminId,
          isUsed: false,
        },
        order: { createdAt: 'DESC' },
      });

      if (!otpRequest) {
        await this.createAuditLog(
          'OTP_VERIFICATION_FAILED',
          admin.adminId,
          { reason: 'otp_not_found' },
          ipAddress || null,
        );
        throw new BadRequestException({
          status: 'error',
          message: 'OTP not found. Please request a new OTP.',
        });
      }

      // Check if OTP expired
      if (otpRequest.expiresAt < new Date()) {
        await this.createAuditLog(
          'OTP_VERIFICATION_FAILED',
          admin.adminId,
          { reason: 'otp_expired' },
          ipAddress || null,
        );
        throw new BadRequestException({
          status: 'error',
          message: 'OTP has expired. Please request a new one.',
        });
      }

      // Check max attempts (3)
      if (otpRequest.attemptCount >= 3) {
        await this.createAuditLog(
          'OTP_VERIFICATION_FAILED',
          admin.adminId,
          { reason: 'max_attempts_exceeded' },
          ipAddress || null,
        );
        throw new BadRequestException({
          status: 'error',
          message: 'Too many OTP attempts. Please request a new OTP.',
        });
      }

      // Verify OTP
      const otpHash = generateHash(dto.otp);
      if (otpHash !== otpRequest.otpCode) {
        otpRequest.attemptCount += 1;
        await this.adminOtpRepository.save(otpRequest);

        await this.createAuditLog(
          'OTP_VERIFICATION_FAILED',
          admin.adminId,
          { reason: 'invalid_otp', attempts: otpRequest.attemptCount },
          ipAddress || null,
        );

        const remainingAttempts = 3 - otpRequest.attemptCount;
        throw new BadRequestException({
          status: 'error',
          message: `Invalid OTP. ${remainingAttempts > 0 ? `You have ${remainingAttempts} attempt(s) remaining.` : 'Please request a new OTP.'}`,
        });
      }

      // Mark OTP as used
      otpRequest.isUsed = true;
      await this.adminOtpRepository.save(otpRequest);

      // Generate reset token (short-lived: 10 minutes)
      const resetToken = this.jwtService.sign(
        { adminId: admin.adminId, type: 'reset' },
        { expiresIn: '10m' },
      );

      await this.createAuditLog(
        'OTP_VERIFIED',
        admin.adminId,
        null,
        ipAddress || null,
      );

      return {
        status: 'success',
        message: 'OTP verified successfully',
        resetToken,
      };
    } catch (error) {
      // Re-throw BadRequestException as-is
      if (error instanceof BadRequestException) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in verifyOtp: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new BadRequestException({
        status: 'error',
        message: 'Failed to verify OTP. Please try again later.',
      });
    }
  }

  async resendOtp(dto: AdminResendOtpDto, ipAddress?: string) {
    try {
      // Validate input
      validateRequired(dto.identifier, 'Email or phone number');

      // Always return generic success message for security (prevents user enumeration)
      const genericResponse = {
        status: 'success',
        message: 'If the account exists, a new OTP has been sent.',
      };

      // Normalize identifier
      const normalizedIdentifier = this.normalizeIdentifier(dto.identifier);
      const isEmail = normalizedIdentifier.includes('@');

      // Find admin by email or phone
      const admin = await this.adminRepository.findOne({
        where: [{ email: normalizedIdentifier }, { phoneNumber: normalizedIdentifier }],
      });

      if (!admin) {
        return genericResponse;
      }

      // Check if admin is active
      if (!admin.isActive) {
        await this.createAuditLog(
          'OTP_RESEND_FAILED',
          admin.adminId,
          { reason: 'account_inactive' },
          ipAddress || null,
        );
        return genericResponse;
      }

      // Validate that admin has the required contact method configured
      if (isEmail && !admin.email) {
        await this.createAuditLog(
          'OTP_RESEND_FAILED',
          admin.adminId,
          { reason: 'email_not_configured' },
          ipAddress || null,
        );
        return genericResponse;
      }

      if (!isEmail && !admin.phoneNumber) {
        await this.createAuditLog(
          'OTP_RESEND_FAILED',
          admin.adminId,
          { reason: 'phone_not_configured' },
          ipAddress || null,
        );
        return genericResponse;
      }

      // Check for recent OTP (cooldown: 60 seconds)
      const recentOtp = await this.adminOtpRepository.findOne({
        where: { adminId: admin.adminId },
        order: { createdAt: 'DESC' },
      });

      if (recentOtp) {
        const timeSinceLastOtp =
          (new Date().getTime() - recentOtp.createdAt.getTime()) / 1000;
        if (timeSinceLastOtp < 60) {
          const waitTime = Math.ceil(60 - timeSinceLastOtp);
          throw new BadRequestException({
            status: 'error',
            message: `Please wait ${waitTime} second(s) before requesting a new OTP.`,
          });
        }
      }

      // Invalidate previous OTPs
      await this.adminOtpRepository.update(
        { adminId: admin.adminId, isUsed: false },
        { isUsed: true },
      );

      // Generate new OTP
      const isIndian = admin?.phoneNumber?.startsWith('+91'); // Temporary fix for Indian numbers
      const otp = isIndian ? '666666' : generateOTP();
      const otpHash = generateHash(otp);
      const expiresAt = new Date();
      expiresAt.setMinutes(expiresAt.getMinutes() + 1); // 1 minute validity

      // Save new OTP
      await this.adminOtpRepository.save({
        adminId: admin.adminId,
        otpCode: otpHash,
        sentTo: normalizedIdentifier,
        expiresAt,
        attemptCount: 0,
        isUsed: false,
      });

      // Send OTP via email or SMS with error handling
      let otpSent = false;
      try {
        if (isEmail && admin.email) {
          await this.mailService.sendOTP(admin.email, otp);
          otpSent = true;
        } else if (!isEmail && admin.phoneNumber) {
          await this.otpService.sendOTP(admin.phoneNumber, otp);
          otpSent = true;
        }
      } catch (error) {
        this.logger.error(`Failed to send resend OTP to ${normalizedIdentifier}:`, error);
        // Still return generic response even if sending fails
      }

      await this.createAuditLog(
        'OTP_RESENT',
        admin.adminId,
        { sentTo: normalizedIdentifier, otpSent },
        ipAddress || null,
      );

      return genericResponse;
    } catch (error) {
      // Re-throw BadRequestException as-is
      if (error instanceof BadRequestException) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in resendOtp: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      // Return generic response even on error (security best practice)
      return {
        status: 'success',
        message: 'If the account exists, a new OTP has been sent.',
      };
    }
  }

  async resetPassword(dto: ResetPasswordDto, ipAddress?: string) {
    try {
      // Validate input
      // Validate input using utility functions
      validateToken(dto.resetToken, 'Reset token');
      validatePasswordMatch(dto.newPassword, dto.confirmPassword);

      // Verify reset token
      let payload: { adminId: string; type: string };
      try {
        payload = this.jwtService.verify(dto.resetToken);
        if (payload.type !== 'reset') {
          throw new UnauthorizedException({
            status: 'error',
            message: 'Invalid reset token.',
          });
        }
      } catch (error) {
        if (error instanceof UnauthorizedException) {
          throw error;
        }
        throw new UnauthorizedException({
          status: 'error',
          message: 'Invalid or expired reset token. Please request a new password reset.',
        });
      }

      // Find admin by adminId from token
      const admin = await this.adminRepository.findOne({
        where: { adminId: payload.adminId },
      });

      if (!admin) {
        throw new BadRequestException({
          status: 'error',
          message: 'Admin account not found.',
        });
      }

      // Check if admin is active
      validateAccountActive(admin.isActive, 'admin account');

      // Password validation is already done by validatePasswordMatch above

      // Get admin security to check old password
      const adminSecurity = await this.adminSecurityRepository.findOne({
        where: { adminId: admin.adminId },
      });

      // Check if new password is same as old password
      if (adminSecurity) {
        const isSameAsOld = await bcrypt.compare(
          dto.newPassword,
          admin.passwordHash,
        );
        if (isSameAsOld) {
          throw new BadRequestException({
            status: 'error',
            message: 'New password cannot be the same as the old password.',
          });
        }
      }

      // Hash new password
      const passwordHash = await bcrypt.hash(dto.newPassword, 10);

      // Update password
      admin.passwordHash = passwordHash;
      await this.adminRepository.save(admin);

      // Update admin security
      if (adminSecurity) {
        adminSecurity.passwordUpdatedAt = new Date();
        adminSecurity.failedLoginAttempts = 0;
        adminSecurity.lockedUntil = null; // Reset lock per policy
        await this.adminSecurityRepository.save(adminSecurity);
      }

      // Revoke all existing sessions
      await this.adminSessionRepository.update(
        { adminId: admin.adminId },
        { revokedAt: new Date() },
      );

      await this.createAuditLog(
        'PASSWORD_RESET',
        admin.adminId,
        null,
        ipAddress || null,
      );

      return {
        status: 'success',
        message: 'Password reset successful.',
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
        `Error in resetPassword: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new BadRequestException({
        status: 'error',
        message: 'Failed to reset password. Please try again later.',
      });
    }
  }

  async getMe(adminId: string) {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin || !admin.isActive) {
      throw new UnauthorizedException('Invalid session');
    }

    return {
      adminId: admin.adminId,
      email: admin.email,
      phoneNumber: admin.phoneNumber,
      role: admin.role,
      isActive: admin.isActive,
      createdAt: admin.createdAt,
    };
  }

  async createSuperAdmin(dto: CreateSuperAdminDto, ipAddress?: string) {
    // Check if email already exists
    const existingAdmin = await this.adminRepository.findOne({
      where: { email: dto.email },
    });

    if (existingAdmin) {
      throw new BadRequestException('Admin with this email already exists');
    }

    // Check if phone number already exists (if provided)
    if (dto.phoneNumber) {
      const existingPhone = await this.adminRepository.findOne({
        where: { phoneNumber: dto.phoneNumber },
      });

      if (existingPhone) {
        throw new BadRequestException('Admin with this phone number already exists');
      }
    }

    // Hash password
    const passwordHash = await bcrypt.hash(dto.password, 10);

    // Create Super Admin
    const admin = this.adminRepository.create({
      email: dto.email,
      phoneNumber: dto.phoneNumber || null,
      passwordHash,
      role: AdminRole.SUPER_ADMIN,
      isActive: true,
    });

    const savedAdmin = await this.adminRepository.save(admin);

    // Create admin security record
    const adminSecurity = this.adminSecurityRepository.create({
      adminId: savedAdmin.adminId,
      failedLoginAttempts: 0,
      passwordUpdatedAt: new Date(),
    });

    await this.adminSecurityRepository.save(adminSecurity);

    // Create audit log
    await this.createAuditLog(
      'SUPER_ADMIN_CREATED',
      savedAdmin.adminId,
      { email: dto.email, phoneNumber: dto.phoneNumber },
      ipAddress || null,
    );

    return {
      message: 'Super Admin created successfully',
      adminId: savedAdmin.adminId,
      email: savedAdmin.email,
      phoneNumber: savedAdmin.phoneNumber,
      role: savedAdmin.role,
    };
  }

  async validateSession(token: string): Promise<string> {
    try {
      const payload = this.jwtService.verify(token);
      if (payload.type !== 'admin') {
        throw new UnauthorizedException('Invalid token type');
      }

      const tokenHash = generateHash(token);

      // Find active session
      const session = await this.adminSessionRepository.findOne({
        where: { tokenHash },
      });

      if (!session) {
        throw new UnauthorizedException('Session not found');
      }

      // Check if session is revoked
      if (session.revokedAt) {
        throw new UnauthorizedException('Session revoked');
      }

      const now = new Date();

      // Check if session is expired
      if (session.expiresAt < now) {
        throw new UnauthorizedException('Session expired');
      }

      // Check for inactivity timeout (30 minutes)
      const inactivityTimeoutMs = 30 * 60 * 1000; // 30 minutes
      if (session.lastActivityAt) {
        const timeSinceLastActivity = now.getTime() - session.lastActivityAt.getTime();
        if (timeSinceLastActivity > inactivityTimeoutMs) {
          // Mark session as revoked due to inactivity
          session.revokedAt = now;
          await this.adminSessionRepository.save(session);
          throw new UnauthorizedException('Session expired due to inactivity');
        }
      }

      // Update last activity (no need to extend expiry - refresh token handles renewal)
      session.lastActivityAt = now;
      await this.adminSessionRepository.save(session);

      return payload.adminId;
    } catch (error) {
      throw new UnauthorizedException('Invalid session');
    }
  }

  async refreshToken(dto: AdminRefreshTokenDto): Promise<{
    accessToken: string;
    expiresIn: number;
  }> {
    try {
      // Verify refresh token
      const payload = this.jwtService.verify(dto.refreshToken);

      if (payload.type !== 'admin_refresh') {
        throw new UnauthorizedException('Invalid refresh token');
      }

      // Find session by hashed refresh token
      const refreshTokenHash = generateHash(dto.refreshToken);
      const session = await this.adminSessionRepository.findOne({
        where: { refreshTokenHash },
      });

      if (!session) {
        throw new UnauthorizedException('Refresh token not found');
      }

      // Check if session is revoked
      if (session.revokedAt) {
        throw new UnauthorizedException('Session has been revoked');
      }

      const now = new Date();

      // Check if session is expired
      if (session.expiresAt < now) {
        throw new UnauthorizedException('Session expired');
      }

      // Verify admin exists and is active
      const admin = await this.adminRepository.findOne({
        where: { adminId: payload.adminId },
      });

      if (!admin || !admin.isActive) {
        throw new UnauthorizedException('Admin not found or inactive');
      }

      // Generate new access token
      const accessTokenPayload = {
        adminId: admin.adminId,
        email: admin.email,
        type: 'admin',
      };

      const accessToken = this.jwtService.sign(accessTokenPayload, {
        expiresIn: this.configService.get<string>('JWT_EXP_TIME'),
      });

      // Update session with new access token hash and last activity
      session.tokenHash = generateHash(accessToken);
      session.lastActivityAt = now;
      await this.adminSessionRepository.save(session);

      // Calculate access token expiry in seconds for response
      const accessExpTime = this.configService.get<string>('JWT_EXP_TIME', '1h');
      const accessExpSeconds = CryptoUtil.timeStringToSeconds(accessExpTime);

      return {
        accessToken,
        expiresIn: accessExpSeconds, // Access token expiry in seconds from env
      };
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }
}

