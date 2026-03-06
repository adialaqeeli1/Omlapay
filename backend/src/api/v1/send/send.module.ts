import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import {
  UserEntity,
  UserKycEntity,
  CoinEntity,
  WalletEntity,
  TransactionEntity,
  OtpRequestEntity,
  SendPendingRequestEntity,
  NotificationEntity,
} from '@common/database/model';
import { BinanceModule } from '@common/services/binance/binance.module';
import { OtpModule } from '@common/services/otp/otp.module';
import { SendController } from './send.controller';
import { SendService } from './send.service';
import { SendQuoteUseCase } from './use-cases/send-quote.use-case';
import { SendHistoryUseCase } from './use-cases/send-history.use-case';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      UserKycEntity,
      CoinEntity,
      WalletEntity,
      TransactionEntity,
      OtpRequestEntity,
      SendPendingRequestEntity,
      NotificationEntity,
    ]),
    BinanceModule,
    OtpModule,
  ],
  controllers: [SendController],
  providers: [SendService, SendQuoteUseCase, SendHistoryUseCase],
  exports: [SendService],
})
export class SendModule {}
