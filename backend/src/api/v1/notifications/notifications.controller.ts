import {
  Controller,
  Get,
  Post,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  UseGuards,
  ParseUUIDPipe,
  Body,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '@common/guards';
import { CurrentUser } from '@common/decorators';
import { GetNotificationsDto } from './dto/get-notifications.dto';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { PushDeviceService } from '@common/services/push-device/push-device.service';

@ApiTags('Notifications')
@Controller({ path: 'notifications', version: '1' })
export class NotificationsController {
  constructor(
    private readonly notificationsService: NotificationsService,
    private readonly pushDevices: PushDeviceService,
  ) {}

  @Post('devices')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: "Register this phone's push-notification (FCM) token",
    description:
      'Called by the app after login and when FCM refreshes the token. The token is tied to this ' +
      'user and session; logout (with device_token) removes it.',
  })
  @ApiResponse({ status: 200, description: 'Device registered' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async registerDevice(
    @CurrentUser() user: { userId: string; sessionId?: string },
    @Body() dto: RegisterDeviceDto,
  ) {
    await this.pushDevices.register(user.userId, user.sessionId ?? null, {
      deviceToken: dto.device_token,
      deviceUuid: dto.device_uuid,
      deviceModel: dto.device_model,
    });
    return { status: 'success', message: 'Device registered.' };
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get notifications with cursor-based pagination and filters',
    description:
      'Supports cursor-based pagination (after, limit) and optional filters (type, is_read, from_date, to_date)',
  })
  @ApiResponse({
    status: 200,
    description: 'Notifications retrieved successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getNotifications(
    @CurrentUser() user: any,
    @Query() query: GetNotificationsDto,
  ) {
    return this.notificationsService.getNotifications(user.userId, query);
  }

  @Post('mark-all-read')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark all notifications as read' })
  @ApiResponse({
    status: 200,
    description: 'All notifications marked as read successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async markAllAsRead(@CurrentUser() user: any) {
    return this.notificationsService.markAllAsRead(user.userId);
  }

  @Post(':id/read')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark notification as read' })
  @ApiResponse({
    status: 200,
    description: 'Notification marked as read successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Notification not found' })
  async markAsRead(
    @CurrentUser() user: any,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.notificationsService.markAsRead(user.userId, id);
  }
}

