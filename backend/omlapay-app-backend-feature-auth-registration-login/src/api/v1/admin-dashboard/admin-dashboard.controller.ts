import {
  Controller,
  Get,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AdminDashboardService } from './admin-dashboard.service';
import { DashboardStatsDto } from './dto/dashboard-stats.dto';
import { AdminJwtAuthGuard } from '@common/guards';

@ApiTags('Admin Dashboard')
@Controller({ path: 'admin/dashboard', version: '1' })
@UseGuards(AdminJwtAuthGuard)
@ApiBearerAuth()
export class AdminDashboardController {
  constructor(private readonly adminDashboardService: AdminDashboardService) {}

  @Get('stats')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get dashboard statistics with optional date range filter' })
  @ApiResponse({ status: 200, description: 'Dashboard statistics retrieved successfully' })
  @ApiResponse({ status: 400, description: 'Invalid date range' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getDashboardStats(@Query() dto: DashboardStatsDto) {
    return this.adminDashboardService.getDashboardStats(dto);
  }
}
