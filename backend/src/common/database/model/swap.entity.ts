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
import { CoinEntity } from './coin.entity';

export enum SwapStatus {
  PENDING = 'PENDING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
}

@Entity('swaps')
@Index('ix_swaps_user_id', ['userId'])
@Index('ix_swaps_status', ['status'])
@Index('ux_swaps_idempotency_key', ['idempotencyKey'], { unique: true })
export class SwapEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  user: UserEntity;

  @Column('uuid')
  fromCoinId: string;

  @ManyToOne(() => CoinEntity, { onDelete: 'RESTRICT' })
  fromCoin: CoinEntity;

  @Column('uuid')
  toCoinId: string;

  @ManyToOne(() => CoinEntity, { onDelete: 'RESTRICT' })
  toCoin: CoinEntity;

  @Column({ type: 'decimal', precision: 36, scale: 18 })
  fromAmount: string;

  @Column({ type: 'decimal', precision: 36, scale: 18 })
  toAmount: string;

  @Column({ type: 'decimal', precision: 36, scale: 18 })
  exchangeRate: string;

  @Column({ type: 'decimal', precision: 36, scale: 18, default: 0 })
  fee: string;

  @Column({
    type: 'enum',
    enum: SwapStatus,
    default: SwapStatus.PENDING,
  })
  status: SwapStatus;

  @Column({ type: 'varchar', length: 64, unique: true })
  idempotencyKey: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

