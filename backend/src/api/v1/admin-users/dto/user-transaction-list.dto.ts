import { IsOptional, IsEnum, IsInt, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { WalletTypeFilter } from './user-activity-list.dto';

export class UserTransactionListDto {
  @ApiProperty({
    description:
      'Filter by wallet/network type (EVM, Bitcoin, Tron, Solana)',
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
