import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { AdminEntity } from './admin.entity';

export enum AdminNotificationType {
  SECURITY = 'SECURITY',
  USER = 'USER',
  TRANSACTION = 'TRANSACTION',
  TICKET = 'TICKET',
}

@Entity('admin_notifications')
@Index('ix_admin_notifications_admin_id', ['adminId'])
@Index('ix_admin_notifications_is_read', ['isRead'])
@Index('ix_admin_notifications_created_at', ['createdAt'])
export class AdminNotificationEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'admin_id' })
  adminId: string;

  @ManyToOne(() => AdminEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'admin_id' })
  admin: AdminEntity;

  @Column({
    type: 'enum',
    enum: AdminNotificationType,
  })
  type: AdminNotificationType;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'boolean', default: false, name: 'is_read' })
  isRead: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
