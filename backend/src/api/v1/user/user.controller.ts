import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  Put,
  Get,
  UseGuards,
  Headers,
  Req,
  Res,
  Param,
} from '@nestjs/common';
import { Response } from 'express';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiExcludeEndpoint,
} from '@nestjs/swagger';
import { UserService } from './user.service';
import { RegisterRequestDto } from './dto/register-request.dto';
import { VerifyOtpDto } from '../auth/dto/verify-otp.dto';
import { ResendOtpDto } from '../auth/dto/resend-otp.dto';
import { SetPasscodeDto } from './dto/set-passcode.dto';
import { UpdateAppearanceDto } from './dto/update-appearance.dto';
import { UpdateLanguageDto } from './dto/update-language.dto';
import { UpdateNotificationsDto } from './dto/update-notifications.dto';
import { Enable2FARequestDto } from './dto/enable-2fa-request.dto';
import { Verify2FADto } from './dto/verify-2fa.dto';
import { StartKycDto } from './dto/start-kyc.dto';
import { UpdateOnboardingDto } from './dto/update-onboarding.dto';
import { JwtAuthGuard } from '@common/guards';
import { CurrentUser } from '@common/decorators';

@ApiTags('User')
@Controller({ path: 'user', version: '1' })
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post('register/request')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Submit mobile number for registration' })
  @ApiResponse({ status: 200, description: 'OTP sent successfully' })
  @ApiResponse({ status: 409, description: 'Mobile number already registered' })
  async registerRequest(@Body() dto: RegisterRequestDto) {
    return this.userService.registerRequest(dto);
  }

  @Post('register/verify-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify registration OTP' })
  @ApiResponse({ status: 200, description: 'Mobile number verified, registration token issued' })
  @ApiResponse({ status: 400, description: 'Invalid or expired OTP' })
  async verifyRegistrationOtp(@Body() dto: VerifyOtpDto) {
    return this.userService.verifyRegistrationOtp(dto);
  }

  @Post('register/resend-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Resend registration OTP' })
  @ApiResponse({ status: 200, description: 'OTP resent successfully' })
  @ApiResponse({ status: 400, description: 'Rate limit exceeded or no active registration found' })
  @ApiResponse({ status: 409, description: 'Mobile number already registered' })
  async resendRegistrationOtp(@Body() dto: ResendOtpDto) {
    return this.userService.resendRegistrationOtp(dto);
  }

  @Post('register/set-passcode')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Create passcode to complete registration' })
  @ApiResponse({
    status: 200,
    description: 'Registration completed successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid passcode or validation failed',
  })
  async setPasscode(@Body() dto: SetPasscodeDto) {
    return this.userService.setPasscode(dto);
  }

  @Put('settings/appearance')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update user appearance theme preference' })
  @ApiResponse({ status: 200, description: 'Appearance updated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateAppearance(
    @CurrentUser() user: any,
    @Body() dto: UpdateAppearanceDto,
  ) {
    return this.userService.updateAppearance(user.userId, dto);
  }

  @Get('settings/appearance')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get user appearance theme preference' })
  @ApiResponse({ status: 200, description: 'Returns user theme preference' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getAppearance(@CurrentUser() user: any) {
    return this.userService.getAppearance(user.userId);
  }

  @Put('settings/language')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update user language preference' })
  @ApiResponse({ status: 200, description: 'Language preference updated' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateLanguage(
    @CurrentUser() user: any,
    @Body() dto: UpdateLanguageDto,
  ) {
    return this.userService.updateLanguage(user.userId, dto);
  }

  @Get('settings/language')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get user language preference' })
  @ApiResponse({
    status: 200,
    description: 'Returns user language preference with direction',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getLanguage(@CurrentUser() user: any) {
    return this.userService.getLanguage(user.userId);
  }

  @Put('settings/notifications')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update user notification settings' })
  @ApiResponse({ status: 200, description: 'Notification settings updated' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateNotifications(
    @CurrentUser() user: any,
    @Body() dto: UpdateNotificationsDto,
  ) {
    return this.userService.updateNotifications(user.userId, dto);
  }

  @Get('settings/notifications')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get user notification settings' })
  @ApiResponse({
    status: 200,
    description: 'Returns user notification settings',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getNotifications(@CurrentUser() user: any) {
    return this.userService.getNotifications(user.userId);
  }

  @Post('onboarding')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Update onboarding status (complete or skip)',
    description: 'Single endpoint to mark onboarding as completed or skipped',
  })
  @ApiResponse({
    status: 200,
    description: 'Onboarding status updated successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateOnboarding(
    @CurrentUser() user: any,
    @Body() dto: UpdateOnboardingDto,
  ) {
    return this.userService.updateOnboarding(user.userId, dto);
  }

  @Get('onboarding-status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get onboarding status',
    description: 'Returns whether user needs language selection and onboarding',
  })
  @ApiResponse({
    status: 200,
    description: 'Onboarding status retrieved successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getOnboardingStatus(@CurrentUser() user: any) {
    return this.userService.getOnboardingStatus(user.userId);
  }

  @Post('settings/2fa/enable')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Request to enable two-factor authentication' })
  @ApiResponse({
    status: 200,
    description: 'Verification codes sent to mobile and email',
  })
  @ApiResponse({
    status: 400,
    description: 'Mobile number or email mismatch, or 2FA already enabled',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async enable2FARequest(
    @CurrentUser() user: any,
    @Body() dto: Enable2FARequestDto,
  ) {
    return this.userService.enable2FARequest(user.userId, dto);
  }

  @Post('settings/2fa/verify')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify codes to enable two-factor authentication' })
  @ApiResponse({
    status: 200,
    description: 'Two-factor authentication enabled successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid OTPs or verification failed' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async verify2FA(@CurrentUser() user: any, @Body() dto: Verify2FADto) {
    return this.userService.verify2FA(user.userId, dto);
  }

  @Post('settings/2fa/disable')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Disable two-factor authentication' })
  @ApiResponse({
    status: 200,
    description: 'Two-factor authentication disabled successfully',
  })
  @ApiResponse({ status: 400, description: '2FA not enabled' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async disable2FA(@CurrentUser() user: any) {
    return this.userService.disable2FA(user.userId);
  }

  @Post('kyc/start')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Start KYC process via Sumsub' })
  @ApiResponse({
    status: 200,
    description: 'KYC access token generated successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async startKyc(@CurrentUser() user: any, @Body() dto?: StartKycDto) {
    return this.userService.startKyc(user.userId, dto);
  }

  @Get('kyc/status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user KYC status for Sumsub and Binance' })
  @ApiResponse({
    status: 200,
    description: 'KYC status retrieved successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getKycStatus(@CurrentUser() user: any) {
    return this.userService.getKycStatus(user.userId);
  }

  @Post('kyc/binance/start')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Start Binance KYC (requires Sumsub approved)' })
  @ApiResponse({ status: 200, description: 'Binance KYC submitted' })
  @ApiResponse({ status: 400, description: 'Sumsub not approved or config missing' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async startBinanceKyc(@CurrentUser() user: any) {
    return this.userService.startBinanceKyc(user.userId);
  }

  @Post('kyc/binance/check-status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Check Binance KYC status from Binance API' })
  @ApiResponse({ status: 200, description: 'KYC status retrieved' })
  @ApiResponse({ status: 400, description: 'No Binance sub-account found' })
  async checkBinanceKycStatus(@CurrentUser() user: any) {
    return this.userService.checkBinanceKycStatus(user.userId);
  }

  @Post('kyc/binance/create-api-keys')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Create Binance API keys for sub-account (after KYC approved)' })
  @ApiResponse({ status: 200, description: 'API keys created' })
  @ApiResponse({ status: 400, description: 'KYC not approved or keys already exist' })
  async createBinanceApiKeys(@CurrentUser() user: any) {
    return this.userService.createBinanceApiKeys(user.userId);
  }

  @Get('kyc/documents/:token')
  @ApiExcludeEndpoint()
  async getKycDocument(
    @Param('token') token: string,
    @Res() res: Response,
  ) {
    const { buffer, contentType } = await this.userService.getKycDocumentStream(token);
    res.setHeader('Content-Type', contentType);
    res.send(buffer);
  }

  @Post('webhooks/sumsub')
  @HttpCode(HttpStatus.OK)
  @ApiExcludeEndpoint()
  async handleSumsubWebhook(
    @Body() payload: any,
    @Headers('x-payload-digest') digest: string | undefined,
    @Headers('x-payload-digest-alg') algorithm: string | undefined,
    @Req() req: any,
  ) {
    return this.userService.handleSumsubWebhook(payload, digest, req.rawBody, algorithm);
  }

  @Post('webhooks/binance-kyc')
  @HttpCode(HttpStatus.OK)
  @ApiExcludeEndpoint()
  async handleBinanceKycWebhook(@Body() payload: any) {
    return this.userService.handleBinanceKycWebhook(payload);
  }
}
