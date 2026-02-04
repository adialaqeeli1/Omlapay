import { Controller, Get, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { CoinsService } from './coins.service';

@ApiTags('Coins')
@Controller({ path: 'coins', version: '1' })
export class CoinsController {
  constructor(private readonly coinsService: CoinsService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get all supported coins (public endpoint)' })
  @ApiResponse({
    status: 200,
    description: 'Supported coins retrieved successfully',
  })
  @ApiResponse({
    status: 500,
    description: 'Unable to fetch supported coins',
  })
  async getSupportedCoins() {
    return this.coinsService.getSupportedCoins();
  }
}

