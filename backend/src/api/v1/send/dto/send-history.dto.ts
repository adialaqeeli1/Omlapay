import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsIn, IsInt, IsString, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';
import { ASSET_FILTERS } from '@common/constants';

export class SendHistoryQueryDto {
  @ApiPropertyOptional({
    enum: ASSET_FILTERS,
    default: 'ALL',
  })
  @IsOptional()
  @IsIn(ASSET_FILTERS)
  asset?: string = 'ALL';

  @ApiPropertyOptional({ description: 'Cursor for pagination (transaction id)' })
  @IsOptional()
  @IsString()
  after?: string;

  @ApiPropertyOptional({ default: 20, minimum: 1, maximum: 50 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(50)
  @Type(() => Number)
  limit?: number = 20;
}
