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

@Entity('admin_audit_logs')
@Index('ix_admin_audit_logs_admin_id', ['adminId'])
@Index('ix_admin_audit_logs_created_at', ['createdAt'])
export class AdminAuditLogEntity {
  @PrimaryGeneratedColumn('uuid', { name: 'log_id' })
  logId: string;

  @Column({ type: 'uuid', nullable: true, name: 'admin_id' })
  adminId: string | null;

  @ManyToOne(() => AdminEntity, { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'admin_id' })
  admin: AdminEntity | null;

  @Column({ type: 'varchar', length: 100 })
  action: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata: Record<string, any> | null;

  @Column({ type: 'varchar', length: 45, nullable: true, name: 'ip_address' })
  ipAddress: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

