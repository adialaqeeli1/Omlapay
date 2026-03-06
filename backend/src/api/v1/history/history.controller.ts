import {
  Controller,
  Get,
  Param,
  Query,
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
import { HistoryService } from './history.service';
import { HistoryQueryDto } from './dto/history-query.dto';

@ApiTags('History')
@Controller({ path: 'history', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class HistoryController {
  constructor(private readonly historyService: HistoryService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get unified transaction history',
    description:
      'Returns all transactions (Receive, Send, Failed) with asset filter, type filter (All/Sent/Receive), date range (max 12 months), and pagination. Grouped by Recently and Month-Year.',
  })
  @ApiResponse({ status: 200, description: 'History retrieved' })
  @ApiResponse({ status: 400, description: 'Invalid date range or filters' })
  async getHistory(
    @CurrentUser() user: { userId: string },
    @Query() query: HistoryQueryDto,
  ) {
    return this.historyService.getHistory(user.userId, {
      asset: query.asset as import('@common/constants').AssetFilter,
      type: query.type as import('./history.constants').HistoryTypeFilter,
      startDate: query.startDate,
      endDate: query.endDate,
      after: query.after,
      limit: query.limit,
    });
  }

  @Get(':transactionId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get transaction detail',
    description: 'Returns single transaction (receive or send) by ID.',
  })
  @ApiResponse({ status: 200, description: 'Transaction details' })
  @ApiResponse({ status: 404, description: 'Transaction not found' })
  async getTransactionDetail(
    @CurrentUser() user: { userId: string },
    @Param('transactionId') transactionId: string,
  ) {
    return this.historyService.getTransactionDetail(user.userId, transactionId);
  }
}
