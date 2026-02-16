import { IsString, IsNotEmpty, IsEmail, MinLength, Matches, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateSuperAdminDto {
  @ApiProperty({
    example: 'superadmin@omlapay.com',
    description: 'Super Admin email address',
  })
  @IsString()
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @ApiProperty({
    example: '+966501234567',
    description: 'Super Admin phone number (optional, supports +91 or +966 formats)',
    required: false,
  })
  @IsOptional()
  @IsString()
  @Matches(/^(\+91\d{10}|\+966\d{9})$/, {
    message: 'Invalid phone number format. Must be India format (+91XXXXXXXXXX) or KSA format (+966XXXXXXXXX)',
  })
  phoneNumber?: string;

  @ApiProperty({
    example: 'SuperAdmin@123',
    description: 'Super Admin password (must meet security requirements)',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/, {
    message:
      'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character',
  })
  password: string;
}
