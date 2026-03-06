import { Controller, Post, Body, HttpCode, HttpStatus, Get, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { CheckUserDto } from './dto/check-user.dto';
import { SoftLoginDto } from './dto/soft-login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ForgotPasscodeDto } from './dto/forgot-passcode.dto';
import { ForgotPasscodeVerifyOtpDto } from './dto/forgot-passcode-verify-otp.dto';
import { ForgotPasscodeResendOtpDto } from './dto/forgot-passcode-resend-otp.dto';
import { ResetPasscodeDto } from '../user/dto/reset-passcode.dto';
import { JwtAuthGuard } from '@common/guards/jwt-auth.guard';

@ApiTags('Auth')
@Controller({ path: 'auth', version: '1' })
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('check-user')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Check if user exists (two-step login flow)',
    description:
      'Returns whether a user exists for the given phone number. Use before showing passcode or registration screen.',
  })
  @ApiResponse({
    status: 200,
    description:
      'Returns userExists: true if user has account (show passcode screen), false if not (show registration).',
  })
  @ApiResponse({ status: 400, description: 'Invalid mobile number' })
  async checkUser(@Body() dto: CheckUserDto) {
    return this.authService.checkUser(dto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login with mobile number and passcode' })
  @ApiResponse({ status: 200, description: 'Login successful' })
  @ApiResponse({ status: 400, description: 'Invalid mobile number' })
  @ApiResponse({ status: 401, description: 'Incorrect passcode' })
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('forgot-passcode')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary:
      'Start forgot passcode flow. Sends OTPs to both mobile and email if 2FA is enabled, otherwise only to mobile.',
  })
  @ApiResponse({
    status: 200,
    description:
      'OTPs sent to mobile and email (if 2FA enabled) or mobile only (if 2FA disabled)',
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid mobile number or user not found',
  })
  async forgotPasscode(@Body() dto: ForgotPasscodeDto) {
    return this.authService.forgotPasscode(dto);
  }

  @Post('forgot-passcode/verify-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary:
      'Verify OTP for forgot passcode. Verifies both mobile and email OTPs if 2FA is enabled, otherwise only mobile OTP.',
  })
  @ApiResponse({ status: 200, description: 'OTP verification successful' })
  @ApiResponse({ status: 400, description: 'Invalid or expired OTP' })
  async verifyForgotPasscodeOtps(@Body() dto: ForgotPasscodeVerifyOtpDto) {
    return this.authService.verifyForgotPasscodeOtps(dto);
  }

  @Post('forgot-passcode/resend-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary:
      'Resend OTPs for forgot passcode. Resends to both mobile and email if 2FA is enabled, otherwise only to mobile.',
  })
  @ApiResponse({ status: 200, description: 'OTPs resent successfully' })
  @ApiResponse({ status: 400, description: 'Rate limit exceeded' })
  async resendForgotPasscodeOtps(@Body() dto: ForgotPasscodeResendOtpDto) {
    return this.authService.resendForgotPasscodeOtps(dto);
  }

  @Post('forgot-passcode/reset')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reset passcode after forgot passcode flow' })
  @ApiResponse({ status: 200, description: 'Passcode reset successfully' })
  @ApiResponse({
    status: 400,
    description: 'Invalid reset token or passcodes do not match',
  })
  @ApiResponse({ status: 401, description: 'Invalid or expired reset token' })
  async resetPasscode(@Body() dto: ResetPasscodeDto) {
    return this.authService.resetPasscode(dto);
  }

  @Post('soft-login')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Soft login - Verify passcode for existing session',
  })
  @ApiResponse({ status: 200, description: 'Passcode verified successfully' })
  @ApiResponse({ status: 401, description: 'Invalid passcode, session expired, or account locked' })
  async softLogin(@Req() req, @Body() dto: SoftLoginDto) {
    return this.authService.softLogin(req.user.userId, req.user.sessionId, dto);
  }

  @Post('refresh-token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Refresh access token using refresh token',
  })
  @ApiResponse({ status: 200, description: 'Token refreshed successfully' })
  @ApiResponse({ status: 401, description: 'Invalid or expired refresh token' })
  async refreshToken(@Body() dto: RefreshTokenDto) {
    return this.authService.refreshToken(dto);
  }

  @Get('session-status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Check if current session is valid',
  })
  @ApiResponse({ status: 200, description: 'Session status retrieved' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getSessionStatus(@Req() req) {
    return this.authService.getSessionStatus(req.user.userId, req.user.sessionId);
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Logout - Revoke current session',
  })
  @ApiResponse({ status: 200, description: 'Logged out successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async logout(@Req() req) {
    return this.authService.logout(req.user.userId, req.user.sessionId);
  }

  @Post('logout-all')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Logout all devices - Revoke all sessions',
  })
  @ApiResponse({ status: 200, description: 'All sessions logged out' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async logoutAll(@Req() req) {
    return this.authService.logoutAll(req.user.userId);
  }
}
