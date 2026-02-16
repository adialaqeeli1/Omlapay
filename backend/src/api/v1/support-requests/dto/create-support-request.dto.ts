import { IsString, IsNotEmpty, IsOptional, MaxLength, Matches } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateSupportRequestDto {
  @ApiProperty({
    description: 'Title of the support request',
    example: 'Unable to complete transaction',
    maxLength: 255,
  })
  @IsString()
  @IsNotEmpty({ message: 'Title is required.' })
  @MaxLength(255, { message: 'Title must not exceed 255 characters.' })
  title: string;

  @ApiProperty({
    description: 'Detailed description of the support request',
    example: 'I am unable to complete a transaction. The app shows an error when I try to send USDT.',
  })
  @IsString()
  @IsNotEmpty({ message: 'Description is required.' })
  description: string;

  @ApiPropertyOptional({
    description: 'Comma-separated URLs of attached files (PNG, JPG, PDF only)',
    example: 'https://example.com/file1.png,https://example.com/file2.pdf',
  })
  @IsOptional()
  @IsString()
  @Matches(
    /^(https?:\/\/[^\s,]+(\.(png|jpg|jpeg|pdf)))(,https?:\/\/[^\s,]+(\.(png|jpg|jpeg|pdf)))*$/i,
    {
      message: 'Invalid file format. Please upload PNG, JPG, or PDF only.',
    },
  )
  attachmentUrl?: string;
}
