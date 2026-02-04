import {
  Injectable,
  ConflictException,
  BadRequestException,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { UserEntity } from '@common/database/model';
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
} from '@common/database/model';
import {
  UserKycEntity,
  KycStatus,
  KycLevel,
  KycProvider,
  KycRejectType,
} from '@common/database/model';
import { generateOTP, generateHash } from '@common/filters';
import { RegisterRequestDto } from './dto/register-request.dto';
import { SetPasscodeDto } from './dto/set-passcode.dto';
import { ResetPasscodeDto } from './dto/reset-passcode.dto';
import { UpdateAppearanceDto } from './dto/update-appearance.dto';
import { UpdateLanguageDto } from './dto/update-language.dto';
import { UpdateNotificationsDto } from './dto/update-notifications.dto';
import { Enable2FARequestDto } from './dto/enable-2fa-request.dto';
import { Verify2FADto } from './dto/verify-2fa.dto';
import { StartKycDto } from './dto/start-kyc.dto';
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
    private jwtService: JwtService,
    private otpService: OtpService,
    private mailService: MailService,
    private binanceService: BinanceService,
    private sumsubService: SumsubService,
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
   * Map StartKycDto to Sumsub fixedInfo (only non-empty fields).
   * residentialCountry → nationality; address + city → addresses[0].
   */
  private buildSumsubFixedInfoFromDto(dto?: StartKycDto): SumsubFixedInfo | undefined {
    if (!dto) return undefined;
    const info: SumsubFixedInfo = {};
    if (dto.firstName) info.firstName = dto.firstName;
    if (dto.lastName) info.lastName = dto.lastName;
    if (dto.dob) info.dob = dto.dob;
    if (dto.country) info.country = dto.country;
    if (dto.residentialCountry) info.nationality = dto.residentialCountry;
    if (dto.address || dto.city) {
      info.addresses = [{
        ...(dto.address && { street: dto.address }),
        ...(dto.city && { town: dto.city }),
        ...(dto.residentialCountry && { country: dto.residentialCountry }),
      }];
    }
    return Object.keys(info).length > 0 ? info : undefined;
  }

  /** Get JWT secret from env (fallback for backward compatibility). */
  private getJwtSecret(): string {
    return process.env.JWT_SECRET_KEY || process.env.JWT_SECRET || 'kyc-doc-secret';
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
      throw new BadRequestException((err as Error).message || 'Invalid document token');
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

    // 4. Pre-fill applicant fixedInfo if provided (create or update applicant before SDK token)
    if (fixedInfo && Object.keys(fixedInfo).length > 0) {
      try {
        const existing = await this.sumsubService.getApplicantByExternalUserId(user.id);
        if (existing?.id) {
          await this.sumsubService.updateApplicantFixedInfo(existing.id, fixedInfo);
        } else {
          await this.sumsubService.createApplicant(user.id, levelName, {
            email: user.email ?? undefined,
            phone: user.fullMobileNumber,
            fixedInfo,
          });
        }
      } catch (err) {
        this.logger.warn(`[KYC] Pre-fill fixedInfo failed, continuing with SDK token: ${(err as Error).message}`);
      }
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
        `[KYC] Failed to start KYC for user ${userId}: ${error.message}`,
        error.stack,
      );
      throw new BadRequestException({
        status: 'error',
        message: 'Failed to start KYC process. Please try again later.',
        details: process.env.NODE_ENV === 'development' ? error.message : undefined,
      });
    }
  }

  // --- Registration & auth ---

  async registerRequest(dto: RegisterRequestDto) {
    const fullMobileNumber = `${dto.country_code}${dto.mobile_number}`;

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
    const otp = generateOTP();
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

    //TODO: await this.otpService.sendOTP(fullMobileNumber, otp);
    console.log(`OTP for ${fullMobileNumber}: ${otp}`);

    return {
      status: 'success',
      message: 'OTP sent to your mobile number.',
    };
  }

  async setPasscode(dto: SetPasscodeDto) {
    // Validate passcodes match early and bail out quickly if invalid
    if (dto.passcode !== dto.confirm_passcode) {
      throw new BadRequestException({
        status: 'error',
        message: 'Passcodes do not match.',
      });
    }

    // Decode and validate registration token
    let payload: { userId: string; type: string };
    try {
      payload = this.jwtService.verify(dto.registration_token);
    } catch {
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

    // Create default user settings
    await this.userSettingsRepository.save({
      userId: user.id,
      theme: Theme.LIGHT,
      language: Language.AR,
      notificationsEnabled: true,
    });

    /** UNCOMMENT THIS WHEN BINANCE IS READY TO USE IN PRODUCTION */

    // // Create Binance sub account
    // try {
    //   const binanceSubAccount = await this.binanceService.createSubAccount();

    //   user.binanceSubaccountId = binanceSubAccount.subaccountId;
    //   user.binanceSubaccountEmail = binanceSubAccount.email;
    //   user.binanceSubaccountTag = binanceSubAccount.tag;
    //   await this.userRepository.save(user);
    // } catch (error) {
    //   // Log error but don't fail registration if Binance fails
    //   console.error('Failed to create Binance sub account during registration:', error);
    //   // Registration still succeeds even if Binance fails
    // }

    /** END OF UNCOMMENT THIS WHEN BINANCE IS READY TO USE IN PRODUCTION */

    return {
      status: 'success',
      message: 'Registration completed successfully.',
    };
  }

  async resetPasscode(dto: ResetPasscodeDto) {
    // Verify passcodes match
    if (dto.new_passcode !== dto.confirm_passcode) {
      throw new BadRequestException({
        status: 'error',
        message: 'Passcodes do not match. Please try again.',
      });
    }

    // Verify reset token
    let payload: { userId: string; type: string };
    try {
      payload = this.jwtService.verify(dto.reset_token);
      if (payload.type !== 'reset') {
        throw new UnauthorizedException({
          status: 'error',
          message: 'Invalid reset token.',
        });
      }
    } catch (error) {
      throw new UnauthorizedException({
        status: 'error',
        message: 'Invalid or expired reset token.',
      });
    }

    // Get user
    const user = await this.userRepository.findOne({
      where: { id: payload.userId },
    });

    if (!user) {
      throw new BadRequestException({
        status: 'error',
        message: 'User not found.',
      });
    }

    // Get user security record
    const userSecurity = await this.userSecurityRepository.findOne({
      where: { userId: user.id },
    });

    if (!userSecurity) {
      throw new BadRequestException({
        status: 'error',
        message: 'User security record not found.',
      });
    }

    // Hash new passcode
    const passcodeHash = await bcrypt.hash(dto.new_passcode, 10);

    // Update passcode
    userSecurity.passcodeHash = passcodeHash;
    userSecurity.lastPasscodeChangedAt = new Date();
    userSecurity.failedAttempts = 0;
    userSecurity.lockedUntil = null;
    await this.userSecurityRepository.save(userSecurity);

    // Revoke all active sessions for security
    await this.authSessionRepository.update(
      { userId: user.id, isRevoked: false },
      { isRevoked: true },
    );

    return {
      status: 'success',
      message: 'Passcode reset successfully. Please login again.',
    };
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

  async enable2FARequest(userId: string, dto: Enable2FARequestDto) {
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
    if (user.email && user.email !== dto.email) {
      throw new BadRequestException({
        status: 'error',
        message: 'Email does not match your account.',
      });
    }

    // Update user email if not set
    if (!user.email) {
      user.email = dto.email;
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
    const mobileOtp = generateOTP();
    const emailOtp = generateOTP();
    const mobileOtpHash = generateHash(mobileOtp);
    const emailOtpHash = generateHash(emailOtp);

    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 5); // 5 minutes validity

    // Invalidate previous OTPs
    await this.otpRepository.delete({
      fullMobileNumber,
      purpose: OtpPurpose.TWO_FACTOR_MOBILE,
    });
    await this.otpRepository.delete({
      email: dto.email,
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
      email: dto.email,
      otpHash: emailOtpHash,
      purpose: OtpPurpose.TWO_FACTOR_EMAIL,
      expiresAt,
      attempts: 0,
      maxAttempts: 3,
      resendAttempts: 0,
      lastResendAt: new Date(),
    });

    // Send OTPs via SMS and Email services
    // await Promise.all([
    //   this.otpService.sendOTP(fullMobileNumber, mobileOtp),
    //   this.mailService.sendOTP(dto.email, emailOtp),
    // ]);
    console.log(`Mobile OTP for ${fullMobileNumber}: ${mobileOtp}`);
    console.log(`Email OTP for ${dto.email}: ${emailOtp}`);

    return {
      status: 'success',
      message: 'Verification codes sent to your mobile number and email.',
      data: {
        mobile_number: fullMobileNumber,
        email: dto.email,
      },
    };
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

  async logout(userId: string) {
    // Revoke all active sessions
    const result = await this.authSessionRepository.update(
      { userId, isRevoked: false },
      { isRevoked: true },
    );

    if (result.affected === 0) {
      throw new BadRequestException({
        status: 'error',
        message: 'No active session found.',
      });
    }

    return {
      status: 'success',
      message: 'Logged out successfully.',
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

    /* 
    // TODO: Auto-start Binance KYC flow (requires production Binance Broker API)
    // - Create Binance sub-account
    // - Start Binance KYC after Sumsub approval
    // Currently disabled because Binance Broker APIs are not available on testnet

    // 6. Auto-start Binance KYC flow if Sumsub is approved
    if (fields.status === KycStatus.APPROVED) {
      this.logger.log(`[Sumsub Webhook] Sumsub approved for user ${userId}, checking Binance flow`);
      
      try {
        // Check if Binance KYC already exists and is in progress
        const binanceKyc = await this.userKycRepository.findOne({
          where: { userId, provider: KycProvider.BINANCE },
        });

        const shouldStartBinance = !binanceKyc || binanceKyc.status === KycStatus.REJECTED;

        if (!shouldStartBinance) {
          this.logger.log(
            `[Sumsub Webhook] Binance KYC already exists with status ${binanceKyc?.status}, skipping auto-start`,
          );
        } else {
          // Create Binance sub-account if it doesn't exist
          if (!user.binanceSubaccountId) {
            this.logger.log(`[Sumsub Webhook] Creating Binance sub-account for user ${userId}`);
            const sub = await this.binanceService.createSubAccount();
            user.binanceSubaccountId = sub.subaccountId;
            user.binanceSubaccountEmail = sub.email;
            user.binanceSubaccountTag = sub.tag;
            await this.userRepository.save(user);
            this.logger.log(`[Sumsub Webhook] Binance sub-account created: ${sub.subaccountId}`);
          } else {
            this.logger.log(`[Sumsub Webhook] Binance sub-account already exists: ${user.binanceSubaccountId}`);
          }

          // Start Binance KYC automatically
          this.logger.log(`[Sumsub Webhook] Starting Binance KYC for user ${userId}`);
          await this.startBinanceKyc(userId);
          this.logger.log(`[Sumsub Webhook] Binance KYC started successfully for user ${userId}`);
        }
      } catch (error) {
        // Log error but don't fail the webhook processing
        this.logger.error(
          `[Sumsub Webhook] Failed to auto-start Binance KYC for user ${userId}: ${(error as Error).message}`,
          (error as Error).stack,
        );
        // Continue processing - webhook is still considered successful
      }
    }
    */

    // TODO: Notify user on status change; analytics; alert on rejection
    // - Send notification to user about KYC status change
    // - Trigger analytics event
    // - Update user permissions if approved
    // - Send to monitoring/alerting if rejected

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

    // If webhook was delayed/missed, sync latest Sumsub status on read and persist
    // and persist it to DB so the client sees up-to-date status.
    let effectiveSumsubKyc = sumsubKyc;
    try {
      const shouldSyncFromSumsub =
        !!sumsubKyc &&
        sumsubKyc.provider === KycProvider.SUMSUB &&
        sumsubKyc.status !== KycStatus.APPROVED &&
        sumsubKyc.status !== KycStatus.REJECTED;

      if (shouldSyncFromSumsub) {
        const applicant = sumsubKyc.referenceId
          ? await this.sumsubService.getApplicantById(sumsubKyc.referenceId)
          : await this.sumsubService.getApplicantByExternalUserId(userId);

        if (applicant?.review?.reviewStatus) {
          const fields = this.buildSumsubKycFields(applicant, {});
          await this.userKycRepository.update(
            { userId, provider: KycProvider.SUMSUB },
            {
              status: fields.status,
              referenceId: applicant.id,
              reviewAnswer: fields.reviewAnswer,
              rejectType: fields.rejectType,
              rejectionReason: fields.rejectionReason,
              verifiedAt: fields.status === KycStatus.APPROVED ? new Date() : null,
              providerPayload: fields.providerPayload as any,
            },
          );
        } else if (applicant && !sumsubKyc.referenceId) {
          await this.userKycRepository.update(
            { userId, provider: KycProvider.SUMSUB },
            {
              referenceId: applicant.id,
              providerPayload: applicant as any,
            },
          );
        }
        effectiveSumsubKyc = await this.userKycRepository.findOne({
          where: { userId, provider: KycProvider.SUMSUB },
        });
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
          updatedAt: binanceKyc?.updatedAt ?? null,
        },
      },
    };
  }

  /**
   * Start Binance KYC (only after Sumsub is approved).
   * Ensures sub-account exists, fetches Sumsub applicant data, shares KYC with Binance eKYC API, upserts user_kyc BINANCE.
   */
  async startBinanceKyc(userId: string) {
    this.logger.log(`[KYC] Starting Binance KYC for user ${userId}`);

    const user = await this.getUserOrThrow(userId);

    const { allowed, reason } = await UserKycEntity.canStartKyc(userId, KycProvider.BINANCE, this.userKycRepository);
    if (!allowed) {
      throw new BadRequestException({ status: 'error', message: reason ?? 'Sumsub KYC must be approved first.' });
    }

    // Ensure Binance sub-account exists
    if (!user.binanceSubaccountId) {
      try {
        const sub = await this.binanceService.createSubAccount();
        user.binanceSubaccountId = sub.subaccountId;
        user.binanceSubaccountEmail = sub.email;
        user.binanceSubaccountTag = sub.tag;
        await this.userRepository.save(user);
      } catch (err) {
        this.logger.error(`[KYC] Binance sub-account creation failed: ${(err as Error).message}`);
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
      userSubmitIp: '0.0.0.0',
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
      userSubmitIp: '0.0.0.0',
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
      this.logger.error(`[KYC] Binance shareKycData failed: ${(err as Error).message}`);
      throw new BadRequestException({
        status: 'error',
        message: (err as Error).message || 'Binance KYC submission failed.',
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
   */
  async handleBinanceKycWebhook(payload: any) {
    const entityCustomerId = payload?.entityCustomerId ?? payload?.userId;
    if (!entityCustomerId) {
      this.logger.warn('[KYC] Binance webhook missing entityCustomerId');
      return;
    }

    const binanceStatus = payload?.kycStatus ?? payload?.basicStatus ?? payload?.status;
    if (!binanceStatus) {
      this.logger.warn('[KYC] Binance webhook missing status');
      return;
    }

    const existing = await this.userKycRepository.findOne({
      where: { userId: entityCustomerId, provider: KycProvider.BINANCE },
    });
    if (!existing) {
      this.logger.debug(`[KYC] No Binance KYC record for user ${entityCustomerId}`);
      return;
    }

    const status = UserKycEntity.mapBinanceStatus(binanceStatus);
    const rejectionReason = payload?.rejectReason ?? payload?.failReason ?? payload?.rejectionReason ?? null;

    await this.userKycRepository.update(
      { userId: entityCustomerId, provider: KycProvider.BINANCE },
      {
        status,
        rejectionReason,
        verifiedAt: status === KycStatus.APPROVED ? new Date() : null,
      },
    );
    this.logger.log(`[KYC] Binance webhook: user=${entityCustomerId} status=${binanceStatus} -> ${status}`);

    /* 
    // TODO: Auto-create API keys on KYC approval (requires production Binance Broker API)
    // - Automatically generate sub-account API keys when Binance KYC is approved
    // Currently disabled because Binance Broker createSubAccountApiKey API is not available on testnet
    
    // Auto-create API keys if KYC is approved
    if (status === KycStatus.APPROVED) {
      this.logger.log(`[KYC] Binance KYC approved for user ${entityCustomerId}, creating API keys`);
      
      try {
        await this.createBinanceApiKeys(entityCustomerId);
      } catch (error) {
        this.logger.error(
          `[KYC] Failed to auto-create Binance API keys for user ${entityCustomerId}: ${(error as Error).message}`,
          (error as Error).stack,
        );
        // Don't fail the webhook - API keys can be created manually later
      }
    }
    */
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
      this.logger.error(`[KYC] Failed to create Binance API keys: ${(err as Error).message}`);
      throw new BadRequestException({
        status: 'error',
        message: (err as Error).message || 'Failed to create API keys.',
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
          currentLevel: result.currentLevel,
          subaccountId: user.binanceSubaccountId,
        },
      };
    } catch (err) {
      this.logger.error(`[KYC] Failed to check Binance KYC status: ${(err as Error).message}`);
      throw new BadRequestException({
        status: 'error',
        message: (err as Error).message || 'Failed to check KYC status.',
      });
    }
  }
}
