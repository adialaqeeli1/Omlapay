import { IsString, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SetPasscodeDto {
  @ApiProperty({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'Registration token from mobile verification',
  })
  @IsString()
  registration_token: string;

  @ApiProperty({ example: '123456', description: '6-digit passcode' })
  @IsString()
  @Length(6, 6, { message: 'Passcode must be exactly 6 digits' })
  @Matches(/^\d{6}$/, { message: 'Passcode must be 6 digits' })
  passcode: string;

  @ApiProperty({ example: '123456', description: 'Confirm passcode' })
  @IsString()
  confirm_passcode: string;
}
