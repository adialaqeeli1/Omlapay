import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateBinanceSubaccountDto {
  @ApiProperty({
    example: 'your-binance-api-key',
    description: 'Binance API key',
    required: true,
  })
  @IsString()
  @IsNotEmpty({ message: 'apiKey is required' })
  apiKey: string;

  @ApiProperty({
    example: '-----BEGIN PRIVATE KEY-----\nMC4CAQAwBQYDK2VwBCIEI...\n-----END PRIVATE KEY-----',
    description: 'Ed25519 private key in PKCS#8 PEM format. Must start with "-----BEGIN PRIVATE KEY-----" and end with "-----END PRIVATE KEY-----". IMPORTANT: When sending via JSON API, use \\n for line breaks (e.g., "-----BEGIN PRIVATE KEY-----\\nMC4CAQA...\\n-----END PRIVATE KEY-----"). Copy the entire key from your file including all lines.',
    required: true,
  })
  @IsString()
  @IsNotEmpty({ message: 'privateKey is required' })
  privateKey: string;

  @ApiProperty({
    example: 'https://api.binance.com',
    description: 'Binance API base URL',
    required: false,
    default: 'https://api.binance.com',
  })
  @IsOptional()
  @IsString()
  baseUrl?: string;

  @ApiProperty({
    example: '5000',
    description: 'Receive window in milliseconds',
    required: false,
  })
  @IsOptional()
  @IsString()
  recvWindow?: string;
}
