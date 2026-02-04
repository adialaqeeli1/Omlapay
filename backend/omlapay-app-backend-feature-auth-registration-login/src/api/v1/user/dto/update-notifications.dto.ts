import { IsBoolean, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateNotificationsDto {
  @ApiProperty({ example: true })
  @IsBoolean()
  @IsNotEmpty()
  notifications_enabled: boolean;
}
