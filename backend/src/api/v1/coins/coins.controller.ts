import {
  Controller,
  Get,
  Post,
  HttpCode,
  HttpStatus,
  Query,
  Param,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery, ApiParam } from '@nestjs/swagger';
import { CoinsService } from './coins.service';
import { Currency } from '@common/services/binance/price.service';

@ApiTags('Coins')
@Controller({ path: 'coins', version: '1' })
export class CoinsController {
  constructor(private readonly coinsService: CoinsService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get all supported coins with optional prices (public endpoint)',
    description:
      'Returns list of supported coins. Optionally include prices by specifying currency parameter (USD or SAR).',
  })
  @ApiQuery({
    name: 'currency',
    required: false,
    enum: Currency,
    description: 'Currency for coin prices (USD or SAR). If not provided, prices are not included.',
    example: Currency.USD,
  })
  @ApiResponse({
    status: 200,
    description: 'Supported coins retrieved successfully',
  })
  @ApiResponse({
    status: 500,
    description: 'Unable to fetch supported coins',
  })
  async getSupportedCoins(@Query('currency') currency?: Currency) {
    return this.coinsService.getSupportedCoins(currency);
  }

  @Post('sync')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Sync supported coins to database',
    description:
      'Creates or updates supported coins (BTC, ETH, SOL, USDT, USDC, BNB) in the database with standard configurations. ' +
      'USDT and USDC use Tron (TRX) blockchain. Updates existing coins or creates new ones.',
  })
  @ApiResponse({
    status: 200,
    description: 'Coins synced successfully',
  })
  @ApiResponse({
    status: 500,
    description: 'Failed to sync coins',
  })
  async syncCoinsFromBinance() {
    return this.coinsService.syncCoinsFromBinance();
  }

  @Get(':symbol')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get coin details by symbol with optional price information (public endpoint)',
    description:
      'Returns details for a specific coin by symbol. Optionally include current price and 24-hour price change by specifying currency parameter (USD or SAR).',
  })
  @ApiParam({
    name: 'symbol',
    description: 'Coin symbol (e.g., USDT, BTC, ETH)',
    example: 'USDT',
  })
  @ApiQuery({
    name: 'currency',
    required: false,
    enum: Currency,
    description: 'Currency for coin price and 24h change (USD or SAR). If not provided, price information is not included.',
    example: Currency.USD,
  })
  @ApiResponse({
    status: 200,
    description: 'Coin details retrieved successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'Coin not found',
  })
  @ApiResponse({
    status: 500,
    description: 'Unable to fetch coin details',
  })
  async getCoinBySymbol(
    @Param('symbol') symbol: string,
    @Query('currency') currency?: Currency,
  ) {
    return this.coinsService.getCoinBySymbol(symbol, currency);
  }
}

