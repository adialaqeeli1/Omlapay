import { IsString, Matches, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { DeviceIdField } from './device-id';

/**
 * POST /auth/login: passcode + the token from POST /auth/login/verify-otp (SMS code).
 * Logging in with only a phone number and passcode is POST /auth/login/passcode, which also
 * needs a remembered device_token.
 */
export class LoginDto extends DeviceIdField {
  @ApiProperty({ example: '123456', description: '6-digit passcode' })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'Passcode must be 6 digits' })
  passcode: string;

  @ApiProperty({
    description:
      'Token from POST /auth/login/verify-otp (valid 5 minutes, one login).',
  })
  @IsString()
  @Length(1, 2048)
  otpVerificationToken: string;
}
