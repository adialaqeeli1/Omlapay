import {
  Controller,
  Post,
  Get,
  Body,
  HttpCode,
  HttpStatus,
  UseGuards,
  Headers,
  Ip,
  BadRequestException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AdminAuthService } from './admin-auth.service';
import { AdminLoginDto } from './dto/admin-login.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { AdminVerifyOtpDto } from './dto/verify-otp.dto';
import { AdminResendOtpDto } from './dto/resend-otp.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { AdminJwtAuthGuard } from '@common/guards';
import { CurrentAdmin } from '@common/decorators';

@ApiTags('Admin Auth')
@Controller({ path: 'admin/auth', version: '1' })
export class AdminAuthController {
  constructor(private readonly adminAuthService: AdminAuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Admin login with email/phone, password, and OTP' })
  @ApiResponse({ status: 200, description: 'Login successful' })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Invalid login credentials' })
  @ApiResponse({ status: 423, description: 'Account temporarily locked' })
  async login(
    @Body() dto: AdminLoginDto,
    @Ip() ipAddress: string,
  ) {
    return this.adminAuthService.login(dto, ipAddress);
  }

  @Post('logout')
  @UseGuards(AdminJwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Admin logout' })
  @ApiResponse({ status: 200, description: 'Logged out successfully' })
  async logout(@CurrentAdmin() adminId: string) {
    return this.adminAuthService.logout(adminId);
  }

  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Initiate password recovery' })
  @ApiResponse({
    status: 200,
    description: 'If the account exists, an OTP has been sent',
  })
  async forgotPassword(@Body() dto: ForgotPasswordDto, @Ip() ipAddress: string) {
    return this.adminAuthService.forgotPassword(dto, ipAddress);
  }

  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify OTP for password reset' })
  @ApiResponse({ status: 200, description: 'OTP verified successfully' })
  @ApiResponse({ status: 400, description: 'Invalid or expired OTP' })
  async verifyOtp(@Body() dto: AdminVerifyOtpDto, @Ip() ipAddress: string) {
    return this.adminAuthService.verifyOtp(dto, ipAddress);
  }

  @Post('resend-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Resend OTP with cooldown enforcement' })
  @ApiResponse({ status: 200, description: 'OTP resent successfully' })
  @ApiResponse({ status: 400, description: 'Cooldown period not met' })
  async resendOtp(@Body() dto: AdminResendOtpDto, @Ip() ipAddress: string) {
    return this.adminAuthService.resendOtp(dto, ipAddress);
  }

  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reset password after OTP verification' })
  @ApiResponse({ status: 200, description: 'Password reset successful' })
  @ApiResponse({ status: 400, description: 'Invalid reset token or passwords do not match' })
  async resetPassword(
    @Body() dto: ResetPasswordDto,
    @Ip() ipAddress: string,
  ) {
    return this.adminAuthService.resetPassword(dto, ipAddress);
  }

  @Get('me')
  @UseGuards(AdminJwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get current admin profile' })
  @ApiResponse({ status: 200, description: 'Admin profile retrieved' })
  @ApiResponse({ status: 401, description: 'Invalid session' })
  async getMe(@CurrentAdmin() adminId: string) {
    return this.adminAuthService.getMe(adminId);
  }
}

