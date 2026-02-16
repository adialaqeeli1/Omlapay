import { IsString, Matches, Length, IsBoolean } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterRequestDto {
  @ApiProperty({ example: '+966', description: 'Country code with + prefix. Allowed: +966 (SA), +91 (IN)' })
  @IsString()
  @Matches(/^\+(966|91)$/, { message: 'Invalid country code. Allowed: +966, +91' })
  country_code: string;

  @ApiProperty({
    example: '512345678',
    description: 'Mobile number without country code (9 digits for +966, 10 digits for +91)',
  })
  @IsString()
  @Length(9, 10)
  @Matches(/^\d{9,10}$/, { message: 'Phone number must be 10 digits long.' })
  mobile_number: string;

  @ApiProperty({
    example: true,
    description: 'User must accept Terms & Conditions and Privacy Policy',
  })
  @IsBoolean()
  terms_accepted: boolean;
}
