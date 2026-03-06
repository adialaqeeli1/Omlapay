import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import {
  CoinEntity,
  WalletEntity,
  SwapEntity,
  NotificationEntity,
} from '@common/database/model';
import { BinanceModule } from '@common/services/binance/binance.module';
import { SwapController } from './swap.controller';
import { SwapService } from './swap.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      CoinEntity,
      WalletEntity,
      SwapEntity,
      NotificationEntity,
    ]),
    BinanceModule,
  ],
  controllers: [SwapController],
  providers: [SwapService],
  exports: [SwapService],
})
export class SwapModule {}
