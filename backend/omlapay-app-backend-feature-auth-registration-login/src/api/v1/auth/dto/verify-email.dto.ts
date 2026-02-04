import { IsString, IsEmail, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyEmailDto {
  @ApiProperty({ example: 'user@example.com', description: 'Email address' })
  @IsEmail({}, { message: 'Please enter a valid email address.' })
  email: string;

  @ApiProperty({ example: '839201', description: '6-digit verification code' })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'Verification code must be 6 digits' })
  verification_code: string;
}
