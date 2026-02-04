import { IsString, IsNotEmpty, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyCurrentPhoneDto {
  @ApiProperty({ example: '123456', description: 'OTP sent to current phone number' })
  @IsString()
  @IsNotEmpty()
  @Length(6, 6)
  otp: string;
}

export class EnterNewPhoneDto {
  @ApiProperty({
    example: '+966501234567',
    description: 'New phone number (KSA format with country code)',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+966\d{9}$/, {
    message: 'Invalid phone number format. Must be KSA format: +966XXXXXXXXX',
  })
  newPhoneNumber: string;
}

export class VerifyNewPhoneDto {
  @ApiProperty({ example: '123456', description: 'OTP sent to new phone number' })
  @IsString()
  @IsNotEmpty()
  @Length(6, 6)
  otp: string;
}
