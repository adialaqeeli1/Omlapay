import { IsString, Matches, Length, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ForgotPasscodeVerifyOtpDto {
  @ApiProperty({
    example: '+966',
    description:
      'Country code with + prefix. Only +966 (Saudi Arabia) by default (ALLOWED_PHONE_COUNTRY_CODES)',
  })
  @IsString()
  @Matches(/^\+?\d{1,4}$/, { message: 'Invalid country code.' })
  country_code: string;

  @ApiProperty({
    example: '512345678',
    description:
      'Saudi mobile number: 5XXXXXXXX or 05XXXXXXXX (9665XXXXXXXX and +9665XXXXXXXX also accepted)',
  })
  @IsString()
  // Format only; the Saudi-only rule and normalization (05…, 5…, 9665…, +9665…) are in the service
  @Matches(/^\+?\d{6,15}$/, { message: 'Invalid mobile number.' })
  mobile_number: string;

  @ApiProperty({
    example: '458921',
    description:
      '6-digit mobile OTP (always required, whether 2FA is enabled or not)',
    required: false,
  })
  @IsOptional()
  @IsString()
  @Length(6, 6, { message: 'Mobile OTP must be 6 digits' })
  @Matches(/^\d{6}$/, { message: 'Mobile OTP must contain only digits' })
  mobile_otp?: string;

  @ApiProperty({
    example: '839201',
    description: '6-digit email OTP (required only if 2FA is enabled)',
    required: false,
  })
  @IsOptional()
  @IsString()
  @Length(6, 6, { message: 'Email OTP must be 6 digits' })
  @Matches(/^\d{6}$/, { message: 'Email OTP must contain only digits' })
  email_otp?: string;
}
