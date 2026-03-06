import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  NotFoundException,
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
import {
  VerifyCurrentEmailDto,
  EnterNewEmailDto,
  VerifyNewEmailDto,
} from './dto/change-email.dto';
import {
  VerifyCurrentPhoneDto,
  EnterNewPhoneDto,
  VerifyNewPhoneDto,
} from './dto/change-phone.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { generateOTP, generateHash } from '@common/filters';
import { MailService } from '@common/services/mail/mail.service';
import { OtpService } from '@common/services/otp/otp.service';
import {
  validateRequired,
  validatePasswordMatch,
  validateAccountActive,
  maskPhoneNumber,
} from '@common/utils';

@Injectable()
export class AdminProfileService {
  private readonly logger = new Logger(AdminProfileService.name);

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

  private maskEmail(email: string): string {
    if (!email) return '';
    const [local, domain] = email.split('@');
    if (local.length <= 2) return `${local[0]}***@${domain}`;
    return `${local[0]}${'*'.repeat(local.length - 2)}${local[local.length - 1]}@${domain}`;
  }

  // Change Email Flow
  async initiateChangeEmail(adminId: string, ipAddress?: string) {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin || !admin.email) {
      throw new NotFoundException('Admin email not found');
    }

    // Invalidate previous OTPs
    await this.adminOtpRepository.update(
      { adminId, isUsed: false },
      { isUsed: true },
    );

