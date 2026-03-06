import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsEnum, IsDateString, IsString, Min, Max, IsInt } from 'class-validator';
import { Type } from 'class-transformer';

export enum AdminTransactionType {
  SWAP = 'swap',
  EXTERNAL_TRANSFER = 'external_transfer',
}

export class AdminTransactionListDto {
  @ApiPropertyOptional({ enum: AdminTransactionType })
  @IsOptional()
  @IsEnum(AdminTransactionType)
  transactionType?: AdminTransactionType;

  @ApiPropertyOptional({ example: '2025-01-01' })
  @IsOptional()
  @IsDateString()
  fromDate?: string;

  @ApiPropertyOptional({ example: '2025-01-31' })
  @IsOptional()
  @IsDateString()
  toDate?: string;

  @ApiPropertyOptional({ description: 'Search by sender email' })
  @IsOptional()
  @IsString()
  senderEmail?: string;

  @ApiPropertyOptional({ default: 1, minimum: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ default: 20, minimum: 1, maximum: 100 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}
