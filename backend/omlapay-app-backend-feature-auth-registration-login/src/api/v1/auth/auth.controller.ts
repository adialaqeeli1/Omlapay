import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { ResendOtpDto } from './dto/resend-otp.dto';
import { EmailVerificationRequestDto } from './dto/email-verification-request.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';
import { ForgotPasscodeDto } from './dto/forgot-passcode.dto';
import { ForgotPasscodeVerifyOtpDto } from './dto/forgot-passcode-verify-otp.dto';
import { ForgotPasscodeResendOtpDto } from './dto/forgot-passcode-resend-otp.dto';

@ApiTags('Auth')
@Controller({ path: 'auth', version: '1' })
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login with mobile number and passcode' })
  @ApiResponse({ status: 200, description: 'Login successful' })
  @ApiResponse({ status: 400, description: 'Invalid mobile number' })
  @ApiResponse({ status: 401, description: 'Incorrect passcode' })
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify registration OTP' })
  @ApiResponse({ status: 200, description: 'Mobile number verified' })
  @ApiResponse({ status: 400, description: 'Invalid or expired OTP' })
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyOtp(dto);
  }

  @Post('resend-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary:
      'Resend OTP. Automatically detects the most recent OTP request for the mobile number.',
  })
  @ApiResponse({ status: 200, description: 'OTP resent successfully' })
  @ApiResponse({ status: 400, description: 'Rate limit exceeded, no active OTP request, or invalid request' })
  async resendOtp(@Body() dto: ResendOtpDto) {
    return this.authService.resendOtp(dto);
  }

  @Post('email/request-verification')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Submit email address for verification' })
  @ApiResponse({ status: 200, description: 'Verification email sent' })
  @ApiResponse({
    status: 400,
    description: 'Invalid email or mobile not verified',
  })
  @ApiResponse({ status: 409, description: 'Email already registered' })
  async requestEmailVerification(@Body() dto: EmailVerificationRequestDto) {
    return this.authService.requestEmailVerification(dto);
  }

  @Post('email/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify email verification code' })
  @ApiResponse({ status: 200, description: 'Email verified successfully' })
  @ApiResponse({
    status: 400,
    description: 'Invalid or expired verification code',
  })
  async verifyEmail(@Body() dto: VerifyEmailDto) {
    return this.authService.verifyEmail(dto);
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
}
