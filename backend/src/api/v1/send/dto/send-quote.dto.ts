import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsNumber, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class SendQuoteDto {
  @ApiProperty({ example: 'USDT', description: 'Coin symbol to send' })
  @IsNotEmpty()
  @IsString()
  coin: string;

  @ApiProperty({
    example: '+966501234567',
    description: 'Phone number (internal) or wallet address (external)',
  })
  @IsNotEmpty()
  @IsString()
  recipient: string;

  @ApiProperty({ example: '200.5', description: 'Amount to send' })
  @IsNotEmpty()
  @IsNumber()
  @Min(0.000001)
  @Type(() => Number)
  amount: number;
}
