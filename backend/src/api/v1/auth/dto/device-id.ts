import { IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

/** Optional device identifier the app sends with device-token requests */
export class DeviceIdField {
  @ApiProperty({
    required: false,
    example: 'A1:B2:C3:D4:E5:F6',
    description:
      'Device identifier. A device_token issued with one is accepted only with the same value.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(128)
  device_id?: string;
}
