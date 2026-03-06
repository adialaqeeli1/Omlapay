import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsOptional,
  IsIn,
  IsInt,
  IsDateString,
  Min,
  Max,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ASSET_FILTERS } from '@common/constants';

export class HistoryQueryDto {
  @ApiPropertyOptional({
    enum: ASSET_FILTERS,
    default: 'ALL',
  })
  @IsOptional()
  @IsIn(ASSET_FILTERS)
  asset?: string = 'ALL';

  @ApiPropertyOptional({
    enum: ['ALL', 'SENT', 'RECEIVE'],
    default: 'ALL',
  })
  @IsOptional()
  @IsIn(['ALL', 'SENT', 'RECEIVE'])
  type?: string = 'ALL';

  @ApiPropertyOptional({
    description: 'Start date (YYYY-MM-DD). Max range 12 months.',
    example: '2024-01-01',
  })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({
    description: 'End date (YYYY-MM-DD). Must be >= startDate.',
    example: '2024-12-31',
  })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Cursor for pagination' })
  @IsOptional()
  after?: string;

  @ApiPropertyOptional({ default: 50, minimum: 1, maximum: 50 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(50)
  @Type(() => Number)
  limit?: number = 50;
}
