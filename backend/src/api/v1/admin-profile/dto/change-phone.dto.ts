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
  @Matches(/^\+?\d{6,15}$/, {
    message:
      'Invalid phone number format. Use a Saudi mobile number: +9665XXXXXXXX or 05XXXXXXXX',
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
