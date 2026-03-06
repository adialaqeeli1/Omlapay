import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UnblockSubaccountDto {
  @ApiProperty({
    example: '367537027503425913',
    description: 'Binance sub-account ID to unblock',
    required: true,
  })
  @IsString()
  @IsNotEmpty({ message: 'subAccountId is required' })
  subAccountId: string;

  @ApiProperty({
    example: 'your-binance-api-key',
    description: 'Binance API key',
    required: true,
  })
  @IsString()
  @IsNotEmpty({ message: 'apiKey is required' })
  apiKey: string;

  @ApiProperty({
    example:
      '-----BEGIN PRIVATE KEY-----\nMC4CAQAwBQYDK2VwBCIEI...\n-----END PRIVATE KEY-----',
    description:
      'Ed25519 or RSA private key in PEM format. When sending via JSON API, use \\n for line breaks.',
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
