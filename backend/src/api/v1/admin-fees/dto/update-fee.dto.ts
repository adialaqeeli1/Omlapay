import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNumber, Min, Max, IsString } from 'class-validator';

export enum FeeType {
  EXTERNAL_TRANSFER = 'external_transfer',
  SWAP = 'swap',
}

export class InitiateFeeUpdateDto {
  @ApiProperty({ enum: FeeType, description: 'Fee type to update' })
  @IsEnum(FeeType)
  feeType: FeeType;

  @ApiProperty({ minimum: 0, maximum: 10, description: 'Fee percentage (0-10)' })
  @IsNumber()
  @Min(0)
  @Max(10)
  value: number;
}

export class ConfirmFeeUpdateDto {
  @ApiProperty({ description: 'OTP received via email' })
  otp: string;

  @ApiProperty({ enum: FeeType, description: 'Fee type being updated' })
  @IsEnum(FeeType)
  feeType: FeeType;

  @ApiProperty({ minimum: 0, maximum: 10, description: 'Fee percentage (0-10)' })
  @IsNumber()
  @Min(0)
  @Max(10)
  value: number;
}
