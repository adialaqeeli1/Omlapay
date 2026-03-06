import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsIn, IsNumber, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { SUPPORTED_COINS } from '@common/constants';

const VALID_COINS = [...SUPPORTED_COINS];

export class SwapQuoteDto {
  @ApiProperty({ example: 'USDT', description: 'From coin symbol' })
  @IsNotEmpty()
  @IsString()
  @IsIn(VALID_COINS)
  fromCoin: string;

  @ApiProperty({ example: 'BTC', description: 'To coin symbol' })
  @IsNotEmpty()
  @IsString()
  @IsIn(VALID_COINS)
  toCoin: string;

  @ApiProperty({ example: '100', description: 'Amount to swap (from coin)' })
  @IsNotEmpty()
  @IsNumber()
  @Min(0.000001)
  @Type(() => Number)
  amount: number;
}
