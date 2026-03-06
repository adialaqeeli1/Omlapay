import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  ValueTransformer,
} from 'typeorm';
import { CryptoUtil } from '../../utils/crypto.util';

/**
 * Transparent AES-256-GCM transformer for sensitive columns.
 * Encrypts on write, decrypts on read. Null values pass through unchanged.
 */
const encryptedColumnTransformer: ValueTransformer = {
  to(value: string | null): string | null {
    if (value === null || value === undefined) return null;
    return CryptoUtil.encryptField(value);
  },
  from(value: string | null): string | null {
    if (value === null || value === undefined) return null;
    try {
      return CryptoUtil.decryptField(value);
    } catch {
      return value;
    }
  },
};

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

  @Column({ type: 'timestamp', nullable: true })
  termsAcceptedAt: Date | null;

  @Column({ type: 'varchar', length: 100, nullable: true, name: 'binance_subaccount_id' })
  binanceSubaccountId: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'binance_subaccount_email' })
  binanceSubaccountEmail: string | null;

  @Column({ type: 'varchar', length: 32, nullable: true, name: 'binance_subaccount_tag' })
  binanceSubaccountTag: string | null;

  @Column({ type: 'varchar', length: 512, nullable: true, name: 'binance_api_key', transformer: encryptedColumnTransformer })
  binanceApiKey: string | null;

  @Column({ type: 'varchar', length: 512, nullable: true, name: 'binance_secret_key', transformer: encryptedColumnTransformer })
  binanceSecretKey: string | null;

  @Column({ type: 'timestamp', nullable: true, name: 'binance_api_key_created_at' })
  binanceApiKeyCreatedAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
