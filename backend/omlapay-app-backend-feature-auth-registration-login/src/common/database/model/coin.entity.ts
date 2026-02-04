import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
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

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;
}

