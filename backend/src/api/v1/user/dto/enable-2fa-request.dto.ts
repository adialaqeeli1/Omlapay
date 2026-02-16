import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsEmail, Matches, Length } from 'class-validator';

export class Enable2FARequestDto {
  @ApiProperty({
    description: 'Country code with + prefix. Allowed: +966 (SA), +91 (IN)',
    example: '+966',
  })
  @IsNotEmpty()
  @IsString()
  @Matches(/^\+(966|91)$/, { message: 'Invalid country code. Allowed: +966, +91' })
  country_code: string;

  @ApiProperty({
    description: 'Mobile number without country code (9 digits for +966, 10 digits for +91)',
    example: '512345678',
  })
  @IsNotEmpty()
  @IsString()
  @Length(9, 10)
  @Matches(/^\d{9,10}$/, { message: 'Phone number must be 10 digits long.' })
  mobile_number: string;

  @ApiProperty({
    description: 'Email address',
    example: 'user@example.com',
  })
  @IsNotEmpty()
  @IsEmail()
  email: string;
}

