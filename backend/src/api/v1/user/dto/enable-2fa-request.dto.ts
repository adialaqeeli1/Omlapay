import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsEmail, Matches, Length } from 'class-validator';

export class Enable2FARequestDto {
  @ApiProperty({
    description: 'Country code with + prefix',
    example: '+966',
  })
  @IsNotEmpty()
  @IsString()
  @Matches(/^\+966$/, { message: 'Invalid country code' })
  country_code: string;

  @ApiProperty({
    description: 'Mobile number without country code',
    example: '512345678',
  })
  @IsNotEmpty()
  @IsString()
  @Length(9, 9)
  @Matches(/^\d{9}$/, { message: 'Mobile number must be 9 digits' })
  mobile_number: string;

  @ApiProperty({
    description: 'Email address',
    example: 'user@example.com',
  })
  @IsNotEmpty()
  @IsEmail()
  email: string;
}

