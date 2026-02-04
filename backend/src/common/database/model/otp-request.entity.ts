import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

export enum OtpPurpose {
  REGISTER = 'REGISTER',
  RESET = 'RESET',
  EMAIL_VERIFICATION = 'EMAIL_VERIFICATION',
  FORGOT_PASSCODE_MOBILE = 'FORGOT_PASSCODE_MOBILE',
  FORGOT_PASSCODE_EMAIL = 'FORGOT_PASSCODE_EMAIL',
  TWO_FACTOR_MOBILE = 'TWO_FACTOR_MOBILE',
  TWO_FACTOR_EMAIL = 'TWO_FACTOR_EMAIL',
}

@Entity('otp_requests')
@Index('ix_otp_full_mobile_number', ['fullMobileNumber'])
@Index('ix_otp_expires_at', ['expiresAt'])
export class OtpRequestEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 20 })
  fullMobileNumber: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  email: string | null;

  @Column()
  otpHash: string;

  @Column({ type: 'enum', enum: OtpPurpose })
  purpose: OtpPurpose;

  @Column({ default: 0 })
  attempts: number;

  @Column({ default: 3 })
  maxAttempts: number;

  @Column({ type: 'timestamp' })
  expiresAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  lockedUntil: Date | null;

  @Column({ default: 0 })
  resendAttempts: number;

  @Column({ type: 'timestamp', nullable: true })
  lastResendAt: Date | null;

  @Column({ default: false })
  isConsumed: boolean;

  @CreateDateColumn()
  createdAt: Date;
}
