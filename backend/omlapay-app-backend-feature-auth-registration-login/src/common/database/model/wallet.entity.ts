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

@Entity('wallets')
@Index('ux_wallets_user_coin', ['userId', 'coinId'], { unique: true })
@Index('ix_wallets_user_id', ['userId'])
export class WalletEntity {
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

  @Column({ type: 'varchar', length: 20 })
  network: string;

  @Column({ type: 'varchar', length: 128 })
  address: string;

  @Column({ type: 'decimal', precision: 36, scale: 18, default: 0 })
  balance: string;

  @Column({ type: 'decimal', precision: 36, scale: 18, default: 0 })
  lockedBalance: string;

  @Column({ type: 'varchar', length: 10, nullable: true })
  binanceWalletType: string | null;

  @Column({ type: 'timestamp', nullable: true })
  lastSyncedAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

