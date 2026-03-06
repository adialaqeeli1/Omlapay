import { Module } from '@nestjs/common';
import { BinanceService } from './binance.service';
import { PriceService } from './price.service';
import { DepositAddressService } from './deposit-address.service';
import { WithdrawalService } from './withdrawal.service';
import { TradeService } from './trade.service';
import { ExchangeInfoService } from './exchange-info.service';

@Module({
  providers: [
    BinanceService,
    PriceService,
    DepositAddressService,
    WithdrawalService,
    TradeService,
    ExchangeInfoService,
  ],
  exports: [
    BinanceService,
    PriceService,
    DepositAddressService,
    WithdrawalService,
    TradeService,
    ExchangeInfoService,
  ],
})
export class BinanceModule {}
