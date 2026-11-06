import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import {
  AuthSessionEntity,
  UserEntity,
  UserSecurityEntity,
} from '@common/database/model';
import { OtpService } from '@common/services/otp/otp.service';
import { TrustedDeviceService } from '@common/services/trusted-device/trusted-device.service';
import { assertStrongPasscode, validatePasscodeMatch } from '@common/utils';
import { AuthService } from '../auth/auth.service';
import { ChangePasscodeDto } from './dto/change-passcode.dto';

const SAME_PASSCODE = {
  status: 'error',
  code: 'SAME_PASSCODE',
  message: 'The new passcode must be different from the current one.',
  message_ar: 'يجب أن يكون رمز المرور الجديد مختلفًا عن الحالي.',
};

/**
 * Change passcode (stage 3): POST /user/settings/change-passcode.
 *
 * The current passcode is the proof (wrong tries count toward the lockout). The new one must
 * match its confirmation, differ from the current one and not be obvious (assertStrongPasscode).
 * Afterwards every other session and remembered phone is logged out; this phone gets a fresh
 * session in the reply and stays remembered. An SMS tells the owner about the change.
 */
@Injectable()
export class ChangePasscodeService {
  private readonly logger = new Logger(ChangePasscodeService.name);

  constructor(
    @InjectRepository(UserEntity)
    private readonly users: Repository<UserEntity>,
    @InjectRepository(UserSecurityEntity)
    private readonly security: Repository<UserSecurityEntity>,
    @InjectRepository(AuthSessionEntity)
    private readonly sessions: Repository<AuthSessionEntity>,
    private readonly authService: AuthService,
    private readonly trustedDevices: TrustedDeviceService,
    private readonly otpService: OtpService,
  ) {}

  async changePasscode(
    userId: string,
    sessionId: string,
    dto: ChangePasscodeDto,
  ) {
    // Current passcode; wrong tries count toward the 5-try lockout
    await this.authService.softLogin(userId, sessionId, {
      passcode: dto.current_passcode,
    });

    validatePasscodeMatch(dto.new_passcode, dto.confirm_passcode);
    if (dto.new_passcode === dto.current_passcode) {
      throw new BadRequestException(SAME_PASSCODE);
    }
    assertStrongPasscode(dto.new_passcode);

    const user = await this.users.findOne({ where: { id: userId } });
    const userSecurity = await this.security.findOne({ where: { userId } });
    if (!user || !userSecurity) {
      throw new BadRequestException({
        status: 'error',
        message: 'User not found.',
      });
    }

    userSecurity.passcodeHash = await bcrypt.hash(dto.new_passcode, 10);
    userSecurity.lastPasscodeChangedAt = new Date();
    userSecurity.failedAttempts = 0;
    userSecurity.lockedUntil = null;
    await this.security.save(userSecurity);

    // Log out everywhere else; this phone keeps its remembered device and gets a new session
    const current = await this.sessions.findOne({
      where: { id: sessionId, userId },
    });
    const keepDeviceId = current?.trustedDeviceId ?? null;
    await this.sessions.update(
      { userId, isRevoked: false },
      { isRevoked: true },
    );
    await this.trustedDevices.revokeAllForUser(userId, keepDeviceId);
    const session = await this.authService.createSession(userId, keepDeviceId);

    try {
      await this.otpService.sendSms(
        user.fullMobileNumber,
        "Your OmlaPay passcode was changed. If this wasn't you, contact OmlaPay support now. " +
          'تم تغيير رمز المرور في OmlaPay. إذا لم تكن أنت، تواصل مع الدعم فورًا.',
      );
    } catch (error) {
      // The change itself succeeded; a failed alert must not undo it
      this.logger.error(
        `Passcode-changed SMS failed for user ${userId}: ${error instanceof Error ? error.message : 'unknown error'}`,
      );
    }

    return {
      status: 'success',
      message:
        'Passcode changed successfully. Other devices have been logged out.',
      message_ar:
        'تم تغيير رمز المرور بنجاح. تم تسجيل الخروج من الأجهزة الأخرى.',
      data: session,
    };
  }
}
