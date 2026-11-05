import {
  IsString,
  Matches,
  Length,
  IsOptional,
  ValidateIf,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

// Two ways to log in:
// - otpVerificationToken (from POST /auth/login/verify-otp) + passcode: the app's login flow
// - country_code + mobile_number + passcode: older app versions and POST /auth/login/passcode
const withoutToken = (o: LoginDto) => !o.otpVerificationToken;

export class LoginDto {
  @ApiProperty({
    required: false,
    example: '+966',
    description:
      'Country code with + prefix. Only +966 (Saudi Arabia) by default (ALLOWED_PHONE_COUNTRY_CODES)',
  })
  @ValidateIf(withoutToken)
  @IsString()
  @Matches(/^\+?\d{1,4}$/, { message: 'Invalid country code.' })
  country_code?: string;

  @ApiProperty({
    required: false,
    example: '512345678',
    description:
      'Saudi mobile number: 5XXXXXXXX or 05XXXXXXXX (9665XXXXXXXX and +9665XXXXXXXX also accepted)',
  })
  @ValidateIf(withoutToken)
  @IsString()
  // Format only; the Saudi-only rule and normalization (05…, 5…, 9665…, +9665…) are in the service
  @Matches(/^\+?\d{6,15}$/, { message: 'Invalid mobile number.' })
  mobile_number?: string;

  @ApiProperty({ example: '123456', description: '6-digit passcode' })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'Passcode must be 6 digits' })
  passcode: string;

  @ApiProperty({
    required: false,
    description:
      'Token from POST /auth/login/verify-otp (valid 5 minutes, one login). Replaces country_code and mobile_number.',
  })
  @IsOptional()
  @IsString()
  @Length(1, 2048)
  otpVerificationToken?: string;
}
