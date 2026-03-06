import {
  IsOptional,
  IsEnum,
  IsDateString,
  IsInt,
  IsString,
  Min,
  Max,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { SupportRequestStatus } from '@common/database/model';

export enum TicketListSortBy {
  USER = 'user',
  TITLE = 'title',
  CREATED_AT = 'createdAt',
  STATUS = 'status',
}

export enum TicketListSortOrder {
  ASC = 'ASC',
  DESC = 'DESC',
}

export class TicketListDto {
  @ApiProperty({
    description: 'Search by user email, phone, or ticket title',
    required: false,
    example: 'baha.taha@gmail.com',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiProperty({
    description: 'Filter by ticket status',
    required: false,
    enum: SupportRequestStatus,
    example: SupportRequestStatus.OPEN,
  })
  @IsOptional()
  @IsEnum(SupportRequestStatus)
  status?: SupportRequestStatus;

  @ApiProperty({
    description: 'Start date for date range filter (ISO 8601 format)',
    required: false,
    example: '2024-01-01T00:00:00Z',
  })
  @IsOptional()
  @IsDateString()
  fromDate?: string;

  @ApiProperty({
    description: 'End date for date range filter (ISO 8601 format)',
    required: false,
    example: '2024-12-31T23:59:59Z',
  })
  @IsOptional()
  @IsDateString()
  toDate?: string;

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
    description: 'Number of tickets per page',
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

  @ApiProperty({
    description: 'Sort by field',
    required: false,
    enum: TicketListSortBy,
    default: TicketListSortBy.CREATED_AT,
  })
  @IsOptional()
  @IsEnum(TicketListSortBy)
  sortBy?: TicketListSortBy = TicketListSortBy.CREATED_AT;

  @ApiProperty({
    description: 'Sort order',
    required: false,
    enum: TicketListSortOrder,
    default: TicketListSortOrder.DESC,
  })
  @IsOptional()
  @IsEnum(TicketListSortOrder)
  sortOrder?: TicketListSortOrder = TicketListSortOrder.DESC;
}
