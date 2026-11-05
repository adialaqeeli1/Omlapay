import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoinsController } from './coins.controller';
import { CoinsService } from './coins.service';
import { CoinEntity } from '@common/database/model';
import { BinanceModule } from '@common/services/binance/binance.module';
import { AdminAuthModule } from '../admin-auth/admin-auth.module';

@Module({
  // AdminAuthModule provides AdminJwtAuthGuard for POST /coins/sync
  imports: [
    TypeOrmModule.forFeature([CoinEntity]),
    BinanceModule,
    AdminAuthModule,
  ],
  controllers: [CoinsController],
  providers: [CoinsService],
  exports: [CoinsService],
})
export class CoinsModule {}

