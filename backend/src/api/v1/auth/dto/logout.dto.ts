import { IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LogoutDto {
  @ApiProperty({
    required: false,
    description:
      "This phone's push-notification (FCM) token, so it stops receiving notifications",
  })
  @IsOptional()
  @IsString()
  @MaxLength(4096)
  device_token?: string;
}
