import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '@common/guards';
import { CurrentUser } from '@common/decorators';
import { SwapService } from './swap.service';
import { SwapQuoteDto } from './dto/swap-quote.dto';
import { SwapExecuteDto } from './dto/swap-execute.dto';
import { SwapHistoryQueryDto } from './dto/swap-history.dto';

@ApiTags('Swap')
@Controller({ path: 'swap', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SwapController {
  constructor(private readonly swapService: SwapService) {}

  @Get('available-assets')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get available swap assets',
    description: 'Returns assets with user balances for swap.',
  })
  @ApiResponse({ status: 200, description: 'Available assets retrieved' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async getAvailableAssets(@CurrentUser() user: { userId: string }) {
    return this.swapService.getAvailableAssets(user.userId);
  }

  @Get('quote')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get swap quote',
    description:
      'Returns exchange rate, fees (Binance + Omlapay), and estimated output.',
  })
  @ApiResponse({ status: 200, description: 'Quote retrieved' })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async getQuote(
    @CurrentUser() user: { userId: string },
    @Query() dto: SwapQuoteDto,
  ) {
    return this.swapService.getQuote(user.userId, {
      fromCoin: dto.fromCoin,
      toCoin: dto.toCoin,
      amount: dto.amount,
    });
  }

  @Post('execute')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Execute swap',
    description: 'Executes the swap and updates balances.',
  })
  @ApiResponse({ status: 200, description: 'Swap completed' })
  @ApiResponse({ status: 400, description: 'Swap failed' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async execute(
    @CurrentUser() user: { userId: string },
    @Body() dto: SwapExecuteDto,
  ) {
    return this.swapService.execute(user.userId, {
      fromCoin: dto.fromCoin,
      toCoin: dto.toCoin,
      amount: dto.amount,
    });
  }

  @Get('history')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get swap history',
    description: 'Returns swap history with pagination.',
  })
  @ApiResponse({ status: 200, description: 'History retrieved' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async getHistory(
    @CurrentUser() user: { userId: string },
    @Query() query: SwapHistoryQueryDto,
  ) {
    return this.swapService.getHistory(user.userId, {
      after: query.after,
      limit: query.limit,
    });
  }

  @Get(':swapId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get swap by ID',
    description: 'Returns single swap transaction details.',
  })
  @ApiResponse({ status: 200, description: 'Swap retrieved' })
  @ApiResponse({ status: 404, description: 'Swap not found' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async getById(
    @CurrentUser() user: { userId: string },
    @Param('swapId') swapId: string,
  ) {
    return this.swapService.getById(user.userId, swapId);
  }
}
