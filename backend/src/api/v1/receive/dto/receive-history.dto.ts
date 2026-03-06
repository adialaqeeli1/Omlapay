import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsIn, IsInt, Min, Max, IsString } from 'class-validator';
import { Type } from 'class-transformer';
import { ASSET_FILTERS } from '@common/constants';

export class ReceiveHistoryQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by asset (ALL, USDC, USDT, BTC, ETH, BNB, SOL)',
    enum: ASSET_FILTERS,
    default: 'ALL',
  })
  @IsOptional()
  @IsIn(ASSET_FILTERS)
  asset?: string = 'ALL';

  @ApiPropertyOptional({
    description: 'Base64 encoded cursor for pagination (load more)',
    example: 'eyJpZCI6IjEyMzQ1Njc4IiwidGltZXN0YW1wIjoiMjAyNi0wMS0wMVQxMDowMDowMFoifQ==',
  })
  @IsOptional()
  @IsString()
  after?: string;

  @ApiPropertyOptional({
    description: 'Number of items to load',
    default: 20,
    minimum: 1,
    maximum: 100,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}
