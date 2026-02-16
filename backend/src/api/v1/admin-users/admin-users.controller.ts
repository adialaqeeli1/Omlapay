import {
  Controller,
  Get,
  Post,
  Param,
  Query,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
  ParseIntPipe,
  ParseUUIDPipe,
  DefaultValuePipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AdminUsersService } from './admin-users.service';
import { UserListDto } from './dto/user-list.dto';
import { BlockUserDto } from './dto/block-user.dto';
import { AdminJwtAuthGuard } from '@common/guards';
import { CurrentAdmin } from '@common/decorators';

@ApiTags('Admin Users')
@Controller({ path: 'admin/users', version: '1' })
@UseGuards(AdminJwtAuthGuard)
@ApiBearerAuth()
export class AdminUsersController {
  constructor(private readonly adminUsersService: AdminUsersService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get user list with search and pagination' })
  @ApiResponse({ status: 200, description: 'User list retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserList(@Query() dto: UserListDto) {
    return this.adminUsersService.getUserList(dto);
  }

  @Get(':userId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get user details with wallet summary' })
  @ApiResponse({ status: 200, description: 'User details retrieved successfully' })
  @ApiResponse({ status: 400, description: 'Invalid user ID format' })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserDetails(@Param('userId', ParseUUIDPipe) userId: string) {
    return this.adminUsersService.getUserDetails(userId);
  }

  @Get(':userId/transactions')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get user transaction history' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10 })
  @ApiResponse({ status: 200, description: 'Transaction history retrieved successfully' })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserTransactions(
    @Param('userId', ParseUUIDPipe) userId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number,
  ) {
    return this.adminUsersService.getUserTransactions(userId, page, limit);
  }

  @Get(':userId/swaps')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get user swap history' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10 })
  @ApiResponse({ status: 200, description: 'Swap history retrieved successfully' })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserSwaps(
    @Param('userId', ParseUUIDPipe) userId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number,
  ) {
    return this.adminUsersService.getUserSwaps(userId, page, limit);
  }

  @Post(':userId/block')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Block a user (sends email notification)' })
  @ApiResponse({ status: 200, description: 'User blocked successfully' })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 400, description: 'User already blocked' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async blockUser(
    @Param('userId', ParseUUIDPipe) userId: string,
    @CurrentAdmin() adminId: string,
    @Body() dto: BlockUserDto,
  ) {
    return this.adminUsersService.blockUser(userId, adminId, dto);
  }

  @Post(':userId/unblock')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Unblock a user' })
  @ApiResponse({ status: 200, description: 'User unblocked successfully' })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 400, description: 'User already active' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async unblockUser(
    @Param('userId', ParseUUIDPipe) userId: string,
    @CurrentAdmin() adminId: string,
  ) {
    return this.adminUsersService.unblockUser(userId, adminId);
  }
}
