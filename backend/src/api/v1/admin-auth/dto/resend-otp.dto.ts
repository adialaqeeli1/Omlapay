import { IsString, IsNotEmpty, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AdminResendOtpDto {
  @ApiProperty({
    example: 'admin@example.com',
    description:
      'Email or Saudi mobile number (email, +9665XXXXXXXX, 9665XXXXXXXX, 05XXXXXXXX or 5XXXXXXXX)',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|\+?\d{6,15})$/, {
    message:
      'Must be a valid email or Saudi mobile number (05XXXXXXXX or +9665XXXXXXXX).',
  })
  identifier: string;
}

