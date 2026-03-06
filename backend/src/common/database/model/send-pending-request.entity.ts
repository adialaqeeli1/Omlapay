import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { UserEntity } from './user.entity';
import { CoinEntity } from './coin.entity';
import { WalletEntity } from './wallet.entity';

export enum RecipientType {
  INTERNAL = 'INTERNAL',
  EXTERNAL = 'EXTERNAL',
}

@Entity('send_pending_requests')
@Index('ix_send_pending_user_id', ['userId'])
@Index('ix_send_pending_expires_at', ['expiresAt'])
export class SendPendingRequestEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  user: UserEntity;

  @Column('uuid')
  otpRequestId: string;

  @Column({ type: 'varchar', length: 20 })
  recipientType: RecipientType;

  @Column({ type: 'varchar', length: 128 })
  recipientIdentifier: string;

  @Column('uuid')
  coinId: string;

  @ManyToOne(() => CoinEntity, { onDelete: 'RESTRICT' })
  coin: CoinEntity;

  @Column({ type: 'varchar', length: 50 })
  network: string;

  @Column({ type: 'decimal', precision: 36, scale: 18 })
  amount: string;

  @Column({ type: 'decimal', precision: 36, scale: 18, default: 0 })
  fee: string;

  @Column('uuid', { nullable: true })
  recipientUserId: string | null;

  @Column('uuid', { nullable: true })
  recipientWalletId: string | null;

  @Column({ type: 'varchar', length: 128, nullable: true })
  recipientAddress: string | null;

  @Column({ type: 'varchar', length: 64, nullable: true })
  addressTag: string | null;

  @Column({ type: 'timestamp' })
  expiresAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}
