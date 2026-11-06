import { IsEmail, IsString, Length, Matches, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class EmailRequestDto {
  @ApiProperty({ example: 'name@example.com' })
  @IsEmail({}, { message: 'Invalid email format.' })
  @MaxLength(255)
  email: string;
}

export class EmailVerifyDto {
  @ApiProperty({
    example: '123456',
    description: '6-digit code from the email',
  })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'OTP must be 6 digits' })
  otp: string;
}
