import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import { UserEntity } from './user.entity';

export enum SupportRequestStatus {
  OPEN = 'OPEN',
  SOLVED = 'SOLVED',
  REJECTED = 'REJECTED',
}

@Entity('support_requests')
@Index('ix_support_requests_user_id', ['userId'])
@Index('ix_support_requests_status', ['status'])
export class SupportRequestEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  user: UserEntity;

  @Column({ length: 255 })
  title: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ type: 'text', nullable: true })
  attachmentUrl: string | null;

  @Column({
    type: 'enum',
    enum: SupportRequestStatus,
    default: SupportRequestStatus.OPEN,
  })
  status: SupportRequestStatus;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
