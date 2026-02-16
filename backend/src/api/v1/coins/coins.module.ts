import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoinsController } from './coins.controller';
import { CoinsService } from './coins.service';
import { CoinEntity } from '@common/database/model';
import { BinanceModule } from '@common/services/binance/binance.module';

@Module({
  imports: [TypeOrmModule.forFeature([CoinEntity]), BinanceModule],
  controllers: [CoinsController],
  providers: [CoinsService],
  exports: [CoinsService],
})
export class CoinsModule {}

