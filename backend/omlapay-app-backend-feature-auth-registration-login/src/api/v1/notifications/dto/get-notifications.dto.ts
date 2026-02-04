import { IsOptional, IsEnum, IsInt, Min, Max, IsBoolean, IsString } from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { NotificationType } from '@common/database/model';

export class GetNotificationsDto {
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

  @ApiPropertyOptional({
    description: 'Filter by notification type',
    enum: NotificationType,
  })
  @IsOptional()
  @IsEnum(NotificationType)
  type?: NotificationType;

  @ApiPropertyOptional({
    description: 'Filter by read status',
    type: Boolean,
  })
  @IsOptional()
  @Transform(({ value }) => {
    if (value === 'true') return true;
    if (value === 'false') return false;
    return value;
  })
  @IsBoolean()
  is_read?: boolean;

  @ApiPropertyOptional({
    description: 'Filter notifications from this date (ISO 8601)',
  })
  @IsOptional()
  @Type(() => Date)
  from_date?: Date;

  @ApiPropertyOptional({
    description: 'Filter notifications until this date (ISO 8601)',
  })
  @IsOptional()
  @Type(() => Date)
  to_date?: Date;
}

