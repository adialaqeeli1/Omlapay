import { IsString, IsEmail } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class EmailVerificationRequestDto {
  @ApiProperty({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'Registration token from mobile verification',
  })
  @IsString()
  registration_token: string;

  @ApiProperty({
    example: 'user@example.com',
    description: 'Email address to verify',
  })
  @IsEmail({}, { message: 'Please enter a valid email address.' })
  email: string;
}
