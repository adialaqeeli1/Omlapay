import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AddTicketResponseDto {
  @ApiProperty({
    example: 'Thank you for your inquiry. We have resolved your issue.',
    description: 'Admin response message (will be sent to user via email)',
  })
  @IsString()
  @IsNotEmpty()
  message: string;
}
