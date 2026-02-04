import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ForgotPasswordDto {
  @ApiProperty({
    example: 'admin@example.com',
    description: 'Email or phone number',
  })
  @IsString()
  @IsNotEmpty()
  identifier: string;
}

