import {
  IsOptional,
  IsString,
  Matches,
  Length,
  MaxLength,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { DeviceIdField } from './device-id';

/** POST /auth/login/passcode: re-login on a remembered device without a new SMS code */
export class PasscodeLoginDto extends DeviceIdField {
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

  @ApiProperty({ example: '123456', description: '6-digit passcode' })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'Passcode must be 6 digits' })
  passcode: string;

  @ApiProperty({
    description:
      'device_token from POST /auth/login, register/set-passcode or forgot-passcode/reset on this phone. ' +
      'Missing or unknown: 401 DEVICE_NOT_TRUSTED (log in with an SMS code).',
  })
  @IsOptional()
  @IsString()
  @MaxLength(256)
  device_token?: string;
}
