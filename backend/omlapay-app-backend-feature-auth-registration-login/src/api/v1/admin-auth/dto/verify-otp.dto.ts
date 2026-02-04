import { IsString, IsNotEmpty, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AdminVerifyOtpDto {
  @ApiProperty({
    example: 'admin@example.com',
    description: 'Email or phone number',
  })
  @IsString()
  @IsNotEmpty()
  identifier: string;

  @ApiProperty({ example: '123456', description: '6-digit OTP' })
  @IsString()
  @Length(6, 6)
  otp: string;
}

