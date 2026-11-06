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
@Index('ix_support_requests_guest_token_hash', ['guestTokenHash'])
export class SupportRequestEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /** The account that sent it; null for a request sent without an account (guest) */
  @Column({ type: 'uuid', nullable: true })
  userId: string | null;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE', nullable: true })
  user: UserEntity | null;

  /**
   * Guest requests only: SHA-256 of the secret guest token the server gave the app with the
   * first request. The app sends the token to list and read its requests.
   */
  @Column({ type: 'varchar', length: 64, nullable: true })
  guestTokenHash: string | null;

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
