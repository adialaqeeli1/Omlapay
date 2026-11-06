import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import { UserEntity } from './user.entity';

/**
 * A phone's push-notification (FCM) token, registered by the app after login
 * (POST /v1/notifications/devices). Tied to the session that registered it, so a
 * notification sender can skip phones whose session has ended.
 */
@Entity('push_devices')
@Index('ix_push_devices_user_id', ['userId'])
@Index('ux_push_devices_device_token', ['deviceToken'], { unique: true })
export class PushDeviceEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  user: UserEntity;

  /** FCM registration token */
  @Column({ type: 'varchar', length: 4096 })
  deviceToken: string;

  /** iOS identifierForVendor / Android build fingerprint, as sent by the app */
  @Column({ type: 'varchar', length: 255 })
  deviceUuid: string;

  @Column({ type: 'varchar', length: 100 })
  deviceModel: string;

  /** The login session that registered this token */
  @Column({ type: 'uuid', nullable: true })
  sessionId: string | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
