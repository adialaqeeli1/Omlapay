import {
  Controller,
  Post,
  UseGuards,
  Body,
  HttpCode,
  HttpStatus,
  Ip,
  Param,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AdminProfileService } from './admin-profile.service';
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
import { AdminJwtAuthGuard, SuperAdminGuard } from '@common/guards';
import { CurrentAdmin } from '@common/decorators';

@ApiTags('Admin Profile')
@Controller({ path: 'admin/profile', version: '1' })
@UseGuards(AdminJwtAuthGuard)
@ApiBearerAuth()
export class AdminProfileController {
  constructor(private readonly adminProfileService: AdminProfileService) {}

  // Change Email Flow
  @Post('change-email/initiate')
  @UseGuards(SuperAdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Step 1: Initiate change email - sends OTP to current email (Super Admin only)' })
  @ApiResponse({ status: 200, description: 'OTP sent to current email' })
  @ApiResponse({ status: 403, description: 'Access denied. Super Admin role required' })
  async initiateChangeEmail(
    @CurrentAdmin() adminId: string,
    @Ip() ipAddress: string,
  ) {
    return this.adminProfileService.initiateChangeEmail(adminId, ipAddress);
  }

  @Post('change-email/verify-current')
  @UseGuards(SuperAdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Step 2: Verify current email with OTP (Super Admin only)' })
  @ApiResponse({ status: 200, description: 'Current email verified' })
  @ApiResponse({ status: 400, description: 'Invalid or expired OTP' })
  @ApiResponse({ status: 403, description: 'Access denied. Super Admin role required' })
  async verifyCurrentEmail(
    @CurrentAdmin() adminId: string,
    @Body() dto: VerifyCurrentEmailDto,
    @Ip() ipAddress: string,
  ) {
    return this.adminProfileService.verifyCurrentEmail(adminId, dto, ipAddress);
  }

  @Post('change-email/enter-new')
  @UseGuards(SuperAdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Step 3: Enter new email address (Super Admin only)' })
  @ApiResponse({ status: 200, description: 'OTP sent to new email' })
  @ApiResponse({ status: 400, description: 'Invalid email or email already exists' })
  @ApiResponse({ status: 403, description: 'Access denied. Super Admin role required' })
  async enterNewEmail(
    @CurrentAdmin() adminId: string,
    @Body() dto: EnterNewEmailDto,
    @Ip() ipAddress: string,
  ) {
    return this.adminProfileService.enterNewEmail(adminId, dto, ipAddress);
  }

  @Post('change-email/verify-new')
  @UseGuards(SuperAdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Step 4: Verify new email with OTP and complete update (Super Admin only)' })
  @ApiResponse({ status: 200, description: 'Email updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid or expired OTP' })
  @ApiResponse({ status: 403, description: 'Access denied. Super Admin role required' })
  async verifyNewEmail(
    @CurrentAdmin() adminId: string,
    @Body() dto: VerifyNewEmailDto,
    @Ip() ipAddress: string,
  ) {
    return this.adminProfileService.verifyNewEmail(adminId, dto, ipAddress);
  }

  // Change Phone Flow
  @Post('change-phone/initiate')
  @UseGuards(SuperAdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Step 1: Initiate change phone - sends OTP to current phone (Super Admin only)' })
  @ApiResponse({ status: 200, description: 'OTP sent to current phone' })
  @ApiResponse({ status: 403, description: 'Access denied. Super Admin role required' })
  async initiateChangePhone(
    @CurrentAdmin() adminId: string,
    @Ip() ipAddress: string,
  ) {
    return this.adminProfileService.initiateChangePhone(adminId, ipAddress);
  }

  @Post('change-phone/verify-current')
  @UseGuards(SuperAdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Step 2: Verify current phone with OTP (Super Admin only)' })
  @ApiResponse({ status: 200, description: 'Current phone verified' })
  @ApiResponse({ status: 400, description: 'Invalid or expired OTP' })
  @ApiResponse({ status: 403, description: 'Access denied. Super Admin role required' })
  async verifyCurrentPhone(
    @CurrentAdmin() adminId: string,
    @Body() dto: VerifyCurrentPhoneDto,
    @Ip() ipAddress: string,
  ) {
    return this.adminProfileService.verifyCurrentPhone(adminId, dto, ipAddress);
  }

  @Post('change-phone/enter-new')
  @UseGuards(SuperAdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Step 3: Enter new phone number (Super Admin only)' })
  @ApiResponse({ status: 200, description: 'OTP sent to new phone' })
  @ApiResponse({ status: 400, description: 'Invalid phone or phone already exists' })
  @ApiResponse({ status: 403, description: 'Access denied. Super Admin role required' })
  async enterNewPhone(
    @CurrentAdmin() adminId: string,
    @Body() dto: EnterNewPhoneDto,
    @Ip() ipAddress: string,
  ) {
    return this.adminProfileService.enterNewPhone(adminId, dto, ipAddress);
  }

  @Post('change-phone/verify-new')
  @UseGuards(SuperAdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Step 4: Verify new phone with OTP and complete update (Super Admin only)' })
  @ApiResponse({ status: 200, description: 'Phone number updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid or expired OTP' })
  @ApiResponse({ status: 403, description: 'Access denied. Super Admin role required' })
  async verifyNewPhone(
    @CurrentAdmin() adminId: string,
    @Body() dto: VerifyNewPhoneDto,
    @Ip() ipAddress: string,
  ) {
    return this.adminProfileService.verifyNewPhone(adminId, dto, ipAddress);
  }

  // Change Password
  @Post('change-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Change admin password' })
  @ApiResponse({ status: 200, description: 'Password changed successfully' })
  @ApiResponse({ status: 400, description: 'Invalid current password or password mismatch' })
  async changePassword(
    @CurrentAdmin() adminId: string,
    @Body() dto: ChangePasswordDto,
    @Ip() ipAddress: string,
  ) {
    return this.adminProfileService.changePassword(adminId, dto, ipAddress);
  }

  // Resend OTP
  @Post('resend-otp/:type')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Resend OTP for email or phone change (cooldown: 60 seconds)' })
  @ApiResponse({ status: 200, description: 'OTP resent successfully' })
  @ApiResponse({ status: 400, description: 'Cooldown period not met' })
  async resendOtp(
    @CurrentAdmin() adminId: string,
    @Param('type') type: 'email' | 'phone',
    @Ip() ipAddress: string,
  ) {
    return this.adminProfileService.resendOtp(adminId, type, ipAddress);
  }
}
