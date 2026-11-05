import { IsString, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ForgotPasscodeResendOtpDto {
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
}
