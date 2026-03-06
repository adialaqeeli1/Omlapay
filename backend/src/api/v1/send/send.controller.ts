import {
  Controller,
  Get,
  Post,
  Body,
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
import { SendService } from './send.service';
import { SendQuoteDto } from './dto/send-quote.dto';
import { SendInitiateDto } from './dto/send-initiate.dto';
import { SendConfirmDto } from './dto/send-confirm.dto';
import { SendResendOtpDto } from './dto/send-resend-otp.dto';
import { SendHistoryQueryDto } from './dto/send-history.dto';

@ApiTags('Send')
@Controller({ path: 'send', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SendController {
  constructor(private readonly sendService: SendService) {}

  @Get('quote')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get send quote',
    description:
      'Validate recipient and amount, return fees, balance, and USD value. Use before initiate.',
  })
  @ApiResponse({ status: 200, description: 'Quote retrieved' })
  @ApiResponse({ status: 400, description: 'Invalid recipient or amount' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async getQuote(
    @CurrentUser() user: { userId: string },
    @Query() dto: SendQuoteDto,
  ) {
    return this.sendService.getQuote(user.userId, {
      coin: dto.coin,
      recipient: dto.recipient,
      amount: dto.amount,
    });
  }

  @Post('initiate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Initiate send (sends OTP)',
    description:
      'Validates and creates pending send. Sends OTP to user phone. Use confirm with sendToken to complete.',
  })
  @ApiResponse({ status: 200, description: 'OTP sent, sendToken returned' })
  @ApiResponse({ status: 400, description: 'Invalid request or recipient' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async initiate(
    @CurrentUser() user: { userId: string },
    @Body() dto: SendInitiateDto,
  ) {
    return this.sendService.initiate(user.userId, {
      coin: dto.coin,
      recipient: dto.recipient,
      amount: dto.amount,
      network: dto.network,
    });
  }

  @Post('resend-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Resend OTP for send verification',
    description:
      'Resends the verification code for an existing send request. Use when user did not receive the OTP.',
  })
  @ApiResponse({ status: 200, description: 'OTP resent successfully' })
  @ApiResponse({ status: 400, description: 'Send request expired' })
  @ApiResponse({ status: 404, description: 'Send request not found' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async resendOtp(
    @CurrentUser() user: { userId: string },
    @Body() dto: SendResendOtpDto,
  ) {
    return this.sendService.resendOtp(user.userId, dto.sendToken);
  }

  @Post('confirm')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Confirm send (verify OTP and execute)',
    description: 'Verifies OTP and executes the send transaction.',
  })
  @ApiResponse({ status: 200, description: 'Send in progress' })
  @ApiResponse({ status: 400, description: 'Invalid OTP or expired' })
  @ApiResponse({ status: 404, description: 'Send request not found' })
  async confirm(
    @CurrentUser() user: { userId: string },
    @Body() dto: SendConfirmDto,
  ) {
    return this.sendService.confirm(user.userId, {
      sendToken: dto.sendToken,
      otp: dto.otp,
    });
  }

  @Get('history')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get send transaction history',
    description:
      'Returns OUT/SENT transactions with pagination. Filter by asset.',
  })
  @ApiResponse({ status: 200, description: 'History retrieved' })
  @ApiResponse({ status: 403, description: 'KYC required' })
  async getHistory(
    @CurrentUser() user: { userId: string },
    @Query() query: SendHistoryQueryDto,
  ) {
    return this.sendService.getHistory(user.userId, {
      asset: query.asset,
      after: query.after,
      limit: query.limit,
    });
  }

  @Get('history/:transactionId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get send transaction details',
    description: 'Returns single sent transaction.',
  })
  @ApiResponse({ status: 200, description: 'Transaction details' })
  @ApiResponse({ status: 404, description: 'Transaction not found' })
  async getTransactionDetail(
    @CurrentUser() user: { userId: string },
    @Param('transactionId') transactionId: string,
  ) {
    return this.sendService.getTransactionDetail(user.userId, transactionId);
  }
}
