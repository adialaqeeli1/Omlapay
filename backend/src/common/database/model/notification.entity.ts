import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { UserEntity } from './user.entity';

export enum NotificationType {
  TX = 'TX',
  SECURITY = 'SECURITY',
  SYSTEM = 'SYSTEM',
  PROMO = 'PROMO',
}

export enum NotificationReferenceType {
  TRANSACTION = 'TRANSACTION',
  SWAP = 'SWAP',
  LOGIN = 'LOGIN',
}

@Entity('notifications')
@Index('ix_notifications_user_created', ['userId', 'createdAt'])
@Index('ix_notifications_is_read', ['isRead'])
@Index('ix_notifications_type', ['type'])
export class NotificationEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  user: UserEntity;

  @Column({
    type: 'enum',
    enum: NotificationType,
  })
  type: NotificationType;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'uuid', nullable: true })
  referenceId: string | null;

  @Column({
    type: 'enum',
    enum: NotificationReferenceType,
    nullable: true,
  })
  referenceType: NotificationReferenceType | null;

  @Column({ default: false })
  isRead: boolean;

  @CreateDateColumn()
  createdAt: Date;
}

