import { IsString, IsNotEmpty, IsEmail, IsOptional, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyCurrentEmailDto {
  @ApiProperty({ example: '123456', description: 'OTP sent to current email' })
  @IsString()
  @IsNotEmpty()
  @Length(6, 6)
  otp: string;
}

export class EnterNewEmailDto {
  @ApiProperty({ example: 'newadmin@example.com', description: 'New email address' })
  @IsString()
  @IsNotEmpty()
  @IsEmail()
  newEmail: string;
}

export class VerifyNewEmailDto {
  @ApiProperty({ example: '123456', description: 'OTP sent to new email' })
  @IsString()
  @IsNotEmpty()
  @Length(6, 6)
  otp: string;
}
