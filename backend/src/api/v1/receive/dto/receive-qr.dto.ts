import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsNotEmpty, IsOptional } from 'class-validator';

const VALID_NETWORKS = ['TRX', 'BTC', 'ETH', 'BNB', 'SOL'];
const VALID_COINS = ['USDT', 'USDC', 'BTC', 'ETH', 'BNB', 'SOL'];

export class ReceiveQrQueryDto {
  @ApiProperty({ description: 'Blockchain network (TRX, BTC, ETH, BNB, SOL)' })
  @IsNotEmpty()
  @IsIn(VALID_NETWORKS)
  network: string;

  @ApiProperty({ description: 'Coin symbol (USDT, USDC, BTC, ETH, BNB, SOL)' })
  @IsNotEmpty()
  @IsIn(VALID_COINS)
  coin: string;

  @ApiPropertyOptional({
    description: 'Output format: png or svg',
    default: 'png',
  })
  @IsOptional()
  @IsIn(['png', 'svg'])
  format?: 'png' | 'svg' = 'png';
}
