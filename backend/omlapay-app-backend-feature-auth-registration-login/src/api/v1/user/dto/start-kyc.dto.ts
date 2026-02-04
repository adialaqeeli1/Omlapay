import { IsString, IsOptional, Matches, MaxLength } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

/** Optional pre-fill for Sumsub applicant fixedInfo (cross-validated with documents). */
export class StartKycDto {
  @ApiPropertyOptional({ example: 'John' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  firstName?: string;

  @ApiPropertyOptional({ example: 'Doe' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  lastName?: string;

  /** ISO 3166-1 alpha-3 (e.g. GBR, USA). Residence / nationality. */
  @ApiPropertyOptional({ example: 'GBR' })
  @IsOptional()
  @IsString()
  @MaxLength(3)
  residentialCountry?: string;

  /** Date of birth, ISO 8601 yyyy-MM-dd. */
  @ApiPropertyOptional({ example: '1990-01-15' })
  @IsOptional()
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'dob must be yyyy-MM-dd' })
  dob?: string;

  /** Document-issuing country, ISO 3166-1 alpha-3. */
  @ApiPropertyOptional({ example: 'GBR' })
  @IsOptional()
  @IsString()
  @MaxLength(3)
  country?: string;

  @ApiPropertyOptional({ example: '123 High Street' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  address?: string;

  @ApiPropertyOptional({ example: 'London' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  city?: string;
}
