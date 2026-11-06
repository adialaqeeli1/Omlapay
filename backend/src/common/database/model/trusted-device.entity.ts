import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { UserEntity } from './user.entity';

/**
 * A phone that proved the user's number by SMS (login code, registration or forgot passcode).
 * Its secret token lets POST /auth/login/passcode log in again without a new SMS code.
 */
@Entity('trusted_devices')
@Index('ix_trusted_devices_user_id', ['userId'])
@Index('ux_trusted_devices_token_hash', ['tokenHash'], { unique: true })
export class TrustedDeviceEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  user: UserEntity;

  /** SHA-256 of the token; the token itself is only on the phone */
  @Column({ length: 64 })
  tokenHash: string;

  /** Device identifier the app sent when the token was issued, if any */
  @Column({ type: 'varchar', length: 128, nullable: true })
  deviceId: string | null;

  @Column({ type: 'timestamp' })
  expiresAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  lastUsedAt: Date | null;

  @Column({ type: 'timestamp', nullable: true })
  revokedAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;
}
