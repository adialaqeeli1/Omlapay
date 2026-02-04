import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AdminNotificationEntity, AdminNotificationType } from '@common/database/model';
import { NotificationListDto } from './dto/notification-list.dto';

@Injectable()
export class AdminNotificationsService {
  constructor(
    @InjectRepository(AdminNotificationEntity)
    private notificationRepository: Repository<AdminNotificationEntity>,
  ) {}

  async getNotifications(adminId: string, dto: NotificationListDto) {
    const { type, isRead, page = 1, limit = 20 } = dto;
    const skip = (page - 1) * limit;

    // Build query
    const queryBuilder = this.notificationRepository.createQueryBuilder(
      'notification',
    );

    queryBuilder.where('notification.adminId = :adminId', { adminId });

    // Apply type filter
    if (type) {
      queryBuilder.andWhere('notification.type = :type', { type });
    }

    // Apply read status filter
    if (isRead !== undefined) {
      queryBuilder.andWhere('notification.isRead = :isRead', { isRead });
    }

    // Get total count
    const total = await queryBuilder.getCount();

    // Get unread count (always without filters except adminId)
    const unreadCount = await this.notificationRepository.count({
      where: { adminId, isRead: false },
    });

    // Apply pagination and ordering
    const notifications = await queryBuilder
      .orderBy('notification.createdAt', 'DESC')
      .skip(skip)
      .take(limit)
      .getMany();

    // Format notifications
    const formattedNotifications = notifications.map((notification) => ({
      id: notification.id,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      isRead: notification.isRead,
      createdAt: notification.createdAt,
    }));

    return {
      notifications: formattedNotifications,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
      unreadCount,
    };
  }

  async markAsRead(adminId: string, notificationId: string) {
    const notification = await this.notificationRepository.findOne({
      where: { id: notificationId, adminId },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    notification.isRead = true;
    await this.notificationRepository.save(notification);

    return {
      message: 'Notification marked as read',
      notification: {
        id: notification.id,
        isRead: notification.isRead,
      },
    };
  }

  async markAllAsRead(adminId: string) {
    await this.notificationRepository.update(
      { adminId, isRead: false },
      { isRead: true },
    );

    return {
      message: 'All notifications marked as read',
    };
  }

  async getUnreadCount(adminId: string) {
    const count = await this.notificationRepository.count({
      where: { adminId, isRead: false },
    });

    return {
      unreadCount: count,
    };
  }
}
