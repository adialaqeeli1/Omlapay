import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  HttpException,
  HttpStatus,
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
import { generateOTP, generateHash } from '@common/filters';
import { MailService } from '@common/services/mail/mail.service';
import { OtpService } from '@common/services/otp/otp.service';

@Injectable()
export class AdminAuthService {
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

  async login(dto: AdminLoginDto, ipAddress?: string) {
    // Find admin by email or phone
    const admin = await this.adminRepository.findOne({
      where: [{ email: dto.identifier }, { phoneNumber: dto.identifier }],
    });

    if (!admin) {
      // Log failed login attempt
      await this.createAuditLog(
        'LOGIN_FAILED',
        null,
        { identifier: dto.identifier, reason: 'admin_not_found' },
        ipAddress || null,
      );
      throw new UnauthorizedException('Invalid login credentials');
    }

    // Check if admin is active
    if (!admin.isActive) {
      await this.createAuditLog(
        'LOGIN_FAILED',
        admin.adminId,
        { reason: 'account_inactive' },
        ipAddress || null,
      );
      throw new UnauthorizedException('Invalid login credentials');
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

      throw new UnauthorizedException('Invalid login credentials');
    }

    // If OTP is not provided, send OTP and return response indicating OTP is required
    if (!dto.otp) {
      // Invalidate previous login OTPs
      await this.adminOtpRepository.update(
        { adminId: admin.adminId, isUsed: false },
        { isUsed: true },
      );

      // Generate OTP
      const otp = generateOTP();
      const otpHash = generateHash(otp);
      const expiresAt = new Date();
      expiresAt.setMinutes(expiresAt.getMinutes() + 10); // 10 minutes validity

      // Save OTP
      await this.adminOtpRepository.save({
        adminId: admin.adminId,
        otpCode: otpHash,
        sentTo: dto.identifier,
        expiresAt,
        attemptCount: 0,
        isUsed: false,
      });

      // Send OTP via email or SMS
      const isEmail = dto.identifier.includes('@');
      if (isEmail && admin.email) {
        await this.mailService.sendOTP(admin.email, otp);
      } else if (!isEmail && admin.phoneNumber) {
        await this.otpService.sendOTP(admin.phoneNumber, otp);
      } else {
        console.log(`OTP for ${dto.identifier}: ${otp}`);
      }

      await this.createAuditLog(
        'LOGIN_OTP_SENT',
        admin.adminId,
        { sentTo: dto.identifier },
        ipAddress || null,
      );

      return {
        message: 'Password verified. OTP sent to your registered email or phone number.',
        requiresOtp: true,
      };
    }

    // OTP is provided, verify it
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
      throw new BadRequestException('Invalid OTP. Please request a new one.');
    }

    // Check if OTP expired
    if (otpRequest.expiresAt < new Date()) {
      await this.createAuditLog(
        'LOGIN_OTP_VERIFICATION_FAILED',
        admin.adminId,
        { reason: 'otp_expired' },
        ipAddress || null,
      );
      throw new BadRequestException('OTP has expired. Please request a new one.');
    }

    // Check max attempts (3)
    if (otpRequest.attemptCount >= 3) {
      await this.createAuditLog(
        'LOGIN_OTP_VERIFICATION_FAILED',
        admin.adminId,
        { reason: 'max_attempts_exceeded' },
        ipAddress || null,
      );
      throw new BadRequestException('Too many OTP attempts. Please request a new OTP.');
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

      throw new BadRequestException('Invalid OTP');
    }

    // Mark OTP as used
    otpRequest.isUsed = true;
    await this.adminOtpRepository.save(otpRequest);

    // Reset failed attempts on successful login
    if (adminSecurity.failedLoginAttempts > 0) {
      adminSecurity.failedLoginAttempts = 0;
      adminSecurity.lockedUntil = null;
    }
    adminSecurity.lastLoginAt = new Date();
    await this.adminSecurityRepository.save(adminSecurity);

    // Generate JWT token
    const tokenPayload = {
      adminId: admin.adminId,
      email: admin.email,
      type: 'admin',
    };

    const token = this.jwtService.sign(tokenPayload, {
      expiresIn: '1h', // 1 hour = 3600 seconds
    });

    // Hash token for storage
    const tokenHash = generateHash(token);

