import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  JoinColumn,
  ManyToOne,
} from 'typeorm';
import { AdminEntity } from './admin.entity';

@Entity('admin_security')
@Index('ix_admin_security_admin_id', ['adminId'])
@Index('ix_admin_security_locked_until', ['lockedUntil'])
export class AdminSecurityEntity {
  @PrimaryGeneratedColumn('uuid', { name: 'admin_security_id' })
  adminSecurityId: string;

  @Column({ type: 'uuid', name: 'admin_id' })
  adminId: string;

  @ManyToOne(() => AdminEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'admin_id' })
  admin: AdminEntity;

  @Column({ type: 'integer', default: 0, name: 'failed_login_attempts' })
  failedLoginAttempts: number;

  @Column({ type: 'timestamp', nullable: true, name: 'locked_until' })
  lockedUntil: Date | null;

  @Column({ type: 'timestamp', nullable: true, name: 'last_failed_login_at' })
  lastFailedLoginAt: Date | null;

  @Column({ type: 'timestamp', nullable: true, name: 'password_updated_at' })
  passwordUpdatedAt: Date | null;

  @Column({ type: 'timestamp', nullable: true, name: 'last_login_at' })
  lastLoginAt: Date | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

