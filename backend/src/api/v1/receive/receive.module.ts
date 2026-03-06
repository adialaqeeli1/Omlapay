import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import {
  CoinEntity,
  TransactionEntity,
  WalletEntity,
} from '@common/database/model';
import { ReceiveController } from './receive.controller';
import { ReceiveService } from './receive.service';
import { BinanceModule } from '@common/services/binance/binance.module';
import { jwtConfig } from '@common/config/jwt.config';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      CoinEntity,
      TransactionEntity,
      WalletEntity,
    ]),
    JwtModule.registerAsync(jwtConfig('7d')),
    BinanceModule,
  ],
  controllers: [ReceiveController],
  providers: [ReceiveService],
  exports: [ReceiveService],
})
export class ReceiveModule {}
