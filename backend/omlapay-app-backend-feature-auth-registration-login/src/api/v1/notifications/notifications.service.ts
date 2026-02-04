import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThanOrEqual, LessThanOrEqual, Between, LessThan } from 'typeorm';
import { NotificationEntity } from '@common/database/model';
import { GetNotificationsDto } from './dto/get-notifications.dto';

interface DecodedCursor {
  id: string;
  timestamp: string;
}

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(NotificationEntity)
    private notificationRepository: Repository<NotificationEntity>,
  ) {}

  private encodeCursor(id: string, timestamp: Date): string {
    const cursor = { id, timestamp: timestamp.toISOString() };
    return Buffer.from(JSON.stringify(cursor)).toString('base64');
  }

  private decodeCursor(cursor: string): DecodedCursor | null {
    try {
      const decoded = Buffer.from(cursor, 'base64').toString('utf-8');
      return JSON.parse(decoded);
    } catch (error) {
      throw new BadRequestException({
        status: 'error',
        message: 'Invalid cursor format',
      });
    }
  }

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
      const decodedCursor = this.decodeCursor(after);
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
      is_read: notif.isRead,
      created_at: notif.createdAt,
      reference_id: notif.referenceId,
      reference_type: notif.referenceType,
    }));

    // Generate next cursor if there are more items
    let nextCursor: string | null = null;
    if (hasMore && notifications.length > 0) {
      const lastItem = notifications[notifications.length - 1];
      nextCursor = this.encodeCursor(lastItem.id, lastItem.createdAt);
    }

    return {
      status: 'success',
      unread_count: unreadCount,
      notifications: formattedNotifications,
      pagination: {
        next_cursor: nextCursor,
        has_more: hasMore,
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
}