    // Create admin session
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 1); // 1 hour

    await this.adminSessionRepository.save({
      adminId: admin.adminId,
      tokenHash,
      ipAddress: ipAddress || null,
      userAgent: null,
      expiresAt,
    });

    await this.createAuditLog(
      'LOGIN_SUCCESS',
      admin.adminId,
      null,
      ipAddress || null,
    );

    return {
      token,
      expiresIn: 3600,
    };
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
    // Always return generic success message for security
    const genericResponse = {
      message: 'If the account exists, an OTP has been sent.',
    };

    // Find admin by email or phone
    const admin = await this.adminRepository.findOne({
      where: [{ email: dto.identifier }, { phoneNumber: dto.identifier }],
    });

    if (!admin) {
      // Don't reveal that admin doesn't exist
      await this.createAuditLog(
        'FORGOT_PASSWORD_FAILED',
        null,
        { identifier: dto.identifier, reason: 'admin_not_found' },
        ipAddress || null,
      );
      return genericResponse;
    }

    // Generate OTP
    const otp = generateOTP();
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
      sentTo: dto.identifier,
      expiresAt,
      attemptCount: 0,
      isUsed: false,
    });

    // TODO: Send OTP via email or SMS based on identifier type
    console.log(`OTP for ${dto.identifier}: ${otp}`);

    await this.createAuditLog(
      'FORGOT_PASSWORD_INITIATED',
      admin.adminId,
      { sentTo: dto.identifier },
      ipAddress || null,
    );

    return genericResponse;
  }

  async verifyOtp(dto: AdminVerifyOtpDto, ipAddress?: string) {
    // Find admin by email or phone
    const admin = await this.adminRepository.findOne({
      where: [{ email: dto.identifier }, { phoneNumber: dto.identifier }],
    });

    if (!admin) {
      throw new BadRequestException('Invalid OTP');
    }

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
      throw new BadRequestException('Invalid OTP');
    }

    // Check if OTP expired
    if (otpRequest.expiresAt < new Date()) {
      await this.createAuditLog(
        'OTP_VERIFICATION_FAILED',
        admin.adminId,
        { reason: 'otp_expired' },
        ipAddress || null,
      );
      throw new BadRequestException('OTP has expired');
    }

    // Check max attempts (3)
    if (otpRequest.attemptCount >= 3) {
      await this.createAuditLog(
        'OTP_VERIFICATION_FAILED',
        admin.adminId,
        { reason: 'max_attempts_exceeded' },
        ipAddress || null,
      );
      throw new BadRequestException('Too many attempts');
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

      throw new BadRequestException('Invalid OTP');
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
      message: 'OTP verified successfully',
      resetToken,
    };
  }

  async resendOtp(dto: AdminResendOtpDto, ipAddress?: string) {
    // Always return generic success message
    const genericResponse = {
      message: 'If the account exists, a new OTP has been sent.',
    };

    // Find admin by email or phone
    const admin = await this.adminRepository.findOne({
      where: [{ email: dto.identifier }, { phoneNumber: dto.identifier }],
    });

    if (!admin) {
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
        throw new BadRequestException(
          'Please wait before requesting a new OTP',
        );
      }
    }

    // Invalidate previous OTPs
    await this.adminOtpRepository.update(
      { adminId: admin.adminId, isUsed: false },
      { isUsed: true },
    );

    // Generate new OTP
    const otp = generateOTP();
    const otpHash = generateHash(otp);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 10); // 10 minutes validity

    // Save new OTP
    await this.adminOtpRepository.save({
      adminId: admin.adminId,
      otpCode: otpHash,
      sentTo: dto.identifier,
      expiresAt,
      attemptCount: 0,
      isUsed: false,
    });

    // TODO: Send OTP via email or SMS
    console.log(`New OTP for ${dto.identifier}: ${otp}`);

    await this.createAuditLog(
      'OTP_RESENT',
      admin.adminId,
      { sentTo: dto.identifier },
      ipAddress || null,
    );

    return genericResponse;
  }

  async resetPassword(dto: ResetPasswordDto, ipAddress?: string) {
    // Verify reset token
    let payload: { adminId: string; type: string };
    try {
      payload = this.jwtService.verify(dto.resetToken);
      if (payload.type !== 'reset') {
        throw new UnauthorizedException('Invalid reset token');
      }
    } catch (error) {
      throw new UnauthorizedException('Invalid or expired reset token');
    }

    // Find admin by adminId from token
    const admin = await this.adminRepository.findOne({
      where: { adminId: payload.adminId },
    });

    if (!admin) {
      throw new BadRequestException('Invalid request');
    }

    // Check if passwords match
    if (dto.newPassword !== dto.confirmPassword) {
      throw new BadRequestException('Passwords do not match');
    }

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
        throw new BadRequestException(
          'New password cannot be the same as the old password',
        );
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
      message: 'Password reset successful',
    };
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
      isActive: admin.isActive,
      createdAt: admin.createdAt,
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

      // Check if session is expired
      if (session.expiresAt < new Date()) {
        throw new UnauthorizedException('Session expired');
      }

      // Check if session is revoked
      if (session.revokedAt) {
        throw new UnauthorizedException('Session revoked');
      }

      return payload.adminId;
    } catch (error) {
      throw new UnauthorizedException('Invalid session');
    }
  }
}

