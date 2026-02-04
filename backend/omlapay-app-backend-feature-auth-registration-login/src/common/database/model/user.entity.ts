import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

@Entity('users')
@Index('ux_users_full_mobile', ['fullMobileNumber'], { unique: true })
@Index('ux_users_email', ['email'], { unique: true })
@Index('ix_users_created_at', ['createdAt'])
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 5 })
  countryCode: string;

  @Column({ length: 15 })
  mobileNumber: string;

  @Column({ length: 20 })
  fullMobileNumber: string;

  @Column({ type: 'text', nullable: true })
  profileImageUrl: string | null;

  @Column({ type: 'timestamp', nullable: true })
  profileImageUpdatedAt: Date | null;

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: false })
  isMobileVerified: boolean;

  @Column({ type: 'timestamp', nullable: true })
  mobileVerifiedAt: Date | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  email: string | null;

  @Column({ default: false })
  isEmailVerified: boolean;

  @Column({ type: 'timestamp', nullable: true })
  emailVerifiedAt: Date | null;

  @Column({ type: 'varchar', length: 100, nullable: true, name: 'binance_subaccount_id' })
  binanceSubaccountId: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'binance_subaccount_email' })
  binanceSubaccountEmail: string | null;

  @Column({ type: 'varchar', length: 32, nullable: true, name: 'binance_subaccount_tag' })
  binanceSubaccountTag: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'binance_api_key' })
  binanceApiKey: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'binance_secret_key' })
  binanceSecretKey: string | null;

  @Column({ type: 'timestamp', nullable: true, name: 'binance_api_key_created_at' })
  binanceApiKeyCreatedAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
