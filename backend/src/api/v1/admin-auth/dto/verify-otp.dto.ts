import { IsString, IsNotEmpty, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AdminVerifyOtpDto {
  @ApiProperty({
    example: 'admin@example.com',
    description:
      'Email or Saudi mobile number (email, +9665XXXXXXXX, 9665XXXXXXXX, 05XXXXXXXX or 5XXXXXXXX)',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|\+?\d{6,15})$/, {
    message:
      'Must be a valid email or Saudi mobile number (05XXXXXXXX or +9665XXXXXXXX).',
  })
  identifier: string;

  @ApiProperty({ example: '123456', description: '6-digit OTP' })
  @IsString()
  @Length(6, 6)
  otp: string;
}

