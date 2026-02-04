import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
  JoinColumn,
  ManyToOne,
} from 'typeorm';
import { AdminEntity } from './admin.entity';

@Entity('admin_otps')
@Index('ix_admin_otps_admin_id', ['adminId'])
@Index('ix_admin_otps_expires_at', ['expiresAt'])
export class AdminOtpEntity {
  @PrimaryGeneratedColumn('uuid', { name: 'otp_id' })
  otpId: string;

  @Column({ type: 'uuid', name: 'admin_id' })
  adminId: string;

  @ManyToOne(() => AdminEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'admin_id' })
  admin: AdminEntity;

  @Column({ type: 'varchar', length: 64, name: 'otp_code' })
  otpCode: string;

  @Column({ type: 'varchar', length: 255, name: 'sent_to' })
  sentTo: string;

  @Column({ type: 'timestamp', name: 'expires_at' })
  expiresAt: Date;

  @Column({ type: 'integer', default: 0, name: 'attempt_count' })
  attemptCount: number;

  @Column({ type: 'boolean', default: false, name: 'is_used' })
  isUsed: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

