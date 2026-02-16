import { IsString, IsNotEmpty, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ForgotPasswordDto {
  @ApiProperty({
    example: 'admin@example.com',
    description: 'Email or mobile number (supports: email, +9665XXXXXXXX, 05XXXXXXXX, +91XXXXXXXXXX, or 10-digit Indian mobile)',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(
    /^([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|(\+966[5][0-9]{8})|05[0-9]{8}|(\+91[6-9]\d{9})|[6-9]\d{9})$/,
    {
      message:
        'Must be a valid email, or Saudi mobile number (+966 or 05). Landlines are not supported.',
    },
  )
  identifier: string;
}

