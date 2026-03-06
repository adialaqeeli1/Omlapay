import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
  Ip,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AdminFeesService } from './admin-fees.service';
import { InitiateFeeUpdateDto, ConfirmFeeUpdateDto } from './dto/update-fee.dto';
import { AdminTransactionListDto } from './dto/transaction-list.dto';
import { AdminJwtAuthGuard, SuperAdminGuard } from '@common/guards';
import { CurrentAdmin } from '@common/decorators';

@ApiTags('Admin Fees')
@Controller({ path: 'admin/fees', version: '1' })
@UseGuards(AdminJwtAuthGuard)
@ApiBearerAuth()
export class AdminFeesController {
  constructor(private readonly adminFeesService: AdminFeesService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get current fee percentages (external transfer and swap)' })
  @ApiResponse({ status: 200, description: 'Fee percentages retrieved' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getFees() {
    return this.adminFeesService.getFees();
  }

  @Post('update/initiate')
  @UseGuards(SuperAdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Initiate fee update - sends OTP to admin email (Super Admin only)' })
  @ApiResponse({ status: 200, description: 'OTP sent' })
  @ApiResponse({ status: 403, description: 'Super Admin required' })
  async initiateFeeUpdate(
    @CurrentAdmin() adminId: string,
    @Body() dto: InitiateFeeUpdateDto,
    @Ip() ipAddress: string,
  ) {
    return this.adminFeesService.initiateFeeUpdate(adminId, dto, ipAddress);
  }

  @Post('update/confirm')
  @UseGuards(SuperAdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Confirm fee update with OTP (Super Admin only)' })
  @ApiResponse({ status: 200, description: 'Fee updated' })
  @ApiResponse({ status: 400, description: 'Invalid or expired OTP' })
  @ApiResponse({ status: 403, description: 'Super Admin required' })
  async confirmFeeUpdate(
    @CurrentAdmin() adminId: string,
    @Body() dto: ConfirmFeeUpdateDto,
    @Ip() ipAddress: string,
  ) {
    return this.adminFeesService.confirmFeeUpdate(adminId, dto, ipAddress);
  }

  @Get('profit')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get profit metrics in USD' })
  @ApiResponse({ status: 200, description: 'Profit metrics' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getProfitMetrics(
    @Query('fromDate') fromDate?: string,
    @Query('toDate') toDate?: string,
  ) {
    return this.adminFeesService.getProfitMetrics(fromDate, toDate);
  }

  @Get('transactions')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'List fee-bearing transactions with filters' })
  @ApiResponse({ status: 200, description: 'Transactions list' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getTransactions(@Query() dto: AdminTransactionListDto) {
    return this.adminFeesService.getTransactions(dto);
  }
}
