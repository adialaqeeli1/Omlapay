import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SystemSettingsEntity } from '@common/database/model';

/** Keys for fee-related system settings */
export const FEE_KEYS = {
  EXTERNAL_TRANSFER_FEE_PERCENT: 'external_transfer_fee_percent',
  SWAP_FEE_PERCENT: 'swap_fee_percent',
} as const;

/** Default fee values (0-10% range) */
export const FEE_DEFAULTS = {
  [FEE_KEYS.EXTERNAL_TRANSFER_FEE_PERCENT]: '0',
  [FEE_KEYS.SWAP_FEE_PERCENT]: '0.1',
} as const;

/** Valid fee range: 0 to 10 percent */
export const FEE_MIN_PERCENT = 0;
export const FEE_MAX_PERCENT = 10;

@Injectable()
export class SystemSettingsService {
  constructor(
    @InjectRepository(SystemSettingsEntity)
    private readonly settingsRepository: Repository<SystemSettingsEntity>,
  ) {}

  /**
   * Get a setting value by key. Returns default if not found.
   */
  async get(key: string, defaultValue: string): Promise<string> {
    const setting = await this.settingsRepository.findOne({
      where: { settingKey: key },
    });
    return setting?.settingValue ?? defaultValue;
  }

  /**
   * Set a setting value. Creates or updates.
   */
  async set(key: string, value: string): Promise<void> {
    const existing = await this.settingsRepository.findOne({
      where: { settingKey: key },
    });
    if (existing) {
      existing.settingValue = value;
      await this.settingsRepository.save(existing);
    } else {
      await this.settingsRepository.save({
        settingKey: key,
        settingValue: value,
      });
    }
  }

  /**
   * Get external transfer fee as decimal (e.g. 0.01 for 1%).
   */
  async getExternalTransferFeePercent(): Promise<number> {
    const raw = await this.get(
      FEE_KEYS.EXTERNAL_TRANSFER_FEE_PERCENT,
      FEE_DEFAULTS[FEE_KEYS.EXTERNAL_TRANSFER_FEE_PERCENT],
    );
    const num = parseFloat(raw);
    return isNaN(num) ? 0 : Math.max(FEE_MIN_PERCENT, Math.min(FEE_MAX_PERCENT, num)) / 100;
  }

  /**
   * Get swap fee as decimal (e.g. 0.001 for 0.1%).
   */
  async getSwapFeePercent(): Promise<number> {
    const raw = await this.get(
      FEE_KEYS.SWAP_FEE_PERCENT,
      FEE_DEFAULTS[FEE_KEYS.SWAP_FEE_PERCENT],
    );
    const num = parseFloat(raw);
    return isNaN(num) ? 0 : Math.max(FEE_MIN_PERCENT, Math.min(FEE_MAX_PERCENT, num)) / 100;
  }

  /**
   * Set external transfer fee. Value must be 0-10 (percent).
   */
  async setExternalTransferFeePercent(percent: number): Promise<void> {
    const clamped = Math.max(FEE_MIN_PERCENT, Math.min(FEE_MAX_PERCENT, percent));
    await this.set(FEE_KEYS.EXTERNAL_TRANSFER_FEE_PERCENT, String(clamped));
  }

  /**
   * Set swap fee. Value must be 0-10 (percent).
   */
  async setSwapFeePercent(percent: number): Promise<void> {
    const clamped = Math.max(FEE_MIN_PERCENT, Math.min(FEE_MAX_PERCENT, percent));
    await this.set(FEE_KEYS.SWAP_FEE_PERCENT, String(clamped));
  }
}
