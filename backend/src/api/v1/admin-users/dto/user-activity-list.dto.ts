import { IsOptional, IsEnum, IsInt, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

/**
 * Wallet type filter for admin user activity (transactions + swaps).
 * Maps to transaction network values: ETH/BNB→EVM, BTC→BITCOIN, TRX→TRON, SOL→SOLANA.
 */
export enum WalletTypeFilter {
  EVM = 'EVM',
  BITCOIN = 'BITCOIN',
  TRON = 'TRON',
  SOLANA = 'SOLANA',
}

/**
 * Activity type filter: transactions only, swaps only, or both combined.
 */
export enum ActivityTypeFilter {
  TRANSACTION = 'TRANSACTION',
  SWAP = 'SWAP',
  ALL = 'ALL',
}

export class UserActivityListDto {
  @ApiProperty({
    description: 'Filter by activity type: transactions, swaps, or both',
    required: false,
    enum: ActivityTypeFilter,
    default: ActivityTypeFilter.ALL,
  })
  @IsOptional()
  @IsEnum(ActivityTypeFilter)
  type?: ActivityTypeFilter = ActivityTypeFilter.ALL;

  @ApiProperty({
    description:
      'Filter by wallet/network type (applies to transactions when type is TRANSACTION or ALL)',
    required: false,
    enum: WalletTypeFilter,
  })
  @IsOptional()
  @IsEnum(WalletTypeFilter)
  walletType?: WalletTypeFilter;

  @ApiProperty({
    description: 'Page number (1-based)',
    required: false,
    default: 1,
    example: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiProperty({
    description: 'Items per page',
    required: false,
    default: 10,
    example: 10,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 10;
}
