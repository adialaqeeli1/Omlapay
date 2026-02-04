import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class BlockUserDto {
  @ApiProperty({
    example: 'Suspicious activity detected',
    description: 'Reason for blocking the user (will be sent via email)',
  })
  @IsString()
  @IsNotEmpty()
  reason: string;
}
