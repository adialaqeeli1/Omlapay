import {
  Body,
  Controller,
  Post,
  Get,
  HttpCode,
  HttpStatus,
  Query,
  Param,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { DevToolsService } from './dev-tools.service';
import { CreateBinanceOrderDto } from './dto/create-binance-order.dto';
import { CreateBinanceSubaccountDto } from './dto/create-binance-subaccount.dto';
import { successResponse, errorResponse } from '@common/utils';

@ApiTags('Dev Tools')
@Controller({ path: 'dev-tools', version: '1' })
export class DevToolsController {
  constructor(private readonly devToolsService: DevToolsService) {}

  @Post('seed')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Seed database with dummy data',
    description:
      'Creates 2-3 users with related data and 50-100 records for transactions, notifications, etc. WARNING: This will clear existing data!',
  })
  @ApiResponse({
    status: 200,
    description: 'Database seeded successfully',
  })
  async seedDatabase() {
    return this.devToolsService.seedDatabase();
  }

  @Post('seed-admin')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Seed admin account',
    description:
      'Creates an admin account with email: admin@omlapay.com and password: Admin@123',
  })
  @ApiResponse({
    status: 200,
    description: 'Admin account seeded successfully',
  })
  async seedAdmin() {
    return this.devToolsService.seedAdmin();
  }

  @Get('sms/balance')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Check SMS service (Taqnyat) balance',
    description:
      'Checks the current balance/credits available in the Taqnyat SMS service account. Available in all environments including production.',
  })
  @ApiResponse({
    status: 200,
    description: 'SMS balance retrieved successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'SMS service not configured or API error',
  })
  async checkSmsBalance() {
    return this.devToolsService.checkSmsBalance();
  }

  @Post('binance/test-subaccount')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Test Binance sub-account creation',
    description:
      'Dev-only endpoint. Tests creating a Binance Broker sub-account with custom API key and private key (RSA or Ed25519).',
  })
  @ApiResponse({
    status: 200,
    description: 'Sub-account created successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid request or Binance API error',
  })
  async testBinanceSubaccount(@Body() dto: CreateBinanceSubaccountDto) {
    return this.devToolsService.testBinanceSubaccount(dto);
  }

  @Post('binance-testnet/order')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Create a Binance Testnet order (RSA-signed)',
    description:
      'Dev-only endpoint. Signs and forwards an order request to Binance Testnet and returns Binance JSON response as-is.',
  })
  @ApiResponse({
    status: 200,
    description: 'Binance response JSON',
  })
  async createBinanceTestnetOrder(@Body() body: CreateBinanceOrderDto) {
    return this.devToolsService.createBinanceTestnetOrder(body);
  }

  @Get('binance-testnet/order')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get Binance Testnet order status (RSA-signed)',
    description:
      'Dev-only endpoint. Gets order status from Binance Testnet and returns Binance JSON response as-is.',
  })
  @ApiQuery({ name: 'symbol', required: true, description: 'Trading pair (e.g., BTCUSDT)' })
  @ApiQuery({ name: 'orderId', required: false, description: 'Order ID' })
  @ApiQuery({ name: 'origClientOrderId', required: false, description: 'Original client order ID' })
  @ApiResponse({
    status: 200,
    description: 'Binance response JSON',
  })
  async getBinanceTestnetOrder(
    @Query('symbol') symbol: string,
    @Query('orderId') orderId?: string,
    @Query('origClientOrderId') origClientOrderId?: string,
  ) {
    return this.devToolsService.getBinanceTestnetOrder({
      symbol,
      orderId,
      origClientOrderId,
    });
  }

  @Get('binance-testnet/open-orders')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get all open Binance Testnet orders (RSA-signed)',
    description:
      'Dev-only endpoint. Gets all open orders from Binance Testnet and returns Binance JSON response as-is.',
  })
  @ApiQuery({ name: 'symbol', required: false, description: 'Trading pair (optional, gets all if omitted)' })
  @ApiResponse({
    status: 200,
    description: 'Binance response JSON',
  })
  async getBinanceTestnetOpenOrders(@Query('symbol') symbol?: string) {
    return this.devToolsService.getBinanceTestnetOpenOrders(symbol);
  }

  @Get('binance-testnet/all-orders')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get all Binance Testnet orders (RSA-signed)',
    description:
      'Dev-only endpoint. Gets all orders from Binance Testnet and returns Binance JSON response as-is.',
  })
  @ApiQuery({ name: 'symbol', required: true, description: 'Trading pair (e.g., BTCUSDT)' })
  @ApiQuery({ name: 'orderId', required: false, description: 'Order ID to fetch from' })
  @ApiQuery({ name: 'startTime', required: false, description: 'Start time (timestamp)' })
  @ApiQuery({ name: 'endTime', required: false, description: 'End time (timestamp)' })
  @ApiQuery({ name: 'limit', required: false, description: 'Number of orders to return (default 500, max 1000)' })
  @ApiResponse({
    status: 200,
    description: 'Binance response JSON',
  })
  async getBinanceTestnetAllOrders(
    @Query('symbol') symbol: string,
    @Query('orderId') orderId?: string,
    @Query('startTime') startTime?: string,
    @Query('endTime') endTime?: string,
    @Query('limit') limit?: string,
  ) {
    return this.devToolsService.getBinanceTestnetAllOrders({
      symbol,
      orderId,
      startTime,
      endTime,
      limit,
    });
  }

  @Get('binance-testnet/my-trades')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get Binance Testnet account trade list (RSA-signed)',
    description:
      'Dev-only endpoint. Gets account trade list from Binance Testnet and returns Binance JSON response as-is.',
  })
  @ApiQuery({ name: 'symbol', required: true, description: 'Trading pair (e.g., BTCUSDT)' })
  @ApiQuery({ name: 'orderId', required: false, description: 'Order ID to fetch trades from' })
  @ApiQuery({ name: 'startTime', required: false, description: 'Start time (timestamp)' })
  @ApiQuery({ name: 'endTime', required: false, description: 'End time (timestamp)' })
  @ApiQuery({ name: 'fromId', required: false, description: 'Trade ID to fetch from' })
  @ApiQuery({ name: 'limit', required: false, description: 'Number of trades to return (default 500, max 1000)' })
  @ApiResponse({
    status: 200,
    description: 'Binance response JSON',
  })
  async getBinanceTestnetMyTrades(
    @Query('symbol') symbol: string,
    @Query('orderId') orderId?: string,
    @Query('startTime') startTime?: string,
    @Query('endTime') endTime?: string,
    @Query('fromId') fromId?: string,
    @Query('limit') limit?: string,
  ) {
    return this.devToolsService.getBinanceTestnetMyTrades({
      symbol,
      orderId,
      startTime,
      endTime,
      fromId,
      limit,
    });
  }

  @Get('binance-testnet/account')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get Binance Testnet account information (RSA-signed)',
    description:
      'Dev-only endpoint. Gets account information from Binance Testnet and returns Binance JSON response as-is.',
  })
  @ApiResponse({
    status: 200,
    description: 'Binance response JSON',
  })
  async getBinanceTestnetAccount() {
    return this.devToolsService.getBinanceTestnetAccount();
  }

  // Swap Testing Flow - Step by Step
  @Get('swap-testing-flow/step1/account')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 1: Get Binance Testnet account (Swap Testing Flow)',
    description:
      'Step 1 of swap testing flow. Verifies account access, canTrade status, and balances. Must succeed before proceeding.',
  })
  @ApiResponse({
    status: 200,
    description: 'Binance account JSON with balances and canTrade status',
  })
  async step1GetAccount() {
    return this.devToolsService.step1GetAccount();
  }

  @Post('swap-testing-flow/step2/swap-order')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 2: Place swap order (MARKET order)',
    description:
      'Step 2 of swap testing flow. Places a MARKET order to perform the swap (e.g., SELL BTCUSDT to swap BTC → USDT).',
  })
  @ApiResponse({
    status: 200,
    description: 'Binance order response JSON',
  })
  async step2PlaceSwapOrder(@Body() body: CreateBinanceOrderDto) {
    return this.devToolsService.step2PlaceSwapOrder(body);
  }

  @Get('swap-testing-flow/step3/order-status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 3: Verify order status',
    description:
      'Step 3 of swap testing flow. Verifies the order execution status. Check if status = FILLED.',
  })
  @ApiQuery({ name: 'symbol', required: true, description: 'Trading pair (e.g., BTCUSDT)' })
  @ApiQuery({ name: 'orderId', required: true, description: 'Order ID from step 2' })
  @ApiResponse({
    status: 200,
    description: 'Binance order status JSON',
  })
  async step3GetOrderStatus(
    @Query('symbol') symbol: string,
    @Query('orderId') orderId: string,
  ) {
    return this.devToolsService.step3GetOrderStatus({ symbol, orderId });
  }

  @Get('swap-testing-flow/step4/trade-fills')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 4: Fetch trade fills (actual swap result)',
    description:
      'Step 4 of swap testing flow. Gets the actual trade fills showing exact price, fees, quantity, and trade ID.',
  })
  @ApiQuery({ name: 'symbol', required: true, description: 'Trading pair (e.g., BTCUSDT)' })
  @ApiQuery({ name: 'orderId', required: false, description: 'Order ID to filter trades' })
  @ApiQuery({ name: 'limit', required: false, description: 'Number of trades to return (default 500, max 1000)' })
  @ApiResponse({
    status: 200,
    description: 'Binance trade fills JSON',
  })
  async step4GetTradeFills(
    @Query('symbol') symbol: string,
    @Query('orderId') orderId?: string,
    @Query('limit') limit?: string,
  ) {
    return this.devToolsService.step4GetTradeFills({ symbol, orderId, limit });
  }

  @Get('swap-testing-flow/step5/account')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 5: Verify updated balances',
    description:
      'Step 5 of swap testing flow. Verifies updated balances after swap. Check that source asset decreased and target asset increased.',
  })
  @ApiResponse({
    status: 200,
    description: 'Binance account JSON with updated balances',
  })
  async step5VerifyBalances() {
    return this.devToolsService.step5VerifyBalances();
  }

  // Receive Funds Flow - Step by Step
  @Get('receive-funds-flow/step1/deposit-address')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 1: Get deposit address (MOST IMPORTANT)',
    description:
      'Step 1 of receive funds flow. Gets the wallet address where users should send funds. This is what you show to the user.',
  })
  @ApiQuery({ name: 'coin', required: true, description: 'Coin symbol (e.g., USDT)' })
  @ApiQuery({ name: 'network', required: true, description: 'Network (e.g., TRX, ETH, BSC)' })
  @ApiResponse({
    status: 200,
    description: 'Binance deposit address JSON with address and network',
  })
  async step1GetDepositAddress(
    @Query('coin') coin: string,
    @Query('network') network: string,
  ) {
    return this.devToolsService.step1GetDepositAddress({ coin, network });
  }

  @Get('receive-funds-flow/step2/simulate-transfer')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 2: Simulate external transfer (Testnet Reality)',
    description:
      'Step 2 of receive funds flow. On testnet, you cannot use real wallets. External means Binance testnet faucet, another testnet account, or manual balance simulation. This endpoint provides instructions.',
  })
  @ApiResponse({
    status: 200,
    description: 'Instructions for simulating external transfer on testnet',
  })
  async step2SimulateTransfer() {
    return this.devToolsService.step2SimulateTransfer();
  }

  @Get('receive-funds-flow/step3/deposit-history')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 3: Check deposit history (Detection)',
    description:
      'Step 3 of receive funds flow. Checks deposit history to detect incoming deposits. Status: 0=Pending, 1=Success, 6=Credited but frozen.',
  })
  @ApiQuery({ name: 'coin', required: false, description: 'Coin symbol (optional, filters by coin)' })
  @ApiQuery({ name: 'limit', required: false, description: 'Number of records to return (default 500, max 1000)' })
  @ApiResponse({
    status: 200,
    description: 'Binance deposit history JSON array',
  })
  async step3CheckDepositHistory(
    @Query('coin') coin?: string,
    @Query('limit') limit?: string,
  ) {
    return this.devToolsService.step3CheckDepositHistory({ coin, limit });
  }

  @Get('receive-funds-flow/step4/credit-user')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 4: Credit user internally (CRITICAL STEP)',
    description:
      'Step 4 of receive funds flow. Once deposit appears with status=1 (success), you must credit the user in your internal ledger. This is backend logic - Binance does NOT credit your users for you. This endpoint provides guidance.',
  })
  @ApiResponse({
    status: 200,
    description: 'Guidance for crediting user internally',
  })
  async step4CreditUser() {
    return this.devToolsService.step4CreditUser();
  }

  @Get('receive-funds-flow/step5/verify-balance')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 5: Verify Binance wallet balance changed',
    description:
      'Step 5 of receive funds flow. Verifies that the Binance wallet balance increased, confirming funds actually entered custody and deposit was real.',
  })
  @ApiResponse({
    status: 200,
    description: 'Binance account JSON with updated balances',
  })
  async step5VerifyBalance() {
    return this.devToolsService.step5VerifyBalance();
  }

  // Send Funds Flow - Step by Step
  @Get('send-funds-flow/step0/preconditions')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 0: Check preconditions',
    description:
      'Step 0 of send funds flow. Validates that all preconditions are met before allowing withdrawal.',
  })
  @ApiResponse({
    status: 200,
    description: 'Preconditions checklist',
  })
  async step0CheckPreconditions() {
    return this.devToolsService.step0CheckPreconditions();
  }

  @Get('send-funds-flow/step1/validate-withdrawal-details')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 1: Validate withdrawal details',
    description:
      'Step 1 of send funds flow. User provides coin, amount, address, and network. This step validates the input - no Binance API call yet.',
  })
  @ApiQuery({ name: 'coin', required: true, description: 'Coin symbol (e.g., USDT)' })
  @ApiQuery({ name: 'amount', required: true, description: 'Amount to withdraw' })
  @ApiQuery({ name: 'address', required: true, description: 'External wallet address' })
  @ApiQuery({ name: 'network', required: true, description: 'Network (e.g., TRX, ETH, BSC)' })
  @ApiQuery({ name: 'addressTag', required: false, description: 'Address tag/memo (optional, depends on coin)' })
  @ApiResponse({
    status: 200,
    description: 'Validation result and guidance',
  })
  async step1ValidateWithdrawalDetails(
    @Query('coin') coin: string,
    @Query('amount') amount: string,
    @Query('address') address: string,
    @Query('network') network: string,
    @Query('addressTag') addressTag?: string,
  ) {
    return this.devToolsService.step1ValidateWithdrawalDetails({
      coin,
      amount,
      address,
      network,
      addressTag,
    });
  }

  @Get('send-funds-flow/step2/check-balance')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 2: Check wallet balance (Optional but Recommended)',
    description:
      'Step 2 of send funds flow. Confirms available balance before withdrawal. Extra safety check.',
  })
  @ApiResponse({
    status: 200,
    description: 'Binance account JSON with balances',
  })
  async step2CheckBalance() {
    return this.devToolsService.step2CheckBalance();
  }

  @Post('send-funds-flow/step3/initiate-withdrawal')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 3: Initiate withdrawal (Core API)',
    description:
      'Step 3 of send funds flow. Initiates the withdrawal request to Binance. Once accepted, withdrawal will be processed on blockchain.',
  })
  @ApiResponse({
    status: 200,
    description: 'Binance withdrawal response with withdrawal order ID',
  })
  async step3InitiateWithdrawal(@Body() body: {
    coin: string;
    address: string;
    amount: string;
    network: string;
    addressTag?: string;
  }) {
    return this.devToolsService.step3InitiateWithdrawal(body);
  }

  @Get('send-funds-flow/step4/deduct-balance')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 4: Deduct user balance internally (Immediately)',
    description:
      'Step 4 of send funds flow. Once Binance accepts the withdrawal request, deduct balance from user internal ledger and mark transaction as processing. Do not wait for blockchain confirmation.',
  })
  @ApiResponse({
    status: 200,
    description: 'Guidance for deducting user balance internally',
  })
  async step4DeductBalance() {
    return this.devToolsService.step4DeductBalance();
  }

  @Get('send-funds-flow/step5/track-withdrawal-status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'STEP 5: Track withdrawal status',
    description:
      'Step 5 of send funds flow. Tracks the withdrawal status to monitor progress and completion.',
  })
  @ApiQuery({ name: 'coin', required: false, description: 'Coin symbol (optional, filters by coin)' })
  @ApiQuery({ name: 'withdrawOrderId', required: false, description: 'Withdrawal order ID from step 3' })
  @ApiQuery({ name: 'limit', required: false, description: 'Number of records to return (default 500, max 1000)' })
  @ApiResponse({
    status: 200,
    description: 'Binance withdrawal history JSON',
  })
  async step5TrackWithdrawalStatus(
    @Query('coin') coin?: string,
    @Query('withdrawOrderId') withdrawOrderId?: string,
    @Query('limit') limit?: string,
  ) {
    return this.devToolsService.step5TrackWithdrawalStatus({
      coin,
      withdrawOrderId,
      limit,
    });
  }

  @Get('sumsub/levels')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get available Sumsub verification levels (Sandbox)',
    description:
      'Dev-only endpoint. Lists all available verification levels in your Sumsub account. Use this to find level names to use in access token generation.',
  })
  @ApiResponse({
    status: 200,
    description: 'List of available verification levels',
  })
  async getSumsubLevels() {
    try {
      const result = await this.devToolsService.getSumsubLevels();
      return successResponse(result, 'Sumsub levels retrieved successfully');
    } catch (error) {
      return errorResponse(
        error.message || 'Failed to get Sumsub levels',
        error,
      );
    }
  }
}

