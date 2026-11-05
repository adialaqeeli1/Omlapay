import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsEmail, Matches } from 'class-validator';

export class Enable2FARequestDto {
  @ApiProperty({
    description:
      'Country code with + prefix. Only +966 (Saudi Arabia) by default (ALLOWED_PHONE_COUNTRY_CODES)',
    example: '+966',
  })
  @IsNotEmpty()
  @IsString()
  @Matches(/^\+?\d{1,4}$/, { message: 'Invalid country code.' })
  country_code: string;

  @ApiProperty({
    description:
      'Saudi mobile number: 5XXXXXXXX or 05XXXXXXXX (9665XXXXXXXX and +9665XXXXXXXX also accepted)',
    example: '512345678',
  })
  @IsNotEmpty()
  @IsString()
  // Format only; the Saudi-only rule and normalization (05…, 5…, 9665…, +9665…) are in the service
  @Matches(/^\+?\d{6,15}$/, { message: 'Invalid mobile number.' })
  mobile_number: string;

  @ApiProperty({
    description: 'Email address',
    example: 'user@example.com',
  })
  @IsNotEmpty()
  @IsEmail()
  email: string;
}

