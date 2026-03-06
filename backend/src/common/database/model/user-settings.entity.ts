import {
  Entity,
  Column,
  PrimaryColumn,
  OneToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { UserEntity } from './user.entity';

export enum Theme {
  LIGHT = 'light',
  DARK = 'dark',
  SYSTEM = 'system',
}

export enum Language {
  EN = 'en',
  AR = 'ar',
}

/** Display currency for balance and prices (USD or SAR) */
export enum DisplayCurrency {
  USD = 'usd',
  SAR = 'sar',
}

@Entity('user_settings')
export class UserSettingsEntity {
  @PrimaryColumn('uuid')
  userId: string;

  @OneToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: UserEntity;

  @Column({
    type: 'enum',
    enum: Theme,
    default: Theme.LIGHT,
  })
  theme: Theme;

  @Column({
    type: 'enum',
    enum: Language,
    default: Language.AR,
  })
  language: Language;

  @Column({ default: true })
  notificationsEnabled: boolean;

  @Column({ default: false })
  twoFactorEnabled: boolean;

  @Column({ default: false })
  onboardingCompleted: boolean;

  @Column({ default: false })
  onboardingSkipped: boolean;

  @Column({
    type: 'enum',
    enum: DisplayCurrency,
    default: DisplayCurrency.USD,
    nullable: true,
  })
  displayCurrency: DisplayCurrency | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
