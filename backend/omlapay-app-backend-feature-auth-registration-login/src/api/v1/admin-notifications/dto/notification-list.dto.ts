import { IsOptional, IsEnum, IsInt, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { AdminNotificationType } from '@common/database/model';

export class NotificationListDto {
  @ApiProperty({
    description: 'Filter by notification type',
    required: false,
    enum: AdminNotificationType,
    example: AdminNotificationType.USER,
  })
  @IsOptional()
  @IsEnum(AdminNotificationType)
  type?: AdminNotificationType;

  @ApiProperty({
    description: 'Filter by read status',
    required: false,
    example: false,
  })
  @IsOptional()
  @Type(() => Boolean)
  isRead?: boolean;

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
    description: 'Number of notifications per page',
    required: false,
    default: 20,
    example: 20,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}
