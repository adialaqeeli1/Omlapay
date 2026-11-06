import { ThrottleCodeSend, ThrottleCredentialCheck } from '@common/decorators';
import { SkipThrottle } from '@nestjs/throttler';
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
import { UpdateCurrencyDto } from './dto/update-currency.dto';
import { InviteContactDto } from './dto/invite-contact.dto';
import { UpdateLanguageDto } from './dto/update-language.dto';
import { UpdateNotificationsDto } from './dto/update-notifications.dto';
import { Enable2FARequestDto } from './dto/enable-2fa-request.dto';
import { Verify2FADto } from './dto/verify-2fa.dto';
import { StartKycDto } from './dto/start-kyc.dto';
import { UpdateOnboardingDto } from './dto/update-onboarding.dto';
import { RequestDeletionDto } from './dto/request-deletion.dto';
import { ChangePasscodeDto } from './dto/change-passcode.dto';
import { ChangePasscodeService } from './change-passcode.service';
import { AccountDeletionService } from './account-deletion.service';
import { JwtAuthGuard } from '@common/guards';
import { CurrentUser } from '@common/decorators';

@ApiTags('User')
@Controller({ path: 'user', version: '1' })
export class UserController {
  constructor(
    private readonly userService: UserService,
    private readonly accountDeletion: AccountDeletionService,
    private readonly changePasscodeService: ChangePasscodeService,
  ) {}

  @Post('register/request')
  @ThrottleCodeSend()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Submit mobile number for registration' })
  @ApiResponse({ status: 200, description: 'OTP sent successfully' })
  @ApiResponse({ status: 409, description: 'Mobile number already registered' })
  async registerRequest(@Body() dto: RegisterRequestDto) {
    return this.userService.registerRequest(dto);
  }

  @Post('register/verify-otp')
  @ThrottleCredentialCheck()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify registration OTP' })
  @ApiResponse({ status: 200, description: 'Mobile number verified, registration token issued' })
  @ApiResponse({ status: 400, description: 'Invalid or expired OTP' })
  async verifyRegistrationOtp(@Body() dto: VerifyOtpDto) {
    return this.userService.verifyRegistrationOtp(dto);
  }

  @Post('register/resend-otp')
  @ThrottleCodeSend()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Resend registration OTP' })
  @ApiResponse({ status: 200, description: 'OTP resent successfully' })
  @ApiResponse({ status: 400, description: 'Rate limit exceeded or no active registration found' })
  @ApiResponse({ status: 409, description: 'Mobile number already registered' })
  async resendRegistrationOtp(@Body() dto: ResendOtpDto) {
    return this.userService.resendRegistrationOtp(dto);
  }

  @Post('register/set-passcode')
  @ThrottleCredentialCheck()
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

