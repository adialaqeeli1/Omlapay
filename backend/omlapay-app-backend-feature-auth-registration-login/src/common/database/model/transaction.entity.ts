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
import { WalletEntity } from './wallet.entity';

export enum TransactionDirection {
  IN = 'IN',
  OUT = 'OUT',
}

export enum TransactionType {
  SENT = 'SENT',
  RECEIVED = 'RECEIVED',
}

export enum TransactionStatus {
  PENDING = 'PENDING',
  PROCESSING = 'PROCESSING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
}

export enum TransactionProvider {
  BINANCE = 'BINANCE',
}

export enum BinanceTransferType {
  TO_MAIN = 'TO_MAIN',
  TO_PAY = 'TO_PAY',
}

@Entity('transactions')
@Index('ix_transactions_user_created', ['userId', 'createdAt'])
@Index('ix_transactions_status', ['status'])
@Index('ix_transactions_coin_id', ['coinId'])
@Index('ix_transactions_tx_hash', ['txHash'])
@Index('ux_transactions_idempotency_key', ['idempotencyKey'], { unique: true })
@Index('ux_transactions_binance_request_id', ['binanceRequestId'], {
  unique: true,
})
@Index('ix_transactions_provider', ['provider'])
export class TransactionEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  user: UserEntity;

  @Column('uuid')
  coinId: string;

  @ManyToOne(() => CoinEntity, { onDelete: 'RESTRICT' })
  coin: CoinEntity;

  @Column('uuid')
  walletId: string;

  @ManyToOne(() => WalletEntity, { onDelete: 'RESTRICT' })
  wallet: WalletEntity;

  @Column({
    type: 'enum',
    enum: TransactionDirection,
  })
  direction: TransactionDirection;

  @Column({
    type: 'enum',
    enum: TransactionType,
  })
  txType: TransactionType;

  @Column({ type: 'decimal', precision: 36, scale: 18 })
  amount: string;

  @Column({ type: 'decimal', precision: 36, scale: 18, default: 0 })
  fee: string;

  @Column({
    type: 'enum',
    enum: TransactionStatus,
    default: TransactionStatus.PENDING,
  })
  status: TransactionStatus;

  @Column({ type: 'varchar', length: 255 })
  network: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  txHash: string | null;

  @Column({ type: 'int', default: 0 })
  confirmations: number;

  @Column({ type: 'varchar', length: 128 })
  senderAddress: string;

  @Column({ type: 'varchar', length: 128 })
  receiverAddress: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  counterpartyPhone: string | null;

  @Column({ type: 'varchar', length: 64, unique: true })
  idempotencyKey: string;

  @Column({
    type: 'enum',
    enum: TransactionProvider,
    default: TransactionProvider.BINANCE,
  })
  provider: TransactionProvider;

  @Column({ type: 'varchar', length: 128, nullable: true, unique: true })
  binanceRequestId: string | null;

  @Column({
    type: 'enum',
    enum: BinanceTransferType,
    nullable: true,
  })
  binanceTransferType: BinanceTransferType | null;

  @Column({ type: 'text', nullable: true })
  errorMessage: string | null;

  @Column({ type: 'jsonb', nullable: true })
  binanceResponse: any;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

