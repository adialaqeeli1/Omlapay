import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class SendResendOtpDto {
  @ApiProperty({
    example: '550e8400-e29b-41d4-a716-446655440000',
    description: 'Send token from initiate response',
  })
  @IsNotEmpty()
  @IsString()
  sendToken: string;
}
