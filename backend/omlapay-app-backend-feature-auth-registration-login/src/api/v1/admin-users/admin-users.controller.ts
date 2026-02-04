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
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
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
  @ApiOperation({ summary: 'Get user details with wallet, transactions, and swaps' })
  @ApiResponse({ status: 200, description: 'User details retrieved successfully' })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserDetails(@Param('userId') userId: string) {
    return this.adminUsersService.getUserDetails(userId);
  }

  @Post(':userId/block')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Block a user (sends email notification)' })
  @ApiResponse({ status: 200, description: 'User blocked successfully' })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 400, description: 'User already blocked' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async blockUser(
    @Param('userId') userId: string,
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
    @Param('userId') userId: string,
    @CurrentAdmin() adminId: string,
  ) {
    return this.adminUsersService.unblockUser(userId, adminId);
  }
}
