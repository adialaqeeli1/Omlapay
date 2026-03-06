import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThanOrEqual, LessThanOrEqual, Between, LessThan } from 'typeorm';
import { NotificationEntity } from '@common/database/model';
import { encodeCursor, decodeCursor } from '@common/utils';
import { GetNotificationsDto } from './dto/get-notifications.dto';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(NotificationEntity)
    private notificationRepository: Repository<NotificationEntity>,
  ) {}

  async getNotifications(userId: string, query: GetNotificationsDto) {
    const { after, limit = 20, type, is_read, from_date, to_date } = query;

    // Build where clause with filters
    const where: any = { userId };

    // Apply type filter
    if (type) {
      where.type = type;
    }

    // Apply is_read filter
    if (is_read !== undefined) {
      where.isRead = is_read;
    }

    // Apply date range filters
    if (from_date && to_date) {
      where.createdAt = Between(from_date, to_date);
    } else if (from_date) {
      where.createdAt = MoreThanOrEqual(from_date);
    } else if (to_date) {
      where.createdAt = LessThanOrEqual(to_date);
    }

    // Handle cursor-based pagination
    if (after) {
      const decodedCursor = decodeCursor(after);
      if (decodedCursor) {
        // Fetch items created before the cursor timestamp
        // If timestamps are equal, use ID for deterministic ordering
        const cursorDate = new Date(decodedCursor.timestamp);
        
        if (where.createdAt && typeof where.createdAt === 'object') {
          // If date filters exist, combine them with cursor
          where.createdAt = LessThan(cursorDate);
        } else {
          where.createdAt = LessThan(cursorDate);
        }
      }
    }

    // Fetch limit + 1 to check if there are more items
    const notifications = await this.notificationRepository.find({
      where,
      order: { createdAt: 'DESC', id: 'DESC' },
      take: limit + 1,
    });

    // Check if there are more items
    const hasMore = notifications.length > limit;
    
    // Remove the extra item if it exists
    if (hasMore) {
      notifications.pop();
    }

    // Get total unread count (always without filters except userId)
    const unreadCount = await this.notificationRepository.count({
      where: { userId, isRead: false },
    });

    // Format notifications
    const formattedNotifications = notifications.map((notif) => ({
      id: notif.id,
      title: notif.title,
      message: notif.message,
      type: notif.type,
      isRead: notif.isRead,
      createdAt: notif.createdAt,
      referenceId: notif.referenceId,
      referenceType: notif.referenceType,
    }));

    // Generate next cursor if there are more items
    let nextCursor: string | null = null;
    if (hasMore && notifications.length > 0) {
      const lastItem = notifications[notifications.length - 1];
      nextCursor = encodeCursor(lastItem.id, lastItem.createdAt);
    }

    return {
      status: 'success',
      unreadCount,
      notifications: formattedNotifications,
      pagination: {
        nextCursor,
        hasMore,
        limit,
      },
    };
  }

  async markAsRead(userId: string, notificationId: string) {
    // Find notification and verify it belongs to the user
    const notification = await this.notificationRepository.findOne({
      where: { id: notificationId, userId },
    });

    if (!notification) {
      throw new NotFoundException({
        status: 'error',
        message: 'Notification not found',
      });
    }

    // Mark as read if not already
    if (!notification.isRead) {
      notification.isRead = true;
      await this.notificationRepository.save(notification);
    }

    return {
      status: 'success',
      message: 'Notification marked as read.',
    };
  }

  /**
   * Mark all notifications as read for the user.
   */
  async markAllAsRead(userId: string) {
    const result = await this.notificationRepository.update(
      { userId, isRead: false },
      { isRead: true },
    );

    return {
      status: 'success',
      message: 'All notifications marked as read.',
      markedCount: result.affected ?? 0,
    };
  }
}

