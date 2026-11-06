import { IsString, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDeviceDto {
  @ApiProperty({ description: 'FCM registration token' })
  @IsString()
  @Length(1, 4096)
  device_token: string;

  @ApiProperty({ example: 'iPhone15,2', description: 'Device model' })
  @IsString()
  @Length(1, 100)
  device_model: string;

  @ApiProperty({
    description: 'iOS identifierForVendor or Android build fingerprint',
  })
  @IsString()
  @Length(1, 255)
  device_uuid: string;
}