  @Post('settings/change-passcode')
  @ThrottleCredentialCheck()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Change passcode (current passcode required)',
    description:
      'Wrong current passcodes count toward the lockout. The new passcode must match confirm_passcode, differ from the ' +
      'current one (SAME_PASSCODE) and not be obvious like 111111 or 123456 (WEAK_PASSCODE). Logs out every other ' +
      'session and remembered phone; returns a new session for this phone. Sends an SMS alert.',
  })
  @ApiResponse({
    status: 200,
    description: 'Changed; data has access_token, refresh_token, expires_in',
  })
  @ApiResponse({ status: 400, description: 'Mismatch, same or weak passcode' })
  @ApiResponse({
    status: 401,
    description: 'Wrong current passcode or not logged in',
  })
  async changePasscode(
    @CurrentUser() user: { userId: string; sessionId: string },
    @Body() dto: ChangePasscodeDto,
  ) {
    return this.changePasscodeService.changePasscode(
      user.userId,
      user.sessionId,
      dto,
    );
  }

  @Post('settings/request-deletion')
  @ThrottleCredentialCheck()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Schedule account deletion (7-day grace period; logging in again cancels it)',
    description:
      'Needs the passcode. Refused while any wallet has a balance (ACCOUNT_HAS_BALANCE) or a transfer/swap is in progress ' +
      '(ACCOUNT_HAS_PENDING_ACTIVITY). Logs out every session and device. After 7 days personal data is erased; ' +
      'transactions and KYC records are kept for the legal retention period.',
  })
  @ApiResponse({ status: 200, description: 'Deletion scheduled (data.deletion_scheduled_for)' })
  @ApiResponse({ status: 400, description: 'Balance or activity in progress' })
  @ApiResponse({ status: 401, description: 'Wrong passcode or not logged in' })
  async requestDeletion(
    @CurrentUser() user: { userId: string; sessionId: string },
    @Body() dto: RequestDeletionDto,
  ) {
    return this.accountDeletion.requestDeletion(
      user.userId,
      user.sessionId,
      dto.passcode,
    );
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

  @Put('settings/currency')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update user display currency preference' })
  @ApiResponse({ status: 200, description: 'Display currency updated (USD or SAR)' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateCurrency(
    @CurrentUser() user: any,
    @Body() dto: UpdateCurrencyDto,
  ) {
    return this.userService.updateCurrency(user.userId, dto);
  }

  @Get('settings/currency')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get user display currency preference' })
  @ApiResponse({
    status: 200,
    description: 'Returns user display currency (USD or SAR)',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getCurrency(@CurrentUser() user: any) {
    return this.userService.getCurrency(user.userId);
  }

  @Post('invite')
  @ThrottleCodeSend()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Send invitation to a contact',
    description:
      'Sends an SMS invitation to a phone number that is not yet registered on Omlapay. Use when user selects a contact from the Send flow who does not have an account.',
  })
  @ApiResponse({ status: 200, description: 'Invitation sent successfully' })
  @ApiResponse({ status: 400, description: 'Phone already registered or invalid' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async inviteContact(
    @CurrentUser() user: any,
    @Body() dto: InviteContactDto,
  ) {
    return this.userService.inviteContact(user.userId, dto);
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

  @Get('account-details')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Get account details',
    description:
      'Returns masked phone, email (if present), and wallet addresses by network. Wallets require KYC.',
  })
  @ApiResponse({
    status: 200,
    description: 'Account details retrieved successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getAccountDetails(@CurrentUser() user: any) {
    return this.userService.getAccountDetails(user.userId);
  }

  @Post('settings/2fa/enable')
  @ThrottleCodeSend()
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
  @ThrottleCredentialCheck()
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
  @ThrottleCredentialCheck()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary:
      'Disable two-factor authentication. Logs out every session and returns a new one for this device.',
  })
  @ApiResponse({
    status: 200,
    description:
      'Two-factor authentication disabled; data has access_token, refresh_token, expires_in',
  })
  @ApiResponse({ status: 400, description: '2FA not enabled' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async disable2FA(
    @CurrentUser() user: { userId: string; sessionId?: string },
  ) {
    return this.userService.disable2FA(user.userId, user.sessionId);
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
  @ApiOperation({
    summary: 'Get user KYC status for Sumsub and Binance',
    description:
      'Returns combined KYC status. Sumsub must be APPROVED before Binance KYC can start.',
  })
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
  @ApiOperation({
    summary: 'Step 2: Share KYC with Binance (requires Sumsub approved)',
    description:
      'Creates sub-account if needed, shares KYC via /bapi/ekyc/v2/public/ekyc/customer/share-kyc-data. Requires Sumsub KYC approved first.',
  })
  @ApiResponse({ status: 200, description: 'Binance KYC submitted' })
  @ApiResponse({ status: 400, description: 'Sumsub not approved or config missing' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async startBinanceKyc(@CurrentUser() user: any, @Req() req: any) {
    const clientIp =
      req.headers['x-forwarded-for']?.split(',')[0]?.trim() ||
      req.headers['x-real-ip'] ||
      req.socket?.remoteAddress ||
      '0.0.0.0';
    return this.userService.startBinanceKyc(user.userId, clientIp);
  }

  @Post('kyc/binance/check-status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Step 3: Check Binance KYC status',
    description:
      'Calls /bapi/ekyc/v2/public/ekyc/customer/check-kyc-status. kycPassed=true when data.levelInfo.currentLevel.kycStatus=PASS.',
  })
  @ApiResponse({ status: 200, description: 'KYC status retrieved (kycPassed when PASS)' })
  @ApiResponse({ status: 400, description: 'No Binance sub-account found' })
  async checkBinanceKycStatus(@CurrentUser() user: any) {
    return this.userService.checkBinanceKycStatus(user.userId);
  }

  @Post('kyc/binance/create-api-keys')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Step 4: Create sub-account API keys (after KYC PASS)',
    description:
      'Calls POST /sapi/v1/broker/subAccountApi. Only available when Binance KYC status is PASS.',
  })
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
  @SkipThrottle() // providers retry in bursts
  @HttpCode(HttpStatus.OK)
  @ApiExcludeEndpoint()
  async handleSumsubWebhook(
    @Body() payload: any,
    @Headers('x-payload-digest') digest: string | undefined,
    @Headers('x-payload-digest-alg') algorithm: string | undefined,
    @Req() req: any,
  ) {
    const rawBody = req.rawBody
      ? typeof req.rawBody === 'string'
        ? req.rawBody
        : req.rawBody.toString('utf8')
      : undefined;
    return this.userService.handleSumsubWebhook(payload, digest, rawBody, algorithm);
  }

  @Post('webhooks/binance-kyc')
  @SkipThrottle() // providers retry in bursts
  @HttpCode(HttpStatus.OK)
  @ApiExcludeEndpoint()
  async handleBinanceKycWebhook(
    @Body() payload: any,
    @Headers('x-sha2-signature') signatureHeader: string | undefined,
    @Req() req: any,
  ) {
    const rawBody = req.rawBody ? req.rawBody.toString('utf8') : undefined;
    return this.userService.handleBinanceKycWebhook(payload, rawBody, signatureHeader);
  }
}
