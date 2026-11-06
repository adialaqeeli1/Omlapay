import { IsString, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RequestDeletionDto {
  @ApiProperty({
    example: '123456',
    description: 'Passcode, to confirm the deletion',
  })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'Passcode must be 6 digits' })
  passcode: string;
}
