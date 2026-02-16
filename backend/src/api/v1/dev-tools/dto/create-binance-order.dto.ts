import { IsString, IsNotEmpty, IsOptional, IsIn } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateBinanceOrderDto {
  @ApiProperty({
    example: 'BTCUSDT',
    description: 'Trading pair symbol',
    required: true,
  })
  @IsString()
  @IsNotEmpty({ message: 'symbol is required' })
  symbol: string;

  @ApiProperty({
    example: 'SELL',
    description: 'Order side',
    enum: ['BUY', 'SELL'],
    required: false,
  })
  @IsOptional()
  @IsIn(['BUY', 'SELL'], { message: 'side must be either BUY or SELL' })
  side?: 'BUY' | 'SELL';

  @ApiProperty({
    example: 'LIMIT',
    description: 'Order type',
    enum: ['LIMIT', 'MARKET'],
    required: false,
  })
  @IsOptional()
  @IsIn(['LIMIT', 'MARKET'], { message: 'type must be either LIMIT or MARKET' })
  type?: 'LIMIT' | 'MARKET';

  @ApiProperty({
    example: 'GTC',
    description: 'Time in force',
    required: false,
  })
  @IsOptional()
  @IsString()
  timeInForce?: string;

  @ApiProperty({
    example: '1.0000000',
    description: 'Order quantity',
    required: false,
  })
  @IsOptional()
  @IsString()
  quantity?: string;

  @ApiProperty({
    example: '50000.00',
    description: 'Order price (required for LIMIT orders)',
    required: false,
  })
  @IsOptional()
  @IsString()
  price?: string;
}
