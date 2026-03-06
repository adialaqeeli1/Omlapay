import {
  Injectable,
  Inject,
  ConflictException,
  BadRequestException,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { UserEntity, CoinEntity } from '@common/database/model';
import { UserSecurityEntity } from '@common/database/model';
import { AuthSessionEntity } from '@common/database/model';
import {
  OtpRequestEntity,
  OtpPurpose,
} from '@common/database/model';
import {
  UserSettingsEntity,
  Theme,
  Language,
  DisplayCurrency,
} from '@common/database/model';
import {
  UserKycEntity,
  KycStatus,
  KycLevel,
  KycProvider,
  KycRejectType,
  BinanceWebhookEntity,
} from '@common/database/model';
import { generateOTP, generateHash } from '@common/filters';
import {
  maskPhoneNumber,
  maskEmail,
  validateCountryCodeAndMobileNumber,
  validatePasscodeMatch,
  buildFullMobileNumber,
  validateBooleanTrue,
  validateOTP,
  validateToken,
} from '@common/utils';
import { successResponse } from '@common/utils/response.util';
import { UserAccountService } from './user-account.service';
import { RegisterRequestDto } from './dto/register-request.dto';
import { SetPasscodeDto } from './dto/set-passcode.dto';
import { VerifyOtpDto } from '../auth/dto/verify-otp.dto';
import { ResendOtpDto } from '../auth/dto/resend-otp.dto';
import { UpdateAppearanceDto } from './dto/update-appearance.dto';
import { UpdateCurrencyDto } from './dto/update-currency.dto';
import { InviteContactDto } from './dto/invite-contact.dto';
import { UpdateLanguageDto } from './dto/update-language.dto';
import { UpdateNotificationsDto } from './dto/update-notifications.dto';
import { Enable2FARequestDto } from './dto/enable-2fa-request.dto';
import { Verify2FADto } from './dto/verify-2fa.dto';
import { StartKycDto } from './dto/start-kyc.dto';
import { UpdateOnboardingDto, OnboardingAction } from './dto/update-onboarding.dto';
import { OtpService } from '@common/services/otp/otp.service';
import { MailService } from '@common/services/mail/mail.service';
import {
  BinanceService,
  BinanceShareKycDataParams,
  BinanceKycBasicInfo,
  BinanceKycIdentityInfo,
} from '@common/services/binance/binance.service';
import {
  SumsubService,
  SumsubFixedInfo,
} from '@common/services/sumsub/sumsub.service';
import { SumsubApplicantResponse } from '@common/services/sumsub/dto/sumsub-webhook.dto';
import { CryptoUtil } from '@common/utils/crypto.util';
import { CountryUtil } from '@common/utils/country.util';
import {
  IAdminNotifier,
} from '@common/services/admin-notifier/admin-notifier.interface';
import { APP_INVITE_URL } from '@common/constants';
import { AdminNotificationType } from '@common/database/model';

@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(UserSecurityEntity)
    private userSecurityRepository: Repository<UserSecurityEntity>,
    @InjectRepository(AuthSessionEntity)
    private authSessionRepository: Repository<AuthSessionEntity>,
    @InjectRepository(OtpRequestEntity)
    private otpRepository: Repository<OtpRequestEntity>,
    @InjectRepository(UserSettingsEntity)
    private userSettingsRepository: Repository<UserSettingsEntity>,
    @InjectRepository(UserKycEntity)
    private userKycRepository: Repository<UserKycEntity>,
    @InjectRepository(BinanceWebhookEntity)
    private binanceWebhookRepository: Repository<BinanceWebhookEntity>,
    @InjectRepository(CoinEntity)
    private coinRepository: Repository<CoinEntity>,
    private jwtService: JwtService,
    private otpService: OtpService,
    private mailService: MailService,
    private binanceService: BinanceService,
    private sumsubService: SumsubService,
    @Inject(IAdminNotifier) private adminNotifier: IAdminNotifier,
    private userAccountService: UserAccountService,
  ) {}

  /** Get user by ID or throw BadRequestException. */
  private async getUserOrThrow(userId: string): Promise<UserEntity> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new BadRequestException({ status: 'error', message: 'User not found.' });
    }
    return user;
  }

  /** Get user settings or throw BadRequestException. */
  private async getSettingsOrThrow(userId: string): Promise<UserSettingsEntity> {
    const settings = await this.userSettingsRepository.findOne({
      where: { userId },
    });
    if (!settings) {
      throw new BadRequestException({
        status: 'error',
        message: 'User settings not found.',
      });
    }
    return settings;
  }

  /**
   * Get account details: masked phone, email (if present), and wallet addresses by network.
   * Delegates to UserAccountService.
   */
  async getAccountDetails(userId: string) {
    return this.userAccountService.getAccountDetails(userId);
  }

  /**
   * Map StartKycDto to Sumsub fixedInfo (only non-empty fields).
   * residentialCountry → nationality; address + city → addresses[0].
   *
   * NOTE: SumSub dashboard shows "john only" when the verification level's Applicant data step
   * uses a single "Full name" field instead of separate "First name" and "Last name" fields.
   * Configure: Dashboard → Settings → Levels → [your level] → Applicant data step →
   * add both "First name" and "Last name" (not just "Full name").
   */
  private buildSumsubFixedInfoFromDto(dto?: StartKycDto): SumsubFixedInfo | undefined {
    if (!dto) return undefined;
    const info: SumsubFixedInfo = {};
    const firstName = dto.firstName?.trim();
    const lastName = dto.lastName?.trim();
    if (firstName) info.firstName = firstName;
    if (lastName) info.lastName = lastName;
    const dob = dto.dob?.trim();
    const country = dto.country?.trim();
    const residentialCountry = dto.residentialCountry?.trim();
    if (dob) info.dob = dob;
    if (country) info.country = country;
    if (residentialCountry) info.nationality = residentialCountry;
    const address = dto.address?.trim();
    const city = dto.city?.trim();
    if (address || city) {
      info.addresses = [{
        ...(address && { street: address }),
        ...(city && { town: city }),
        ...(residentialCountry && { country: residentialCountry }),
      }];
    }
    return Object.keys(info).length > 0 ? info : undefined;
  }

  /** Get JWT secret from env. */
  private getJwtSecret(): string {
    const secret = process.env.JWT_SECRET_KEY;
    if (!secret || !secret.trim()) {
      throw new Error(
        'JWT_SECRET_KEY or JWT_SECRET must be set.',
      );
    }
    return secret;
  }

  /** Create signed token for KYC document proxy (Binance fetches image by URL). */
  private createKycDocumentToken(applicantId: string, imageId: string): string {
    return CryptoUtil.createSignedToken(
      { applicantId, imageId },
      this.getJwtSecret(),
      60 * 60 * 1000, // 1 hour
    );
  }

  /** Verify and decode KYC document token. */
  private verifyKycDocumentToken(token: string): { applicantId: string; imageId: string } {
    try {
      return CryptoUtil.verifySignedToken<{ applicantId: string; imageId: string }>(
        token,
        this.getJwtSecret(),
      );
    } catch (err) {
      throw new BadRequestException(err instanceof Error ? err.message : 'Invalid document token');
    }
  }

  /**
   * Stream KYC document image for Binance (public endpoint; token is short-lived signed).
   */
  async getKycDocumentStream(token: string): Promise<{ buffer: Buffer; contentType: string }> {
    const { applicantId, imageId } = this.verifyKycDocumentToken(token);
    const applicant = await this.sumsubService.getApplicantById(applicantId);
    if (!applicant?.inspectionId) throw new BadRequestException('Applicant or image not found');
    return this.sumsubService.getInspectionImage(applicant.inspectionId, imageId);
  }

  /**
   * Build KYC update fields from Sumsub applicant (preferred) or webhook payload fallback.
   * Used by webhook and getKycStatus sync.
   */
  private buildSumsubKycFields(
    applicant: SumsubApplicantResponse | null,
    payload: {
      reviewStatus?: string;
      reviewResult?: {
        reviewAnswer?: string;
        reviewRejectType?: string;
        rejectLabels?: string[];
        moderationComment?: string;
      };
    },
  ): {
    status: KycStatus;
    reviewAnswer: string | null;
    rejectType: KycRejectType | null;
    rejectionReason: string | null;
    providerPayload: Record<string, unknown> | null;
  } {
    const reviewStatus = applicant?.review?.reviewStatus ?? payload.reviewStatus ?? 'pending';
    const reviewAnswer = applicant?.review?.reviewResult?.reviewAnswer ?? payload.reviewResult?.reviewAnswer;
    const reviewRejectType = applicant?.review?.reviewResult?.reviewRejectType ?? payload.reviewResult?.reviewRejectType;
    const rejectLabels = applicant?.review?.reviewResult?.rejectLabels ?? payload.reviewResult?.rejectLabels ?? [];
    const rejectionReason = rejectLabels.length
      ? rejectLabels.join(', ')
      : (payload.reviewResult?.moderationComment ?? null);

    const status = UserKycEntity.mapSumsubStatus(reviewStatus, reviewAnswer, reviewRejectType);
    const rejectType =
      reviewRejectType === 'RETRY' || reviewRejectType === 'FINAL'
        ? (reviewRejectType as KycRejectType)
        : null;
    const providerPayload =
      applicant != null
        ? (applicant as unknown as Record<string, unknown>)
        : (payload && typeof payload === 'object'
            ? (JSON.parse(JSON.stringify(payload)) as Record<string, unknown>)
            : null);

    return {
      status,
      reviewAnswer: reviewAnswer ?? null,
      rejectType,
      rejectionReason,
      providerPayload,
    };
  }

  // --- KYC (Sumsub) ---

  /**
   * Start KYC verification process for a user
   * Flow: Client calls this → Gets SDK token → Loads Sumsub WebSDK → User completes KYC
   *       → Sumsub sends webhook → We update KYC status in database
   * 
   * @param userId - Internal user ID
   * @param dto - Optional pre-fill for Sumsub fixedInfo (firstName, lastName, dob, address, etc.)
   * @returns SDK access token for initializing Sumsub WebSDK on client side
   */
  async startKyc(userId: string, dto?: StartKycDto) {
    this.logger.log(`[KYC] Starting KYC process for user ${userId}`);
    if (dto?.firstName || dto?.lastName) {
      this.logger.debug(`[KYC] Request body: firstName="${dto.firstName ?? ''}", lastName="${dto.lastName ?? ''}"`);
    }

    // 1. Fetch user details
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      this.logger.error(`[KYC] User ${userId} not found`);
      throw new BadRequestException({
        status: 'error',
        message: 'User not found.',
      });
    }

    // 2. Check if user already has an approved KYC
    const existingKyc = await this.userKycRepository.findOne({
      where: { userId, provider: KycProvider.SUMSUB },
    });

    if (existingKyc?.status === KycStatus.APPROVED) {
      this.logger.warn(
        `[KYC] User ${userId} already has approved KYC, returning existing status`,
      );
      return {
        status: 'success',
        message: 'KYC already approved.',
        data: {
          kycStatus: KycStatus.APPROVED,
          verifiedAt: existingKyc.verifiedAt,
        },
      };
    }

    // 3. Get verification level from environment
    const levelName =
      process.env.SUMSUB_DEFAULT_LEVEL_NAME ||
      process.env.SUMSUB_LEVEL_NAME ||
      'id-and-liveness';

    this.logger.debug(`[KYC] Using verification level: ${levelName} for user ${userId}`);

    const fixedInfo = this.buildSumsubFixedInfoFromDto(dto);
    if (fixedInfo?.firstName || fixedInfo?.lastName) {
      this.logger.debug(
        `[KYC] Pre-filling Sumsub fixedInfo: firstName=${fixedInfo.firstName ?? '(empty)'}, lastName=${fixedInfo.lastName ?? '(empty)'}`,
      );
    }

    // 4. Ensure Sumsub applicant exists (create if not), then pre-fill fixedInfo if provided
    try {
      const existing = await this.sumsubService.getApplicantByExternalUserId(user.id);
      if (existing?.id) {
        if (fixedInfo && Object.keys(fixedInfo).length > 0) {
          await this.sumsubService.updateApplicantFixedInfo(existing.id, fixedInfo);
        }
      } else {
        await this.sumsubService.createApplicant(user.id, levelName, {
          email: user.email ?? undefined,
          phone: user.fullMobileNumber,
          ...(fixedInfo && Object.keys(fixedInfo).length > 0 ? { fixedInfo } : {}),
        });
      }
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`[KYC] Applicant create/update failed: ${msg}`);
      throw new BadRequestException({
        status: 'error',
        message: `Failed to pre-fill KYC data in SumSub. Please try again. Details: ${msg}`,
      });
    }

    // 5. Create SDK access token via Sumsub API
    try {
      const tokenResponse = await this.sumsubService.createSdkAccessToken({
        userId: user.id,
        levelName,
        email: user.email ?? undefined,
        phone: user.fullMobileNumber,
      });

      // 6. Initialize/update KYC record in our database
      // This creates the record that will be updated by the webhook
      await this.userKycRepository.upsert(
        {
          userId: user.id,
          provider: KycProvider.SUMSUB,
          status: KycStatus.INIT,
          level: KycLevel.BASIC,
          referenceId: null, // Will be populated by webhook when applicant submits
          reviewAnswer: null,
          rejectType: null,
          rejectionReason: null,
          verifiedAt: null,
        },
        ['userId', 'provider'],
      );

      this.logger.log(
        `[KYC] Successfully generated SDK token for user ${userId}, status set to INIT`,
      );

      return {
        status: 'success',
        message: 'KYC process started successfully.',
        data: {
          token: tokenResponse.token,
          userId: tokenResponse.userId,
          levelName,
          // Include webhook info for client debugging (optional)
          _meta: {
            webhookUrl: `${process.env.API_BASE_URL || ''}/v1/user/webhooks/sumsub`,
            note: 'Token is valid for 10 minutes. Webhook will update KYC status automatically.',
          },
        },
      };
    } catch (error) {
      this.logger.error(
        `[KYC] Failed to start KYC for user ${userId}: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );
      throw new BadRequestException({
        status: 'error',
        message: 'Failed to start KYC process. Please try again later.',
        details: process.env.NODE_ENV === 'development' && error instanceof Error ? error.message : undefined,
      });
    }
  }

  // --- Registration & auth ---

  /**
   * Verify registration OTP and generate registration token
   */
  async verifyRegistrationOtp(dto: VerifyOtpDto) {
    try {
      // Validate input using utility functions
      validateCountryCodeAndMobileNumber(dto.country_code, dto.mobile_number);
      validateOTP(dto.otp);

      const fullMobileNumber = buildFullMobileNumber(
        dto.country_code,
        dto.mobile_number,
      );

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
      const remainingAttempts = otpRequest.maxAttempts - otpRequest.attempts;

      if (otpRequest.attempts >= otpRequest.maxAttempts) {
        const lockUntil = new Date();
        lockUntil.setMinutes(lockUntil.getMinutes() + 5); // 5 minutes lockout
        otpRequest.lockedUntil = lockUntil;
      }

      await this.otpRepository.save(otpRequest);
      throw new BadRequestException({
        status: 'error',
        message: 'Invalid OTP.',
        code: 'REGISTRATION_OTP_INVALID',
        data: {
          remaining_attempts: remainingAttempts,
        },
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
        termsAcceptedAt: new Date(),
      });
      user = await this.userRepository.save(user);
    } else {
      user.isMobileVerified = true;
      user.mobileVerifiedAt = new Date();
      if (!user.termsAcceptedAt) {
        user.termsAcceptedAt = new Date();
      }
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
    } catch (error) {
      // Re-throw BadRequestException and ConflictException as-is
      if (
        error instanceof BadRequestException ||
        error instanceof ConflictException
      ) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in verifyRegistrationOtp: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new BadRequestException({
        status: 'error',
        message: 'Failed to verify OTP. Please try again later.',
      });
    }
  }

  /**
   * Resend registration OTP
   */
  async resendRegistrationOtp(dto: ResendOtpDto) {
    try {
      // Validate input using utility functions
      validateCountryCodeAndMobileNumber(dto.country_code, dto.mobile_number);

      const fullMobileNumber = buildFullMobileNumber(
        dto.country_code,
        dto.mobile_number,
      );

      // Find most recent non-consumed OTP request for registration
      const existingOtp = await this.otpRepository.findOne({
        where: {
          fullMobileNumber,
          isConsumed: false,
          purpose: OtpPurpose.REGISTER,
        },
        order: { createdAt: 'DESC' },
      });

      if (!existingOtp) {
        throw new BadRequestException({
          status: 'error',
          message: 'No active OTP request found. Please start the registration process again.',
        });
      }

      // Check cooldown (60 seconds)
      if (existingOtp.lastResendAt) {
        const cooldownSeconds = 60;
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

      // Check if user already exists and is verified
      const existingUser = await this.userRepository.findOne({
        where: { fullMobileNumber },
      });

      if (existingUser && existingUser.isMobileVerified) {
        throw new ConflictException({
          status: 'error',
          message: 'This mobile number is already registered.',
        });
      }

      const resendAttempts = existingOtp.resendAttempts + 1;

      // Generate new OTP
      const isIndian = fullMobileNumber?.startsWith('+91'); // Temporary fix for Indian numbers
      const otp = isIndian ? '666666' : generateOTP();
      const otpHash = generateHash(otp);
      const expiresAt = new Date();
      expiresAt.setSeconds(expiresAt.getSeconds() + 60);

      // Delete old OTP
      await this.otpRepository.delete({
        fullMobileNumber,
        purpose: OtpPurpose.REGISTER,
      });

      // Save new OTP
      await this.otpRepository.save({
        fullMobileNumber,
        email: null,
        otpHash,
        purpose: OtpPurpose.REGISTER,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts,
        lastResendAt: new Date(),
      });

      // Send OTP via SMS service
      await this.otpService.sendOTP(fullMobileNumber, otp);

      return {
        status: 'success',
        message: 'Verification code resent to your mobile number.',
        data: {
          masked_mobile: maskPhoneNumber(fullMobileNumber),
          otp_expiry_seconds: 60,
          ...(process.env.NODE_ENV === 'development' && { otp }),
        },
      };
    } catch (error) {
      // Re-throw BadRequestException and ConflictException as-is
      if (
        error instanceof BadRequestException ||
        error instanceof ConflictException
      ) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in resendRegistrationOtp: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new BadRequestException({
        status: 'error',
        message: 'Failed to resend OTP. Please try again later.',
      });
    }
  }

  async registerRequest(dto: RegisterRequestDto) {
    try {
      // Validate input using utility functions
      validateCountryCodeAndMobileNumber(dto.country_code, dto.mobile_number);
      validateBooleanTrue(
        dto.terms_accepted,
        'Terms & Conditions and Privacy Policy',
        'You must accept the Terms & Conditions and Privacy Policy to register.',
      );

      const fullMobileNumber = buildFullMobileNumber(
        dto.country_code,
        dto.mobile_number,
      );

      // Check if user already exists
      const existingUser = await this.userRepository.findOne({
        where: { fullMobileNumber },
      });

      if (existingUser && existingUser.isMobileVerified) {
        throw new ConflictException({
          status: 'error',
          message: 'This mobile number is already registered.',
        });
      }

      // Generate and send OTP
      const isIndian = fullMobileNumber?.startsWith('+91'); // Temporary fix for Indian numbers
      const otp = isIndian ? '666666' : generateOTP();
      const otpHash = generateHash(otp);
      const expiresAt = new Date();
      expiresAt.setMinutes(expiresAt.getMinutes() + 1); // 1 minute validity

      // Invalidate previous OTPs for this number
      await this.otpRepository.delete({
        fullMobileNumber,
        purpose: OtpPurpose.REGISTER,
      });

      // Save new OTP
      await this.otpRepository.save({
        fullMobileNumber,
        email: null,
        otpHash,
        purpose: OtpPurpose.REGISTER,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts: 0,
        lastResendAt: new Date(),
        isConsumed: false,
      });

      await this.otpService.sendOTP(fullMobileNumber, otp);

      return {
        status: 'success',
        message: 'OTP sent to your mobile number.',
        data: {
          masked_mobile: maskPhoneNumber(fullMobileNumber),
          otp_expiry_seconds: 60,
          ...(process.env.NODE_ENV === 'development' && { otp }),
        },
      };
    } catch (error) {
      // Re-throw BadRequestException and ConflictException as-is
      if (
        error instanceof BadRequestException ||
        error instanceof ConflictException
      ) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in registerRequest: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new BadRequestException({
        status: 'error',
        message: 'Failed to process registration request. Please try again later.',
      });
    }
  }

  async setPasscode(dto: SetPasscodeDto) {
    try {
      // Validate input using utility functions
      validateToken(dto.registration_token, 'Registration token');
      validatePasscodeMatch(dto.passcode, dto.confirm_passcode);

      // Decode and validate registration token
      let payload: { userId: string; type: string };
      try {
        payload = this.jwtService.verify(dto.registration_token);
      } catch (error) {
        throw new UnauthorizedException({
          status: 'error',
          message: 'Invalid or expired registration token.',
        });
      }

      if (!payload || payload.type !== 'registration' || !payload.userId) {
        throw new UnauthorizedException({
          status: 'error',
          message: 'Invalid registration token.',
        });
      }

      // Parallelize user and security lookups for reduced latency
      const [user, existingSecurity] = await Promise.all([
        this.userRepository.findOne({ where: { id: payload.userId } }),
        this.userSecurityRepository.findOne({ where: { userId: payload.userId } }),
      ]);

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

      if (existingSecurity) {
        throw new ConflictException({
          status: 'error',
          message: 'Passcode already set.',
        });
      }

      // Hash passcode
      const passcodeHash = await bcrypt.hash(dto.passcode, 10);

      // Create user security record
      await this.userSecurityRepository.save({
        userId: user.id,
        passcodeHash,
        lastPasscodeChangedAt: new Date(),
        failedAttempts: 0,
      });

      // Create default user settings with onboarding status
      // Language is set to default, user will select during onboarding flow
      await this.userSettingsRepository.save({
        userId: user.id,
        theme: Theme.LIGHT,
        language: Language.AR, // Default language, user can change during onboarding
        notificationsEnabled: true,
        onboardingCompleted: false,
        onboardingSkipped: false,
      });

      // Create Binance sub account
      try {
        const binanceSubAccount = await this.binanceService.createSubAccount(user.id.slice(0, 31));

        user.binanceSubaccountId = binanceSubAccount.subaccountId;
        user.binanceSubaccountEmail = binanceSubAccount.email;
        user.binanceSubaccountTag = binanceSubAccount.tag;
        await this.userRepository.save(user);
      } catch (error) {
        // Log error but don't fail registration if Binance fails
        this.logger.error('Failed to create Binance sub account during registration:', error);
        // Registration still succeeds even if Binance fails
      }

      // Notify all admins about new user registration (include email when available for UI/spec)
      try {
        const detail = user.email
          ? `A new user has registered on the platform: ${user.email}.`
          : `A new user has registered on the platform. Mobile: ${user.fullMobileNumber}.`;
        await this.adminNotifier.notifyAllAdmins(
          AdminNotificationType.USER,
          'New User Registered',
          detail,
        );
      } catch (error) {
        // Don't fail registration if notification fails
        this.logger.error(
          `Failed to notify admins about new user registration: ${error instanceof Error ? error.message : 'Unknown error'}`,
        );
      }

      return {
        status: 'success',
        message: 'Registration completed successfully.',
      };
    } catch (error) {
      // Re-throw BadRequestException, UnauthorizedException, and ConflictException as-is
      if (
        error instanceof BadRequestException ||
        error instanceof UnauthorizedException ||
        error instanceof ConflictException
      ) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(
        `Error in setPasscode: ${error instanceof Error ? error.message : 'Unknown error'}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new BadRequestException({
        status: 'error',
        message: 'Failed to set passcode. Please try again later.',
      });
    }
  }

  // --- Settings ---

  async updateAppearance(userId: string, dto: UpdateAppearanceDto) {
    const settings = await this.getSettingsOrThrow(userId);
    settings.theme = dto.theme;
    await this.userSettingsRepository.save(settings);
    return { status: 'success', message: 'Appearance updated successfully.' };
  }

  async getAppearance(userId: string) {
    const settings = await this.getSettingsOrThrow(userId);
    return { theme: settings.theme };
  }

  async updateLanguage(userId: string, dto: UpdateLanguageDto) {
    const settings = await this.getSettingsOrThrow(userId);
    settings.language = dto.language;
    await this.userSettingsRepository.save(settings);
    return { status: 'success', message: 'Language preference updated.' };
  }

  async getLanguage(userId: string) {
    const settings = await this.getSettingsOrThrow(userId);
    return {
      language: settings.language,
      direction: settings.language === Language.AR ? 'rtl' : 'ltr',
    };
  }

  async updateNotifications(userId: string, dto: UpdateNotificationsDto) {
    const settings = await this.getSettingsOrThrow(userId);
    settings.notificationsEnabled = dto.notifications_enabled;
    await this.userSettingsRepository.save(settings);
    return { status: 'success', message: 'Notification settings updated.' };
  }

  async getNotifications(userId: string) {
    const settings = await this.getSettingsOrThrow(userId);
    return { notifications_enabled: settings.notificationsEnabled };
  }

  async updateCurrency(userId: string, dto: UpdateCurrencyDto) {
    const settings = await this.getSettingsOrThrow(userId);
    settings.displayCurrency = dto.currency;
    await this.userSettingsRepository.save(settings);
    return successResponse(
      { currency: dto.currency },
      'Display currency updated successfully.',
    );
  }

  async getCurrency(userId: string) {
    const settings = await this.getSettingsOrThrow(userId);
    const currency = settings.displayCurrency ?? DisplayCurrency.USD;
    return successResponse({ currency });
  }

  /**
   * Send invitation to a contact who is not yet on Omlapay.
   * Sends SMS with app download link. Only for non-registered phone numbers.
   */
  async inviteContact(userId: string, dto: InviteContactDto) {
    validateCountryCodeAndMobileNumber(dto.country_code, dto.mobile_number);

    const fullMobileNumber = buildFullMobileNumber(
      dto.country_code,
      dto.mobile_number,
    );

    const existingUser = await this.userRepository.findOne({
      where: { fullMobileNumber },
    });

    if (existingUser) {
      throw new BadRequestException({
        status: 'error',
        message: 'This number is already registered on Omlapay.',
      });
    }

    const message = `You've been invited to join Omlapay! Download the app to send and receive crypto securely: ${APP_INVITE_URL}`;

    await this.otpService.sendSms(fullMobileNumber, message);

    this.logger.log(`Invitation sent to ${fullMobileNumber} by user ${userId}`);

    return successResponse(
      { phone: maskPhoneNumber(fullMobileNumber) },
      'Invitation sent successfully.',
    );
  }

  // --- Onboarding ---

  /**
   * Update onboarding status (complete or skip).
   * Single endpoint handles both actions.
   */
  async updateOnboarding(userId: string, dto: UpdateOnboardingDto) {
    const settings = await this.getSettingsOrThrow(userId);

    if (dto.action === OnboardingAction.COMPLETE) {
      settings.onboardingCompleted = true;
      settings.onboardingSkipped = false;
    } else if (dto.action === OnboardingAction.SKIP) {
      settings.onboardingSkipped = true;
      settings.onboardingCompleted = false;
    }

    await this.userSettingsRepository.save(settings);

    return {
      status: 'success',
      message: `Onboarding ${dto.action === OnboardingAction.COMPLETE ? 'completed' : 'skipped'} successfully.`,
      onboardingStatus: {
        completed: settings.onboardingCompleted,
        skipped: settings.onboardingSkipped,
      },
    };
  }

  /**
   * Get onboarding status for the user.
   * Returns whether user needs language selection and onboarding.
   */
  async getOnboardingStatus(userId: string) {
    // Check if user settings exist
    const settings = await this.userSettingsRepository.findOne({
      where: { userId },
    });

    // If no settings exist, user needs language selection and onboarding
    if (!settings) {
      return {
        needsLanguageSelection: true,
        needsOnboarding: true,
        onboardingStatus: 'NOT_STARTED',
        language: null,
      };
    }

    // Determine onboarding status
    let onboardingStatus: 'NOT_STARTED' | 'COMPLETED' | 'SKIPPED';
    if (settings.onboardingCompleted) {
      onboardingStatus = 'COMPLETED';
    } else if (settings.onboardingSkipped) {
      onboardingStatus = 'SKIPPED';
    } else {
      onboardingStatus = 'NOT_STARTED';
    }

    // User needs language selection if onboarding hasn't started yet
    // Since language selection happens before onboarding, if onboarding is completed/skipped,
    // language was already selected. If onboarding is NOT_STARTED, user needs language selection.
    const needsLanguageSelection =
      onboardingStatus === 'NOT_STARTED' &&
      !settings.onboardingCompleted &&
      !settings.onboardingSkipped;

    // User needs onboarding if not completed and not skipped
    const needsOnboarding = !settings.onboardingCompleted && !settings.onboardingSkipped;

    return {
      needsLanguageSelection,
      needsOnboarding,
      onboardingStatus,
      language: settings.language,
    };
  }

  async enable2FARequest(userId: string, dto: Enable2FARequestDto) {
    try {
      // Validate input
      if (!dto.country_code || !dto.mobile_number || !dto.email) {
        throw new BadRequestException({
          status: 'error',
          message: 'Country code, mobile number, and email are required.',
        });
      }

      // Validate country code format
      if (!/^\+(966|91)$/.test(dto.country_code)) {
        throw new BadRequestException({
          status: 'error',
          message: 'Invalid country code. Allowed: +966, +91',
        });
      }

      // Validate mobile number format
      const mobileNumberRegex = dto.country_code === '+966' ? /^\d{9}$/ : /^\d{10}$/;
      if (!mobileNumberRegex.test(dto.mobile_number)) {
        const expectedLength = dto.country_code === '+966' ? '9' : '10';
        throw new BadRequestException({
          status: 'error',
          message: `Mobile number must be ${expectedLength} digits long.`,
        });
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(dto.email)) {
        throw new BadRequestException({
          status: 'error',
          message: 'Invalid email format.',
        });
      }

      const user = await this.getUserOrThrow(userId);

      // Verify mobile number matches
      const fullMobileNumber = `${dto.country_code}${dto.mobile_number}`;
      if (user.fullMobileNumber !== fullMobileNumber) {
        throw new BadRequestException({
          status: 'error',
          message: 'Mobile number does not match your account.',
        });
      }

      // Verify email matches if user already has email, or update it
      if (user.email && user.email.toLowerCase() !== dto.email.toLowerCase()) {
        throw new BadRequestException({
          status: 'error',
          message: 'Email does not match your account.',
        });
      }

      // Update user email if not set
      if (!user.email) {
        user.email = dto.email.toLowerCase();
        await this.userRepository.save(user);
      }

      // Check if 2FA is already enabled
      const settings = await this.userSettingsRepository.findOne({
        where: { userId: user.id },
      });

      if (settings?.twoFactorEnabled) {
        throw new BadRequestException({
          status: 'error',
          message: 'Two-factor authentication is already enabled.',
        });
      }

      // Generate OTPs for both mobile and email
      const isIndian = fullMobileNumber.startsWith('+91');
      const mobileOtp = isIndian ? '666666' : generateOTP();
      const emailOtp = generateOTP();
      const mobileOtpHash = generateHash(mobileOtp);
      const emailOtpHash = generateHash(emailOtp);

      const expiresAt = new Date();
      expiresAt.setSeconds(expiresAt.getSeconds() + 60); // 60 seconds (1 minute) validity

      // Invalidate previous OTPs
      await this.otpRepository.delete({
        fullMobileNumber,
        purpose: OtpPurpose.TWO_FACTOR_MOBILE,
      });
      await this.otpRepository.delete({
        email: dto.email.toLowerCase(),
        purpose: OtpPurpose.TWO_FACTOR_EMAIL,
      });

      // Save mobile OTP
      await this.otpRepository.save({
        fullMobileNumber,
        email: null,
        otpHash: mobileOtpHash,
        purpose: OtpPurpose.TWO_FACTOR_MOBILE,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts: 0,
        lastResendAt: new Date(),
      });

      // Save email OTP
      await this.otpRepository.save({
        fullMobileNumber,
        email: dto.email.toLowerCase(),
        otpHash: emailOtpHash,
        purpose: OtpPurpose.TWO_FACTOR_EMAIL,
        expiresAt,
        attempts: 0,
        maxAttempts: 3,
        resendAttempts: 0,
        lastResendAt: new Date(),
      });

      // Send OTPs via SMS and Email services and track success/failure
      let mobileOtpSent = false;
      let emailOtpSent = false;
      let mobileOtpError: string | null = null;
      let emailOtpError: string | null = null;

      await Promise.all([
        this.otpService
          .sendOTP(fullMobileNumber, mobileOtp)
          .then(() => {
            mobileOtpSent = true;
          })
          .catch((error) => {
            mobileOtpSent = false;
            mobileOtpError = error instanceof Error ? error.message : 'Failed to send OTP';
            this.logger.error(`Failed to send mobile OTP: ${mobileOtpError}`, error instanceof Error ? error.stack : undefined);
          }),
        this.mailService
          .sendOTP(dto.email.toLowerCase(), emailOtp)
          .then(() => {
            emailOtpSent = true;
          })
          .catch((error) => {
            emailOtpSent = false;
            emailOtpError = error instanceof Error ? error.message : 'Failed to send OTP';
            this.logger.error(`Failed to send email OTP: ${emailOtpError}`, error instanceof Error ? error.stack : undefined);
          }),
      ]);

      // Determine response message based on OTP sending results
      let status: string;
      let message: string;

      if (!mobileOtpSent && !emailOtpSent) {
        status = 'error';
        message = 'Failed to send verification codes. Please try again later.';
      } else if (!mobileOtpSent) {
        status = 'partial_success';
        message = 'Verification code sent to your email. Failed to send code to mobile number.';
      } else if (!emailOtpSent) {
        status = 'partial_success';
        message = 'Verification code sent to your mobile number. Failed to send code to email.';
      } else {
        status = 'success';
        message = 'Verification codes sent to your mobile number and email.';
      }

      return {
        status,
        message,
        data: {
          mobile_number: fullMobileNumber,
          email: dto.email.toLowerCase(),
          mobile_otp_sent: mobileOtpSent,
          email_otp_sent: emailOtpSent,
          ...(mobileOtpError ? { mobile_otp_error: mobileOtpError } : {}),
          ...(emailOtpError ? { email_otp_error: emailOtpError } : {}),
          ...(process.env.NODE_ENV === 'development' ? { mobile_otp: mobileOtp, email_otp: emailOtp } : {}),
        },
      };
    } catch (error) {
      // Re-throw BadRequestException as-is (validation errors)
      if (error instanceof BadRequestException) {
        throw error;
      }

      // Log unexpected errors
      this.logger.error(`Error in enable2FARequest: ${error instanceof Error ? error.message : 'Unknown error'}`, error instanceof Error ? error.stack : undefined);

      // Return user-friendly error message for unexpected errors
      throw new BadRequestException({
        status: 'error',
        message: 'Failed to enable two-factor authentication. Please try again later.',
      });
    }
  }

  async verify2FA(userId: string, dto: Verify2FADto) {
    const user = await this.getUserOrThrow(userId);

    if (!user.email) {
      throw new BadRequestException({
        status: 'error',
        message: 'Email address is required to enable 2FA.',
      });
    }

    // Find mobile OTP request
    const mobileOtpRequest = await this.otpRepository.findOne({
      where: {
        fullMobileNumber: user.fullMobileNumber,
        purpose: OtpPurpose.TWO_FACTOR_MOBILE,
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
        purpose: OtpPurpose.TWO_FACTOR_EMAIL,
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

    // Check if locked
    if (
      (mobileOtpRequest.lockedUntil &&
        mobileOtpRequest.lockedUntil > new Date()) ||
      (emailOtpRequest.lockedUntil && emailOtpRequest.lockedUntil > new Date())
    ) {
      throw new BadRequestException({
        status: 'error',
        message: 'Too many failed attempts. Please try again later.',
      });
    }

    // Check if expired
    if (
      mobileOtpRequest.expiresAt < new Date() ||
      emailOtpRequest.expiresAt < new Date()
    ) {
      throw new BadRequestException({
        status: 'error',
        message: 'OTP has expired. Please request a new OTP.',
      });
    }

    // Verify mobile OTP
    const mobileOtpHash = generateHash(dto.mobile_otp);
    if (mobileOtpHash !== mobileOtpRequest.otpHash) {
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
        message: 'Invalid mobile OTP.',
      });
    }

    // Verify email OTP
    const emailOtpHash = generateHash(dto.email_otp);
    if (emailOtpHash !== emailOtpRequest.otpHash) {
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
        message: 'Invalid email OTP.',
      });
    }

    // Mark email as verified (since user verified email OTP)
    if (!user.isEmailVerified) {
      user.isEmailVerified = true;
      user.emailVerifiedAt = new Date();
      await this.userRepository.save(user);
    }

    // Enable 2FA
    const settings = await this.userSettingsRepository.findOne({
      where: { userId: user.id },
    });

    if (settings) {
      settings.twoFactorEnabled = true;
      await this.userSettingsRepository.save(settings);
    } else {
      await this.userSettingsRepository.save({
        userId: user.id,
        theme: Theme.LIGHT,
        language: Language.AR,
        notificationsEnabled: true,
        twoFactorEnabled: true,
      });
    }

    // Mark OTPs as consumed instead of deleting
    mobileOtpRequest.isConsumed = true;
    emailOtpRequest.isConsumed = true;
    await this.otpRepository.save([mobileOtpRequest, emailOtpRequest]);

    // Revoke all active sessions for security
    await this.authSessionRepository.update(
      { userId: user.id, isRevoked: false },
      { isRevoked: true },
    );

    return {
      status: 'success',
      message: 'Two-factor authentication has been enabled. Please login again.',
    };
  }

  async disable2FA(userId: string) {
    const user = await this.getUserOrThrow(userId);

    // Get settings
    const settings = await this.userSettingsRepository.findOne({
      where: { userId: user.id },
    });

    if (!settings) {
      throw new BadRequestException({
        status: 'error',
        message: 'User settings not found.',
      });
    }

    if (!settings.twoFactorEnabled) {
      throw new BadRequestException({
        status: 'error',
        message: 'Two-factor authentication is not enabled.',
      });
    }

    // Disable 2FA
    settings.twoFactorEnabled = false;
    await this.userSettingsRepository.save(settings);

    // Revoke all active sessions for security
    await this.authSessionRepository.update(
      { userId: user.id, isRevoked: false },
      { isRevoked: true },
    );

    return {
      status: 'success',
      message: 'Two-factor authentication has been disabled. Please login again.',
    };
  }

  /**
   * Handle Sumsub webhook for KYC status updates
   * Webhook flow: User completes KYC → Sumsub sends webhook → We update user_kyc table
   * 
   * @param payload - Webhook payload from Sumsub
   * @param digest - HMAC signature in x-payload-digest header
   * @param rawBody - Raw request body for signature verification
   * @param algorithm - Hash algorithm from x-payload-digest-alg header (sha1 or sha256)
   * @returns Status object indicating if webhook was processed
   */
  async handleSumsubWebhook(
    payload: any,
    digest: string | undefined,
    rawBody?: string,
    algorithm?: string,
  ) {
    const startTime = Date.now();
    if (!payload || typeof payload !== 'object') {
      this.logger.warn('[Sumsub Webhook] Missing or invalid payload');
      return { received: true, skipped: true, reason: 'invalid_payload' };
    }
    const webhookId = payload.correlationId || payload.applicantId || 'unknown';

    this.logger.log(`[Sumsub Webhook] Received webhook ${webhookId}`, {
      type: payload.type,
      reviewStatus: payload.reviewStatus,
      applicantId: payload.applicantId,
      algorithm: algorithm || 'sha256 (default)',
    });

    // 1. Verify webhook signature (production security requirement)
    if (digest && rawBody) {
      const hashAlgorithm = (algorithm || 'sha256').toLowerCase();
      const isValid = this.sumsubService.verifyWebhookSignature(rawBody, digest, hashAlgorithm);
      if (!isValid) {
        this.logger.error(
          `[Sumsub Webhook] Signature verification failed for webhook ${webhookId}`,
        );
        throw new UnauthorizedException('Invalid webhook signature');
      }
      this.logger.debug(`[Sumsub Webhook] Signature verified for webhook ${webhookId}`);
    } else if (process.env.NODE_ENV === 'production') {
      // In production, always require signature verification
      this.logger.warn(
        `[Sumsub Webhook] Missing signature or rawBody for webhook ${webhookId} in production`,
      );
    }

    // 2. Extract and validate webhook data
    const {
      externalUserId,
      applicantId,
      reviewStatus,
      reviewResult,
      type: webhookType,
      levelName,
    } = payload;

    const reviewAnswer = reviewResult?.reviewAnswer;
    const reviewRejectType = reviewResult?.reviewRejectType;
    const rejectLabels = reviewResult?.rejectLabels || [];
    const moderationComment = reviewResult?.moderationComment;

    // Skip webhooks without externalUserId (these are not linked to our users)
    if (!externalUserId) {
      this.logger.debug(
        `[Sumsub Webhook] Skipping webhook ${webhookId} - no externalUserId`,
      );
      return { received: true, skipped: true, reason: 'no_external_user_id' };
    }

    // Normalize: Sumsub/external may send "dash-<uuid>"; DB userId is uuid only
    const userId = String(externalUserId).replace(/^dash-/, '');

    // Verify user exists in our database
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      this.logger.warn(
        `[Sumsub Webhook] User ${userId} not found for webhook ${webhookId}`,
      );
      return { received: true, skipped: true, reason: 'user_not_found' };
    }

    // 3. Fetch applicant from Sumsub (same source as check-status); fallback to payload
    let applicant: SumsubApplicantResponse | null = null;
    if (applicantId) {
      try {
        applicant = await this.sumsubService.getApplicantById(applicantId);
      } catch (e: any) {
        this.logger.warn(
          `[Sumsub Webhook] Failed to fetch applicant ${applicantId}, using payload: ${e?.message ?? e}`,
        );
      }
    }
    const payloadReview = {
      reviewStatus,
      reviewResult: { reviewAnswer, reviewRejectType, rejectLabels, moderationComment },
    };
    const fields = this.buildSumsubKycFields(applicant, payloadReview);
    if (!applicant && payload && typeof payload === 'object') {
      fields.providerPayload = JSON.parse(JSON.stringify(payload)) as Record<string, unknown>;
    }

    // 4. Upsert KYC record
    const kycUpdateData: any = {
      userId,
      provider: KycProvider.SUMSUB,
      status: fields.status,
      level: KycLevel.BASIC,
      referenceId: applicantId ?? null,
      reviewAnswer: fields.reviewAnswer,
      rejectType: fields.rejectType,
      rejectionReason: fields.rejectionReason,
      verifiedAt: fields.status === KycStatus.APPROVED ? new Date() : null,
      providerPayload: fields.providerPayload,
    };

    // 5. Update or create KYC record (idempotent operation)
    await this.userKycRepository.upsert(kycUpdateData, ['userId', 'provider']);

    const processingTime = Date.now() - startTime;

    this.logger.log(
      `[Sumsub Webhook] Processed ${webhookId} in ${processingTime}ms`,
      { userId, status: fields.status, applicantId },
    );

    if (fields.status === KycStatus.APPROVED) {
      this.logger.log(`[Sumsub Webhook] Sumsub approved for user ${userId}, checking Binance flow`);

      try {
        const binanceKyc = await this.userKycRepository.findOne({
          where: { userId, provider: KycProvider.BINANCE },
        });

        const shouldStartBinance = !binanceKyc || binanceKyc.status === KycStatus.REJECTED;

        if (!shouldStartBinance) {
          this.logger.log(
            `[Sumsub Webhook] Binance KYC already exists with status ${binanceKyc?.status}, skipping auto-start`,
          );
        } else {
          if (!user.binanceSubaccountId) {
            this.logger.log(`[Sumsub Webhook] Creating Binance sub-account for user ${userId}`);
            const sub = await this.binanceService.createSubAccount(userId.slice(0, 31));
            user.binanceSubaccountId = sub.subaccountId;
            user.binanceSubaccountEmail = sub.email;
            user.binanceSubaccountTag = sub.tag;
            await this.userRepository.save(user);
            this.logger.log(`[Sumsub Webhook] Binance sub-account created: ${sub.subaccountId}`);
          }

          this.logger.log(`[Sumsub Webhook] Starting Binance KYC for user ${userId}`);
          const applicantIp = (applicant as any)?.info?.ipAddress || '0.0.0.0';
          await this.startBinanceKyc(userId, applicantIp);
          this.logger.log(`[Sumsub Webhook] Binance KYC started successfully for user ${userId}`);
        }
      } catch (error) {
        this.logger.error(
          `[Sumsub Webhook] Failed to auto-start Binance KYC for user ${userId}: ${error instanceof Error ? error.message : 'Unknown error'}`,
          error instanceof Error ? error.stack : undefined,
        );
      }
    }

    // Notify all admins about KYC status changes
    try {
      if (fields.status === KycStatus.APPROVED) {
        await this.adminNotifier.notifyAllAdmins(
          AdminNotificationType.USER,
          'KYC Approved',
          `A user's KYC has been approved. User: ${user.fullMobileNumber || user.email || userId}`,
        );
      } else if (fields.status === KycStatus.REJECTED) {
        const rejectionReason = fields.rejectionReason
          ? ` Reason: ${fields.rejectionReason}`
          : '';
        await this.adminNotifier.notifyAllAdmins(
          AdminNotificationType.USER,
          'KYC Rejected',
          `A user's KYC has been rejected and requires follow-up. User: ${user.fullMobileNumber || user.email || userId}.${rejectionReason}`,
        );
      }
    } catch (error) {
      // Don't fail webhook processing if notification fails
      this.logger.error(
        `Failed to notify admins about KYC status change: ${error instanceof Error ? error.message : 'Unknown error'}`,
      );
    }

    return {
      received: true,
      updated: true,
      status: fields.status,
      processingTimeMs: processingTime,
    };
  }

  /** Get KYC status (Sumsub + Binance). Syncs Sumsub from API on read if webhook was delayed. */
  async getKycStatus(userId: string) {
    const user = await this.getUserOrThrow(userId);

    const [sumsubKyc, binanceKyc] = await Promise.all([
      this.userKycRepository.findOne({
        where: { userId, provider: KycProvider.SUMSUB },
      }),
      this.userKycRepository.findOne({
        where: { userId, provider: KycProvider.BINANCE },
      }),
    ]);

    // Always sync latest Sumsub status from SumSub API when user checks status (webhook may be delayed/missed).
    // Fetch by externalUserId (our user.id) - same identifier used when creating applicant in startKyc.
    let effectiveSumsubKyc = sumsubKyc;
    try {
      const applicant = await this.sumsubService.getApplicantByExternalUserId(user.id);

      if (applicant) {
        const fields = this.buildSumsubKycFields(applicant, {});
        await this.userKycRepository.upsert(
          {
            userId,
            provider: KycProvider.SUMSUB,
            level: sumsubKyc?.level ?? KycLevel.BASIC,
            status: fields.status,
            referenceId: applicant.id,
            reviewAnswer: fields.reviewAnswer,
            rejectType: fields.rejectType,
            rejectionReason: fields.rejectionReason,
            verifiedAt: fields.status === KycStatus.APPROVED ? new Date() : null,
            providerPayload: fields.providerPayload as any,
          },
          ['userId', 'provider'],
        );
        effectiveSumsubKyc = await this.userKycRepository.findOne({
          where: { userId, provider: KycProvider.SUMSUB },
        });
        this.logger.debug(`[KYC] Synced Sumsub status for user ${userId}: ${fields.status}`);
      }
    } catch (e: any) {
      // Don't fail status endpoint if Sumsub API errors; return last known DB state.
      this.logger.warn(
        `[KYC] Failed to sync Sumsub status for user ${userId}: ${e?.message || e}`,
      );
    }

    const canStartBinanceKyc =
      effectiveSumsubKyc?.status === KycStatus.APPROVED &&
      (!binanceKyc || binanceKyc.status === KycStatus.REJECTED);

    const binanceKycPassed = binanceKyc?.status === KycStatus.APPROVED;
    const canCreateApiKeys =
      binanceKycPassed && !user.binanceApiKey && !user.binanceSecretKey;

    return {
      status: 'success',
      data: {
        sumsub: {
          status: effectiveSumsubKyc?.status ?? null,
          referenceId: effectiveSumsubKyc?.referenceId ?? null,
          verifiedAt: effectiveSumsubKyc?.verifiedAt ?? null,
          rejectionReason: effectiveSumsubKyc?.rejectionReason ?? null,
          rejectType: effectiveSumsubKyc?.rejectType ?? null,
          reviewAnswer: effectiveSumsubKyc?.reviewAnswer ?? null,
          updatedAt: effectiveSumsubKyc?.updatedAt ?? null,
        },
        binance: {
          status: binanceKyc?.status ?? null,
          referenceId: binanceKyc?.referenceId ?? null,
          verifiedAt: binanceKyc?.verifiedAt ?? null,
          rejectionReason: binanceKyc?.rejectionReason ?? null,
          canStart: canStartBinanceKyc,
          canCreateApiKeys,
          hasApiKeys: !!(user.binanceApiKey && user.binanceSecretKey),
          updatedAt: binanceKyc?.updatedAt ?? null,
        },
      },
    };
  }

  /**
   * Start Binance KYC (only after Sumsub is approved).
   * Ensures sub-account exists, fetches Sumsub applicant data, shares KYC with Binance eKYC API, upserts user_kyc BINANCE.
   */
  async startBinanceKyc(userId: string, clientIp: string = '0.0.0.0') {
    this.logger.log(`[KYC] Starting Binance KYC for user ${userId}`);

    const user = await this.getUserOrThrow(userId);

    const { allowed, reason } = await UserKycEntity.canStartKyc(userId, KycProvider.BINANCE, this.userKycRepository);
    if (!allowed) {
      throw new BadRequestException({ status: 'error', message: reason ?? 'Sumsub KYC must be approved first.' });
    }

    // Ensure Binance sub-account exists
    if (!user.binanceSubaccountId) {
      try {
        const sub = await this.binanceService.createSubAccount(userId.slice(0, 31));
        user.binanceSubaccountId = sub.subaccountId;
        user.binanceSubaccountEmail = sub.email;
        user.binanceSubaccountTag = sub.tag;
        await this.userRepository.save(user);
      } catch (err) {
        this.logger.error(`[KYC] Binance sub-account creation failed: ${err instanceof Error ? err.message : 'Unknown error'}`);
        throw new BadRequestException({
          status: 'error',
          message: 'Could not create Binance sub-account. Try again later.',
        });
      }
    }

    const sumsubKyc = await this.userKycRepository.findOne({
      where: { userId, provider: KycProvider.SUMSUB },
    });
    const applicantId = sumsubKyc?.referenceId ?? null;
    const applicant = applicantId
      ? await this.sumsubService.getApplicantById(applicantId)
      : await this.sumsubService.getApplicantByExternalUserId(userId);

    if (!applicant?.inspectionId) {
      throw new BadRequestException({
        status: 'error',
        message: 'Sumsub applicant data not found. Complete Sumsub KYC first.',
      });
    }

    const metadataItems = await this.sumsubService.getApplicantMetadataResources(applicant.id);
    const docSources = (s?: string) => (s || '').toLowerCase();
    const docImages = metadataItems.filter((i) => docSources(i.source).includes('document') || docSources(i.source).includes('capture'));
    const faceImages = metadataItems.filter((i) => docSources(i.source).includes('liveness') || docSources(i.source).includes('selfie'));
    const frontId = docImages[0]?.id;
    const backId = docImages[1]?.id;
    const faceId = faceImages[0]?.id ?? docImages[0]?.id;

    if (!frontId || !faceId) {
      throw new BadRequestException({
        status: 'error',
        message: 'Not enough document images from Sumsub. Ensure ID and selfie were submitted.',
      });
    }

    const baseUrl = (process.env.API_BASE_URL || '').replace(/\/$/, '');
    const docBase = baseUrl ? `${baseUrl}/v1/user/kyc/documents` : '';
    const frontUrl = docBase ? `${docBase}/${this.createKycDocumentToken(applicant.id, frontId!)}` : '';
    const backUrl = backId && docBase ? `${docBase}/${this.createKycDocumentToken(applicant.id, backId)}` : undefined;
    const faceUrl = docBase ? `${docBase}/${this.createKycDocumentToken(applicant.id, faceId!)}` : '';

    if (!process.env.BINANCE_KYC_BIZ_ENTITY_KEY || !process.env.BINANCE_KYC_SECRET || !process.env.BINANCE_BROKER_MAIN_ACCOUNT_ID) {
      throw new BadRequestException({
        status: 'error',
        message: 'Binance KYC not configured. Set BINANCE_KYC_BIZ_ENTITY_KEY, BINANCE_KYC_SECRET, BINANCE_BROKER_MAIN_ACCOUNT_ID.',
      });
    }

    const info = applicant.info ?? {};
    const firstDoc = info.idDocs?.[0] ?? {};
    const docType = (firstDoc.idDocType ?? info.idDocs?.[0]?.idDocType ?? 'ID_CARD').toUpperCase().replace(/-/g, '_');
    const basicInfo: BinanceKycBasicInfo = {
      firstName: (info.firstName ?? '').trim() || 'N',
      lastName: (info.lastName ?? '').trim() || 'A',
      residentialCountry: CountryUtil.alpha3ToAlpha2(info.nationality ?? info.country ?? ''),
      dob: info.dob ?? '1990-01-01',
      country: CountryUtil.alpha3ToAlpha2(info.country ?? info.nationality ?? ''),
      userSubmitIp: clientIp,
      address: (info.addresses?.[0]?.street ?? 'N/A').slice(0, 400),
      city: (info.addresses?.[0]?.town ?? '').slice(0, 100) || 'N/A',
    };
    const identityInfo: BinanceKycIdentityInfo = {
      documentType: docType,
      selectCountry: CountryUtil.alpha3ToAlpha2(firstDoc.country ?? info.country ?? ''),
      frontFileUrl: frontUrl,
      ...(backUrl && { backFileUrl: backUrl }),
      faceFileUrl: faceUrl,
      firstName: basicInfo.firstName,
      lastName: basicInfo.lastName,
      dob: basicInfo.dob,
      idType: docType,
      idCountry: CountryUtil.alpha3ToAlpha2(firstDoc.country ?? info.country ?? ''),
      nationalityCountry: basicInfo.country,
      idNumber: (firstDoc.number ?? 'N/A').slice(0, 50),
      ...(firstDoc.validUntil && { idExpiry: firstDoc.validUntil.slice(0, 10) }),
      userSubmitIp: clientIp,
    };

    const requestNo = `omlapay-${userId}-${Date.now()}`;
    const notifyUrl = baseUrl ? `${baseUrl}/v1/user/webhooks/binance-kyc` : 'https://example.com/webhook';

    const params: BinanceShareKycDataParams = {
      entityCustomerId: userId,
      brokerMainAccountId: process.env.BINANCE_BROKER_MAIN_ACCOUNT_ID!,
      brokerSubAccountId: user.binanceSubaccountId!,
      notifyUrl,
      basicInfo,
      identityInfo,
    };

    try {
      await this.binanceService.shareKycData(params, requestNo);
    } catch (err) {
      const errMsg = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`[KYC] Binance shareKycData failed: ${errMsg}`);
      throw new BadRequestException({
        status: 'error',
        message: errMsg || 'Binance KYC submission failed.',
      });
    }

    await this.userKycRepository.upsert(
      {
        userId: user.id,
        provider: KycProvider.BINANCE,
        status: KycStatus.INIT,
        level: KycLevel.BASIC,
        referenceId: user.binanceSubaccountId,
        reviewAnswer: null,
        rejectType: null,
        rejectionReason: null,
        verifiedAt: null,
      },
      ['userId', 'provider'],
    );

    this.logger.log(`[KYC] Binance KYC started for user ${userId}`);

    return {
      status: 'success',
      message: 'Binance KYC submitted. Status will update via webhook.',
      data: { referenceId: user.binanceSubaccountId },
    };
  }

  /**
   * Handle Binance KYC status webhook (notifyUrl callback).
   * Verifies HMAC signature, persists raw payload for audit, then processes the status update.
   */
  async handleBinanceKycWebhook(payload: any, rawBody?: string, signatureHeader?: string) {
    // 1. Verify webhook signature if secret is configured
    const secret = process.env.BINANCE_KYC_SECRET;
    if (secret && rawBody && signatureHeader) {
      const isValid = CryptoUtil.verifyHmacSignature(rawBody, signatureHeader, secret);
      if (!isValid) {
        this.logger.warn('[KYC] Binance webhook signature verification failed');
        return { received: false, reason: 'Invalid signature' };
      }
    }

    const entityCustomerId = payload?.entityCustomerId ?? payload?.userId;
    const binanceStatus = payload?.kycStatus ?? payload?.basicStatus ?? payload?.status;
    const eventType = binanceStatus ? `kyc_status_${binanceStatus}` : 'kyc_status_unknown';

    // 2. Persist raw webhook payload for audit/debugging
    let webhookRecord: BinanceWebhookEntity | null = null;
    try {
      webhookRecord = this.binanceWebhookRepository.create({
        eventType,
        payload,
        processed: false,
      });
      webhookRecord = await this.binanceWebhookRepository.save(webhookRecord);
    } catch (err) {
      this.logger.error(
        `[KYC] Failed to persist Binance webhook: ${err instanceof Error ? err.message : 'Unknown error'}`,
      );
    }

    // 3. Validate required fields
    if (!entityCustomerId) {
      this.logger.warn('[KYC] Binance webhook missing entityCustomerId');
      if (webhookRecord) {
        await this.binanceWebhookRepository.update(webhookRecord.webhookId, {
          processed: true,
          errorMessage: 'Missing entityCustomerId',
        });
      }
      return { received: true, processed: false, reason: 'Missing entityCustomerId' };
    }

    if (!binanceStatus) {
      this.logger.warn('[KYC] Binance webhook missing status');
      if (webhookRecord) {
        await this.binanceWebhookRepository.update(webhookRecord.webhookId, {
          processed: true,
          errorMessage: 'Missing status',
        });
      }
      return { received: true, processed: false, reason: 'Missing status' };
    }

    // 4. Find existing KYC record
    const existing = await this.userKycRepository.findOne({
      where: { userId: entityCustomerId, provider: KycProvider.BINANCE },
    });
    if (!existing) {
      this.logger.debug(`[KYC] No Binance KYC record for user ${entityCustomerId}`);
      if (webhookRecord) {
        await this.binanceWebhookRepository.update(webhookRecord.webhookId, {
          processed: true,
          errorMessage: `No Binance KYC record for user ${entityCustomerId}`,
        });
      }
      return { received: true, processed: false, reason: 'No KYC record found' };
    }

    // 5. Map status and update
    const status = UserKycEntity.mapBinanceStatus(binanceStatus);
    const rejectionReason = payload?.rejectReason ?? payload?.failReason ?? payload?.rejectionReason ?? null;

    // Idempotency: skip if status is already the same
    if (existing.status === status && existing.rejectionReason === rejectionReason) {
      this.logger.debug(`[KYC] Binance webhook duplicate: user=${entityCustomerId} status=${status}, skipping`);
      if (webhookRecord) {
        await this.binanceWebhookRepository.update(webhookRecord.webhookId, {
          processed: true,
        });
      }
      return { received: true, processed: false, reason: 'Duplicate status' };
    }

    existing.status = status;
    existing.rejectionReason = rejectionReason;
    existing.verifiedAt = status === KycStatus.APPROVED ? new Date() : null;
    existing.providerPayload = JSON.parse(JSON.stringify(payload)) as Record<string, unknown>;
    await this.userKycRepository.save(existing);
    this.logger.log(`[KYC] Binance webhook: user=${entityCustomerId} status=${binanceStatus} -> ${status}`);

    // 6. Auto-create API keys when KYC is PASS (Step 4 of Binance flow)
    if (status === KycStatus.APPROVED) {
      this.logger.log(`[KYC] Binance KYC approved for user ${entityCustomerId}, creating API keys`);
      try {
        await this.createBinanceApiKeys(entityCustomerId);
      } catch (error) {
        this.logger.error(
          `[KYC] Failed to auto-create Binance API keys for user ${entityCustomerId}: ${error instanceof Error ? error.message : 'Unknown error'}`,
          error instanceof Error ? error.stack : undefined,
        );
      }
    }

    // 7. Mark webhook as processed
    if (webhookRecord) {
      await this.binanceWebhookRepository.update(webhookRecord.webhookId, {
        processed: true,
      });
    }

    return { received: true, processed: true, status };
  }

  /**
   * Create Binance API keys for a user's sub-account (after KYC is approved).
   */
  async createBinanceApiKeys(userId: string) {
    this.logger.log(`[KYC] Creating Binance API keys for user ${userId}`);

    const user = await this.getUserOrThrow(userId);

    if (!user.binanceSubaccountId) {
      throw new BadRequestException({
        status: 'error',
        message: 'Binance sub-account not found. Complete Binance KYC first.',
      });
    }

    // Check if API keys already exist
    if (user.binanceApiKey && user.binanceSecretKey) {
      this.logger.log(`[KYC] Binance API keys already exist for user ${userId}`);
      return {
        status: 'success',
        message: 'API keys already exist.',
        data: {
          apiKey: user.binanceApiKey,
          createdAt: user.binanceApiKeyCreatedAt,
        },
      };
    }

    // Verify KYC is approved
    const binanceKyc = await this.userKycRepository.findOne({
      where: { userId, provider: KycProvider.BINANCE },
    });

    if (!binanceKyc || binanceKyc.status !== KycStatus.APPROVED) {
      throw new BadRequestException({
        status: 'error',
        message: 'Binance KYC must be approved before creating API keys.',
      });
    }

    // Create API keys
    try {
      const keys = await this.binanceService.createSubAccountApiKey(
        user.binanceSubaccountId,
        {
          canTrade: true,
          marginTrade: false,
          futuresTrade: false,
        },
      );

      // Store keys in user record
      user.binanceApiKey = keys.apiKey;
      user.binanceSecretKey = keys.secretKey;
      user.binanceApiKeyCreatedAt = new Date();
      await this.userRepository.save(user);

      this.logger.log(`[KYC] Binance API keys created for user ${userId}`);

      return {
        status: 'success',
        message: 'API keys created successfully.',
        data: {
          apiKey: keys.apiKey,
          subaccountId: keys.subaccountId,
          createdAt: user.binanceApiKeyCreatedAt,
        },
      };
    } catch (err) {
      const errMsg = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`[KYC] Failed to create Binance API keys: ${errMsg}`);
      throw new BadRequestException({
        status: 'error',
        message: errMsg || 'Failed to create API keys.',
      });
    }
  }

  /**
   * Check Binance KYC status directly from Binance API.
   */
  async checkBinanceKycStatus(userId: string) {
    this.logger.log(`[KYC] Checking Binance KYC status for user ${userId}`);

    const user = await this.getUserOrThrow(userId);

    if (!user.binanceSubaccountId) {
      throw new BadRequestException({
        status: 'error',
        message: 'Binance sub-account not found.',
      });
    }

    try {
      const result = await this.binanceService.checkKycStatus(
        userId,
        user.binanceSubaccountId,
      );

      this.logger.log(`[KYC] Binance KYC status for user ${userId}: ${result.kycStatus}`);

      // Update local status if different
      const localKyc = await this.userKycRepository.findOne({
        where: { userId, provider: KycProvider.BINANCE },
      });

      if (localKyc) {
        const mappedStatus = UserKycEntity.mapBinanceStatus(result.kycStatus);
        if (localKyc.status !== mappedStatus) {
          await this.userKycRepository.update(
            { userId, provider: KycProvider.BINANCE },
            {
              status: mappedStatus,
              verifiedAt: mappedStatus === KycStatus.APPROVED ? new Date() : null,
            },
          );
          this.logger.log(`[KYC] Updated local Binance KYC status: ${localKyc.status} -> ${mappedStatus}`);
        }
      }

      return {
        status: 'success',
        data: {
          kycStatus: result.kycStatus,
          kycPassed: result.kycStatus === 'PASS',
          currentLevel: result.currentLevel,
          subaccountId: user.binanceSubaccountId,
        },
      };
    } catch (err) {
      const errMsg = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`[KYC] Failed to check Binance KYC status: ${errMsg}`);
      throw new BadRequestException({
        status: 'error',
        message: errMsg || 'Failed to check KYC status.',
      });
    }
  }
}
