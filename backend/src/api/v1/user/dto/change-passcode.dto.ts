import { IsString, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ChangePasscodeDto {
  @ApiProperty({ example: '135790', description: 'Current 6-digit passcode' })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'Passcode must be 6 digits' })
  current_passcode: string;

  @ApiProperty({ example: '246813', description: 'New 6-digit passcode' })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'Passcode must be 6 digits' })
  new_passcode: string;

  @ApiProperty({ example: '246813', description: 'New passcode again' })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'Passcode must be 6 digits' })
  confirm_passcode: string;
}
