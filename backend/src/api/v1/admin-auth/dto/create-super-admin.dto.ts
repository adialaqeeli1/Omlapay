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
    description:
      'Super Admin phone number (optional, Saudi mobile: +9665XXXXXXXX or 05XXXXXXXX)',
    required: false,
  })
  @IsOptional()
  @IsString()
  @Matches(/^\+?\d{6,15}$/, {
    message:
      'Invalid phone number format. Use a Saudi mobile number: +9665XXXXXXXX or 05XXXXXXXX',
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
