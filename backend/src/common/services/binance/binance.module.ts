import { Module } from '@nestjs/common';
import { BinanceService } from './binance.service';
import { PriceService } from './price.service';

@Module({
  providers: [BinanceService, PriceService],
  exports: [BinanceService, PriceService],
})
export class BinanceModule {}
