import {
  Controller,
  Get,
  Post,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AdminNotificationsService } from './admin-notifications.service';
import { NotificationListDto } from './dto/notification-list.dto';
import { AdminJwtAuthGuard } from '@common/guards';
import { CurrentAdmin } from '@common/decorators';

@ApiTags('Admin Notifications')
@Controller({ path: 'admin/notifications', version: '1' })
@UseGuards(AdminJwtAuthGuard)
@ApiBearerAuth()
export class AdminNotificationsController {
  constructor(
    private readonly adminNotificationsService: AdminNotificationsService,
  ) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get admin notifications with filters and pagination' })
  @ApiResponse({ status: 200, description: 'Notifications retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getNotifications(
    @CurrentAdmin() adminId: string,
    @Query() dto: NotificationListDto,
  ) {
    return this.adminNotificationsService.getNotifications(adminId, dto);
  }

  @Get('unread-count')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get unread notification count' })
  @ApiResponse({ status: 200, description: 'Unread count retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUnreadCount(@CurrentAdmin() adminId: string) {
    return this.adminNotificationsService.getUnreadCount(adminId);
  }

  @Post(':notificationId/read')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark a notification as read' })
  @ApiResponse({ status: 200, description: 'Notification marked as read' })
  @ApiResponse({ status: 404, description: 'Notification not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async markAsRead(
    @CurrentAdmin() adminId: string,
    @Param('notificationId') notificationId: string,
  ) {
    return this.adminNotificationsService.markAsRead(adminId, notificationId);
  }

  @Post('read-all')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark all notifications as read' })
  @ApiResponse({ status: 200, description: 'All notifications marked as read' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async markAllAsRead(@CurrentAdmin() adminId: string) {
    return this.adminNotificationsService.markAllAsRead(adminId);
  }
}
