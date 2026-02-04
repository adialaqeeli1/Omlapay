import { IsString, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ResetPasscodeDto {
  @ApiProperty({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'Reset token from OTP verification',
  })
  @IsString()
  reset_token: string;

  @ApiProperty({ example: '654321', description: '6-digit new passcode' })
  @IsString()
  @Length(6, 6, { message: 'New passcode must be exactly 6 digits' })
  @Matches(/^\d{6}$/, {
    message: 'New passcode must be a 6-digit number',
  })
  new_passcode: string;

  @ApiProperty({ example: '654321', description: 'Confirm new passcode' })
  @IsString()
  confirm_passcode: string;
}