    // Generate OTP
    const otp = generateOTP();
    const otpHash = generateHash(otp);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 10);

    // Save OTP
    await this.adminOtpRepository.save({
      adminId,
      otpCode: otpHash,
      sentTo: admin.email,
      expiresAt,
      attemptCount: 0,
      isUsed: false,
    });

    // Send OTP
    await this.mailService.sendOTP(admin.email, otp);

    await this.createAuditLog(
      'CHANGE_EMAIL_INITIATED',
      adminId,
      { maskedEmail: this.maskEmail(admin.email) },
      ipAddress || null,
    );

    return {
      message: 'OTP sent to your current email address',
      maskedEmail: this.maskEmail(admin.email),
    };
  }

  async verifyCurrentEmail(
    adminId: string,
    dto: VerifyCurrentEmailDto,
    ipAddress?: string,
  ) {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin || !admin.email) {
      throw new NotFoundException('Admin email not found');
    }

    // Find latest unused OTP
    const otpRequest = await this.adminOtpRepository.findOne({
      where: {
        adminId,
        sentTo: admin.email,
        isUsed: false,
      },
      order: { createdAt: 'DESC' },
    });

    if (!otpRequest) {
      throw new BadRequestException('Invalid OTP. Please request a new one.');
    }

    if (otpRequest.expiresAt < new Date()) {
      throw new BadRequestException('OTP expired. Please resend');
    }

    if (otpRequest.attemptCount >= 3) {
      throw new BadRequestException('Too many attempts. Please request a new OTP.');
    }

    const otpHash = generateHash(dto.otp);
    if (otpHash !== otpRequest.otpCode) {
      otpRequest.attemptCount += 1;
      await this.adminOtpRepository.save(otpRequest);
      throw new BadRequestException('Invalid OTP');
    }

    // Mark OTP as used
    otpRequest.isUsed = true;
    await this.adminOtpRepository.save(otpRequest);

    await this.createAuditLog(
      'CHANGE_EMAIL_CURRENT_VERIFIED',
      adminId,
      null,
      ipAddress || null,
    );

    return {
      message: 'Current email verified. Please enter new email.',
    };
  }

  async enterNewEmail(
    adminId: string,
    dto: EnterNewEmailDto,
    ipAddress?: string,
  ) {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin) {
      throw new NotFoundException('Admin not found');
    }

    // Check if new email is same as current
    if (dto.newEmail.toLowerCase() === admin.email?.toLowerCase()) {
      throw new BadRequestException('New email must be different from current email');
    }

    // Check if email already exists
    const existingAdmin = await this.adminRepository.findOne({
      where: { email: dto.newEmail.toLowerCase() },
    });

    if (existingAdmin) {
      throw new BadRequestException('Email already exists in admin records');
    }

    // Invalidate previous OTPs for new email
    await this.adminOtpRepository.update(
      { adminId, isUsed: false },
      { isUsed: true },
    );

    // Generate OTP for new email
    const otp = generateOTP();
    const otpHash = generateHash(otp);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 10);

    // Save OTP
    await this.adminOtpRepository.save({
      adminId,
      otpCode: otpHash,
      sentTo: dto.newEmail,
      expiresAt,
      attemptCount: 0,
      isUsed: false,
    });

    // Send OTP to new email
    await this.mailService.sendOTP(dto.newEmail, otp);

    await this.createAuditLog(
      'CHANGE_EMAIL_NEW_EMAIL_ENTERED',
      adminId,
      { maskedNewEmail: this.maskEmail(dto.newEmail) },
      ipAddress || null,
    );

    return {
      message: 'OTP sent to new email address',
      maskedNewEmail: this.maskEmail(dto.newEmail),
    };
  }

  async verifyNewEmail(
    adminId: string,
    dto: VerifyNewEmailDto,
    ipAddress?: string,
  ) {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin) {
      throw new NotFoundException('Admin not found');
    }

    // Find latest unused OTP for new email
    const otpRequest = await this.adminOtpRepository.findOne({
      where: {
        adminId,
        isUsed: false,
      },
      order: { createdAt: 'DESC' },
    });

    if (!otpRequest) {
      throw new BadRequestException('Invalid OTP. Please request a new one.');
    }

    if (otpRequest.expiresAt < new Date()) {
      throw new BadRequestException('OTP expired. Please resend');
    }

    if (otpRequest.attemptCount >= 3) {
      throw new BadRequestException('Too many attempts. Please request a new OTP.');
    }

    const otpHash = generateHash(dto.otp);
    if (otpHash !== otpRequest.otpCode) {
      otpRequest.attemptCount += 1;
      await this.adminOtpRepository.save(otpRequest);
      throw new BadRequestException('Invalid OTP');
    }

    // Update email
    const newEmail = otpRequest.sentTo;
    admin.email = newEmail.toLowerCase();
    await this.adminRepository.save(admin);

    // Mark OTP as used
    otpRequest.isUsed = true;
    await this.adminOtpRepository.save(otpRequest);

    // Revoke all sessions (force re-login)
    await this.adminSessionRepository.update(
      { adminId },
      { revokedAt: new Date() },
    );

    await this.createAuditLog(
      'CHANGE_EMAIL_COMPLETED',
      adminId,
      { newEmail: this.maskEmail(newEmail) },
      ipAddress || null,
    );

    return {
      message: 'Email updated successfully. Please login again.',
    };
  }

  // Change Phone Flow
  async initiateChangePhone(adminId: string, ipAddress?: string) {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin || !admin.phoneNumber) {
      throw new NotFoundException('Admin phone number not found');
    }

    // Invalidate previous OTPs
    await this.adminOtpRepository.update(
      { adminId, isUsed: false },
      { isUsed: true },
    );

    // Generate OTP
    const isIndian = admin?.phoneNumber?.startsWith('+91'); // Temporary fix for Indian numbers
    const otp = isIndian ? '666666' : generateOTP();
    const otpHash = generateHash(otp);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 10);

    // Save OTP
    await this.adminOtpRepository.save({
      adminId,
      otpCode: otpHash,
      sentTo: admin.phoneNumber,
      expiresAt,
      attemptCount: 0,
      isUsed: false,
    });

    // Send OTP
    await this.otpService.sendOTP(admin.phoneNumber, otp);

    await this.createAuditLog(
      'CHANGE_PHONE_INITIATED',
      adminId,
      { maskedPhone: maskPhoneNumber(admin.phoneNumber) },
      ipAddress || null,
    );

    return {
      message: 'OTP sent to your current phone number',
      maskedPhone: maskPhoneNumber(admin.phoneNumber),
    };
  }

  async verifyCurrentPhone(
    adminId: string,
    dto: VerifyCurrentPhoneDto,
    ipAddress?: string,
  ) {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin || !admin.phoneNumber) {
      throw new NotFoundException('Admin phone number not found');
    }

    // Find latest unused OTP
    const otpRequest = await this.adminOtpRepository.findOne({
      where: {
        adminId,
        sentTo: admin.phoneNumber,
        isUsed: false,
      },
      order: { createdAt: 'DESC' },
    });

    if (!otpRequest) {
      throw new BadRequestException('Invalid OTP. Please request a new one.');
    }

    if (otpRequest.expiresAt < new Date()) {
      throw new BadRequestException('OTP expired. Please resend');
    }

    if (otpRequest.attemptCount >= 3) {
      throw new BadRequestException('Too many attempts. Please request a new OTP.');
    }

    const otpHash = generateHash(dto.otp);
    if (otpHash !== otpRequest.otpCode) {
      otpRequest.attemptCount += 1;
      await this.adminOtpRepository.save(otpRequest);
      throw new BadRequestException('Invalid OTP');
    }

    // Mark OTP as used
    otpRequest.isUsed = true;
    await this.adminOtpRepository.save(otpRequest);

    await this.createAuditLog(
      'CHANGE_PHONE_CURRENT_VERIFIED',
      adminId,
      null,
      ipAddress || null,
    );

    return {
      message: 'Current phone number verified. Please enter new phone number.',
    };
  }

  async enterNewPhone(
    adminId: string,
    dto: EnterNewPhoneDto,
    ipAddress?: string,
  ) {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin) {
      throw new NotFoundException('Admin not found');
    }

    // Check if new phone is same as current
    if (dto.newPhoneNumber === admin.phoneNumber) {
      throw new BadRequestException('New phone number must be different from current phone number');
    }

    // Check if phone already exists
    const existingAdmin = await this.adminRepository.findOne({
      where: { phoneNumber: dto.newPhoneNumber },
    });

    if (existingAdmin) {
      throw new BadRequestException('Phone number already exists in admin records');
    }

    // Invalidate previous OTPs
    await this.adminOtpRepository.update(
      { adminId, isUsed: false },
      { isUsed: true },
    );

    // Generate OTP for new phone
    const isIndian = admin?.phoneNumber?.startsWith('+91'); // Temporary fix for Indian numbers
    const otp = isIndian ? '666666' : generateOTP();
    const otpHash = generateHash(otp);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 10);

    // Save OTP
    await this.adminOtpRepository.save({
      adminId,
      otpCode: otpHash,
      sentTo: dto.newPhoneNumber,
      expiresAt,
      attemptCount: 0,
      isUsed: false,
    });

    // Send OTP to new phone
    await this.otpService.sendOTP(dto.newPhoneNumber, otp);

    await this.createAuditLog(
      'CHANGE_PHONE_NEW_PHONE_ENTERED',
      adminId,
      { maskedNewPhone: maskPhoneNumber(dto.newPhoneNumber) },
      ipAddress || null,
    );

    return {
      message: 'OTP sent to new phone number',
      maskedNewPhone: maskPhoneNumber(dto.newPhoneNumber),
    };
  }

  async verifyNewPhone(
    adminId: string,
    dto: VerifyNewPhoneDto,
    ipAddress?: string,
  ) {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin) {
      throw new NotFoundException('Admin not found');
    }

    // Find latest unused OTP for new phone
    const otpRequest = await this.adminOtpRepository.findOne({
      where: {
        adminId,
        isUsed: false,
      },
      order: { createdAt: 'DESC' },
    });

    if (!otpRequest) {
      throw new BadRequestException('Invalid OTP. Please request a new one.');
    }

    if (otpRequest.expiresAt < new Date()) {
      throw new BadRequestException('OTP expired. Please resend');
    }

    if (otpRequest.attemptCount >= 3) {
      throw new BadRequestException('Too many attempts. Please request a new OTP.');
    }

    const otpHash = generateHash(dto.otp);
    if (otpHash !== otpRequest.otpCode) {
      otpRequest.attemptCount += 1;
      await this.adminOtpRepository.save(otpRequest);
      throw new BadRequestException('Invalid OTP');
    }

    // Update phone
    const newPhone = otpRequest.sentTo;
    admin.phoneNumber = newPhone;
    await this.adminRepository.save(admin);

    // Mark OTP as used
    otpRequest.isUsed = true;
    await this.adminOtpRepository.save(otpRequest);

    // Revoke all sessions (force re-login)
    await this.adminSessionRepository.update(
      { adminId },
      { revokedAt: new Date() },
    );

    await this.createAuditLog(
      'CHANGE_PHONE_COMPLETED',
      adminId,
      { newPhone: maskPhoneNumber(newPhone) },
      ipAddress || null,
    );

    return {
      message: 'Phone number updated successfully. Please login again.',
    };
  }

  // Change Password
  async changePassword(
    adminId: string,
    dto: ChangePasswordDto,
    ipAddress?: string,
  ) {
    try {
      // Validate input using utility functions
      validateRequired(adminId, 'Admin ID');
      validateRequired(dto.currentPassword, 'Current password');
      validatePasswordMatch(dto.newPassword, dto.confirmPassword);

      const admin = await this.adminRepository.findOne({
        where: { adminId },
      });

      if (!admin) {
        throw new NotFoundException({
          status: 'error',
          message: 'Admin account not found.',
        });
      }

      // Check if admin is active
      validateAccountActive(admin.isActive, 'admin account');

      // Verify current password
      const isCurrentPasswordValid = await bcrypt.compare(
        dto.currentPassword,
        admin.passwordHash,
      );

      if (!isCurrentPasswordValid) {
        throw new BadRequestException({
          status: 'error',
          message: 'Incorrect current password.',
        });
      }

      // Check if new password is same as old password
      const isSameAsOld = await bcrypt.compare(dto.newPassword, admin.passwordHash);
      if (isSameAsOld) {
        throw new BadRequestException({
          status: 'error',
          message: 'New password cannot be the same as the old password.',
        });
      }

    // Hash new password
    const passwordHash = await bcrypt.hash(dto.newPassword, 10);

    // Update password
    admin.passwordHash = passwordHash;
    await this.adminRepository.save(admin);

    // Update admin security
    const adminSecurity = await this.adminSecurityRepository.findOne({
      where: { adminId },
    });

    if (adminSecurity) {
      adminSecurity.passwordUpdatedAt = new Date();
      await this.adminSecurityRepository.save(adminSecurity);
    }

    // Revoke all sessions (force re-login)
    await this.adminSessionRepository.update(
      { adminId },
      { revokedAt: new Date() },
    );

    await this.createAuditLog(
      'PASSWORD_CHANGED',
      adminId,
      null,
      ipAddress || null,
    );

      return {
        status: 'success',
        message: 'Password changed successfully. Please login again.',
      };
    } catch (error) {
      // Re-throw BadRequestException and NotFoundException as-is
      if (
        error instanceof BadRequestException ||
        error instanceof NotFoundException
      ) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in changePassword: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new BadRequestException({
        status: 'error',
        message: 'Failed to change password. Please try again later.',
      });
    }
  }

  async resendOtp(adminId: string, type: 'email' | 'phone', ipAddress?: string) {
    const admin = await this.adminRepository.findOne({
      where: { adminId },
    });

    if (!admin) {
      throw new NotFoundException('Admin not found');
    }

    // Check for recent OTP (cooldown: 60 seconds)
    const recentOtp = await this.adminOtpRepository.findOne({
      where: { adminId },
      order: { createdAt: 'DESC' },
    });

    if (recentOtp) {
      const timeSinceLastOtp =
        (new Date().getTime() - recentOtp.createdAt.getTime()) / 1000;
      if (timeSinceLastOtp < 60) {
        throw new BadRequestException('Please wait before requesting a new OTP');
      }
    }

    // Invalidate previous OTPs
    await this.adminOtpRepository.update(
      { adminId, isUsed: false },
      { isUsed: true },
    );

    // Generate new OTP
    const isIndian = admin?.phoneNumber?.startsWith('+91'); // Temporary fix for Indian numbers
    const otp = isIndian ? '666666' : generateOTP();
    const otpHash = generateHash(otp);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 10);

    let sentTo: string;
    if (type === 'email') {
      if (!admin.email) {
        throw new BadRequestException('Admin email not found');
      }
      sentTo = admin.email;
      await this.mailService.sendOTP(admin.email, otp);
    } else {
      if (!admin.phoneNumber) {
        throw new BadRequestException('Admin phone number not found');
      }
      sentTo = admin.phoneNumber;
      await this.otpService.sendOTP(admin.phoneNumber, otp);
    }

    // Save new OTP
    await this.adminOtpRepository.save({
      adminId,
      otpCode: otpHash,
      sentTo,
      expiresAt,
      attemptCount: 0,
      isUsed: false,
    });

    await this.createAuditLog(
      'OTP_RESENT',
      adminId,
      { type, sentTo: type === 'email' ? this.maskEmail(sentTo) : maskPhoneNumber(sentTo) },
      ipAddress || null,
    );

    return {
      message: 'OTP resent successfully',
    };
  }
}
