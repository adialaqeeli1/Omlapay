import { IsString, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SoftLoginDto {
  @ApiProperty({ example: '123456', description: '6-digit passcode' })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'Passcode must be 6 digits' })
  passcode: string;
}
