import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

@Entity('coins')
@Index('ux_coins_symbol', ['symbol'], { unique: true })
export class CoinEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 10 })
  symbol: string;

  @Column({ length: 50 })
  name: string;

  @Column({ type: 'int' })
  decimals: number;

  @Column({ type: 'varchar', length: 50, nullable: true })
  network: string | null;

  @Column({ type: 'text', nullable: true })
  iconUrl: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  contractAddress: string | null;

  @Column({ type: 'decimal', precision: 36, scale: 18, nullable: true })
  minWithdrawal: string | null;

  @Column({ type: 'decimal', precision: 36, scale: 18, nullable: true })
  minDeposit: string | null;

  @Column({ type: 'decimal', precision: 36, scale: 18, nullable: true })
  withdrawalFee: string | null;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ type: 'int', default: 0 })
  displayOrder: number;

  @Column({ type: 'varchar', length: 50, nullable: true })
  coinGeckoId: string | null;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

