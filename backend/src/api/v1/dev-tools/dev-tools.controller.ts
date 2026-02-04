import { Controller, Post, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { DevToolsService } from './dev-tools.service';

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
}

