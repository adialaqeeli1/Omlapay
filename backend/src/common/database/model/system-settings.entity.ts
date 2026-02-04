import {
  Entity,
  Column,
  PrimaryColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('system_settings')
export class SystemSettingsEntity {
  @PrimaryColumn({ type: 'varchar', length: 100, name: 'setting_key' })
  settingKey: string;

  @Column({ type: 'text', name: 'setting_value' })
  settingValue: string;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
