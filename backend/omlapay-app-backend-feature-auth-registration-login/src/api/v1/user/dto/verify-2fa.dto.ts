import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, Length } from 'class-validator';

export class Verify2FADto {
  @ApiProperty({
    description: '6-digit SMS verification code',
    example: '123456',
  })
  @IsNotEmpty()
  @IsString()
  @Length(6, 6)
  mobile_otp: string;

  @ApiProperty({
    description: '6-digit email verification code',
    example: '654321',
  })
  @IsNotEmpty()
  @IsString()
  @Length(6, 6)
  email_otp: string;
}

