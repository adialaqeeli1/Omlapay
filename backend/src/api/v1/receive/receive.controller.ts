import {
  Controller,
  Get,
  Query,
  Param,
  UseGuards,
  Res,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Response } from 'express';
import { JwtAuthGuard } from '@common/guards';
import { CurrentUser } from '@common/decorators';
import { ReceiveService } from './receive.service';
import { ReceiveHistoryQueryDto } from './dto/receive-history.dto';
import { ReceiveQrQueryDto } from './dto/receive-qr.dto';

@ApiTags('Receive')
@Controller({ path: 'receive', version: '1' })
export class ReceiveController {
  constructor(private readonly receiveService: ReceiveService) {}

  @Get('wallets')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get wallet addresses by network',
    description:
      'Wallet Selection Screen. Returns addresses grouped by network. Requires KYC.',
  })
  @ApiResponse({ status: 200, description: 'Wallet list retrieved' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async getWallets(@CurrentUser() user: { userId: string }) {
    return this.receiveService.getWallets(user.userId);
  }

  @Get('qr')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Generate QR code for wallet address',
    description:
      'Returns PNG or SVG QR code encoding the wallet address. High resolution for scanning.',
  })
  @ApiResponse({
    status: 200,
    description: 'QR code image (PNG or SVG)',
    content: {
      'image/png': {},
      'image/svg+xml': {},
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid network or coin' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async getQrCode(
    @CurrentUser() user: { userId: string },
    @Query() query: ReceiveQrQueryDto,
    @Res() res: Response,
  ) {
    const format = (query.format ?? 'png') as 'png' | 'svg';
    const { buffer, mimeType } = await this.receiveService.getQrCode(
      user.userId,
      query.network,
      query.coin,
      format,
    );

    res.setHeader('Content-Type', mimeType);
    res.setHeader('Content-Length', buffer.length);
    res.send(buffer);
  }

  @Get('history')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get receive transaction history',
    description:
      'Returns IN/RECEIVED transactions with cursor-based pagination (after, limit). Filter by asset (ALL, USDC, USDT, BTC, ETH, BNB, SOL).',
  })
  @ApiResponse({ status: 200, description: 'History retrieved' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async getReceiveHistory(
    @CurrentUser() user: { userId: string },
    @Query() query: ReceiveHistoryQueryDto,
  ) {
    return this.receiveService.getReceiveHistory(user.userId, {
      asset: (query.asset ?? 'ALL') as import('@common/constants').AssetFilter,
      after: query.after,
      limit: query.limit ?? 20,
    });
  }

  @Get('history/:transactionId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get receive transaction details',
    description: 'Returns single receive transaction. Only IN/RECEIVED allowed.',
  })
  @ApiResponse({ status: 200, description: 'Transaction details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  @ApiResponse({ status: 404, description: 'Transaction not found' })
  async getReceiveTransactionDetails(
    @CurrentUser() user: { userId: string },
    @Param('transactionId') transactionId: string,
  ) {
    return this.receiveService.getReceiveTransactionDetails(
      user.userId,
      transactionId,
    );
  }
}
