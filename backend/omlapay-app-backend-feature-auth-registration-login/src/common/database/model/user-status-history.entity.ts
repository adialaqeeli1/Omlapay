import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { UserEntity } from './user.entity';
import { AdminEntity } from './admin.entity';

export enum UserStatus {
  ACTIVE = 'ACTIVE',
  BLOCKED = 'BLOCKED',
}

@Entity('user_status_history')
@Index('ix_user_status_history_user_id', ['userId'])
@Index('ix_user_status_history_admin_id', ['changedByAdminId'])
@Index('ix_user_status_history_created_at', ['createdAt'])
export class UserStatusHistoryEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: UserEntity;

  @Column({
    type: 'enum',
    enum: UserStatus,
    name: 'old_status',
  })
  oldStatus: UserStatus;

  @Column({
    type: 'enum',
    enum: UserStatus,
    name: 'new_status',
  })
  newStatus: UserStatus;

  @Column({ type: 'text' })
  reason: string;

  @Column({ type: 'uuid', name: 'changed_by_admin_id' })
  changedByAdminId: string;

  @ManyToOne(() => AdminEntity, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'changed_by_admin_id' })
  changedByAdmin: AdminEntity;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
