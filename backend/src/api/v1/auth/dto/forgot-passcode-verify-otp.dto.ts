import { IsString, Matches, Length, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ForgotPasscodeVerifyOtpDto {
  @ApiProperty({ example: '+966', description: 'Country code with + prefix. Allowed: +966 (SA), +91 (IN)' })
  @IsString()
  @Matches(/^\+(966|91)$/, { message: 'Invalid country code. Allowed: +966, +91' })
  country_code: string;

  @ApiProperty({
    example: '512345678',
    description: 'Mobile number without country code (9 digits for +966, 10 digits for +91)',
  })
  @IsString()
  @Length(9, 10)
  @Matches(/^\d{9,10}$/, { message: 'Phone number must be 10 digits long.' })
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
