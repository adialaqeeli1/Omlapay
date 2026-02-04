import { IsString, Matches, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyOtpDto {
  @ApiProperty({ example: '+966', description: 'Country code with + prefix' })
  @IsString()
  @Matches(/^\+966$/, { message: 'Invalid country code' })
  country_code: string;

  @ApiProperty({
    example: '512345678',
    description: 'Mobile number without country code',
  })
  @IsString()
  @Length(9, 9)
  @Matches(/^\d{9}$/, { message: 'Mobile number must be 9 digits' })
  mobile_number: string;

  @ApiProperty({ example: '654321', description: '6-digit OTP code' })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'OTP must be 6 digits' })
  otp: string;
}
