import {
  IsOptional,
  IsString,
  IsInt,
  Min,
  Max,
  IsEnum,
  IsDateString,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

/** Filter for user list: Active/Blocked (legacy). */
export enum UserStatusFilter {
  ACTIVE = 'ACTIVE',
  BLOCKED = 'BLOCKED',
}

/**
 * Tab filter for admin user list UI.
 * - ALL: show all users
 * - KYC: users with at least one approved KYC (e.g. Sumsub)
 * - NON_KYC: users without approved KYC
 * - BLOCKED: users with isActive = false
 */
export enum UserListTabFilter {
  ALL = 'ALL',
  KYC = 'KYC',
  NON_KYC = 'NON_KYC',
  BLOCKED = 'BLOCKED',
}

/** Sort field for user list. */
export enum UserListSortBy {
  CREATED_AT = 'createdAt',
  EMAIL = 'email',
}

/** Sort order. */
export enum UserListSortOrder {
  ASC = 'ASC',
  DESC = 'DESC',
}

export class UserListDto {
  @ApiProperty({
    description: 'Search by email or mobile number',
    required: false,
    example: '501234567',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiProperty({
    description: 'Filter by user status (legacy: ACTIVE | BLOCKED)',
    required: false,
    enum: UserStatusFilter,
    example: UserStatusFilter.ACTIVE,
  })
  @IsOptional()
  @IsEnum(UserStatusFilter)
  status?: UserStatusFilter;

  @ApiProperty({
    description: 'Tab filter: All Users, KYC Users, Non-KYC Users, Blocked Users',
    required: false,
    enum: UserListTabFilter,
    example: UserListTabFilter.ALL,
  })
  @IsOptional()
  @IsEnum(UserListTabFilter)
  filter?: UserListTabFilter;

  @ApiProperty({
    description: 'Filter by created date from (ISO date string)',
    required: false,
    example: '2025-01-01',
  })
  @IsOptional()
  @IsDateString()
  dateFrom?: string;

  @ApiProperty({
    description: 'Filter by created date to (ISO date string)',
    required: false,
    example: '2025-12-31',
  })
  @IsOptional()
  @IsDateString()
  dateTo?: string;

  @ApiProperty({
    description: 'Sort by field',
    required: false,
    enum: UserListSortBy,
    default: UserListSortBy.CREATED_AT,
  })
  @IsOptional()
  @IsEnum(UserListSortBy)
  sortBy?: UserListSortBy = UserListSortBy.CREATED_AT;

  @ApiProperty({
    description: 'Sort order',
    required: false,
    enum: UserListSortOrder,
    default: UserListSortOrder.DESC,
  })
  @IsOptional()
  @IsEnum(UserListSortOrder)
  sortOrder?: UserListSortOrder = UserListSortOrder.DESC;

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
    description: 'Number of users per page',
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
