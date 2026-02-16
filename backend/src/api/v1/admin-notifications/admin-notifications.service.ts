import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  AdminNotificationEntity,
  AdminNotificationType,
  AdminEntity,
} from '@common/database/model';
import { NotificationListDto } from './dto/notification-list.dto';

@Injectable()
export class AdminNotificationsService {
  private readonly logger = new Logger(AdminNotificationsService.name);

  constructor(
    @InjectRepository(AdminNotificationEntity)
    private notificationRepository: Repository<AdminNotificationEntity>,
    @InjectRepository(AdminEntity)
    private adminRepository: Repository<AdminEntity>,
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

    // Get per-type counts for filter tabs (All, Moderation/SECURITY, User Lifecycle/USER, Support/TICKET, Transactions/TRANSACTION)
    const typeCounts = await this.getTypeCounts(adminId);

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
      typeCounts,
    };
  }

  /**
   * Returns count of notifications per type for the given admin (for filter tab badges).
   */
  private async getTypeCounts(adminId: string): Promise<Record<AdminNotificationType, number>> {
    const counts = await this.notificationRepository
      .createQueryBuilder('n')
      .select('n.type', 'type')
      .addSelect('COUNT(*)', 'count')
      .where('n.adminId = :adminId', { adminId })
      .groupBy('n.type')
      .getRawMany<{ type: AdminNotificationType; count: string }>();

    const typeCounts: Record<AdminNotificationType, number> = {
      [AdminNotificationType.SECURITY]: 0,
      [AdminNotificationType.USER]: 0,
      [AdminNotificationType.TRANSACTION]: 0,
      [AdminNotificationType.TICKET]: 0,
    };
    for (const row of counts) {
      typeCounts[row.type] = parseInt(row.count, 10) || 0;
    }
    return typeCounts;
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

  /**
   * Create a notification for a specific admin.
   * @param adminId - Admin ID to notify
   * @param type - Notification type
   * @param title - Notification title
   * @param message - Notification message
   * @returns Created notification entity
   */
  async createNotification(
    adminId: string,
    type: AdminNotificationType,
    title: string,
    message: string,
  ): Promise<AdminNotificationEntity> {
    const notification = this.notificationRepository.create({
      adminId,
      type,
      title,
      message,
      isRead: false,
    });

    return await this.notificationRepository.save(notification);
  }

  /**
   * Notify all active admins when a transaction fails.
   * Call this when a transaction is marked as FAILED (e.g. from wallet/transfer flow).
   */
  async notifyTransactionFailed(
    transactionId: string,
    userId: string,
    amount?: string,
    errorMessage?: string,
  ): Promise<number> {
    const message = [
      'A transaction has failed.',
      amount ? ` Amount: ${amount}.` : '',
      ` Transaction ID: ${transactionId.slice(0, 8).toUpperCase()}.`,
      ` User ID: ${userId.slice(0, 8).toUpperCase()}.`,
      errorMessage ? ` Reason: ${errorMessage}` : '',
    ].join('');
    return this.notifyAllAdmins(
      AdminNotificationType.TRANSACTION,
      'Failed Transaction',
      message.trim(),
    );
  }

  /**
   * Notify all active admins about an event.
   * Creates a notification for each active admin in the system.
   * @param type - Notification type
   * @param title - Notification title
   * @param message - Notification message
   * @returns Number of notifications created
   */
  async notifyAllAdmins(
    type: AdminNotificationType,
    title: string,
    message: string,
  ): Promise<number> {
    try {
      // Get all active admins
      const activeAdmins = await this.adminRepository.find({
        where: { isActive: true },
        select: ['adminId'],
      });

      if (activeAdmins.length === 0) {
        this.logger.warn('No active admins found to notify');
        return 0;
      }

      // Create notifications for all active admins
      const notifications = activeAdmins.map((admin) =>
        this.notificationRepository.create({
          adminId: admin.adminId,
          type,
          title,
          message,
          isRead: false,
        }),
      );

      await this.notificationRepository.save(notifications);

      this.logger.log(
        `Created ${notifications.length} admin notifications for event: ${title}`,
      );

      return notifications.length;
    } catch (error) {
      this.logger.error(
        `Failed to notify all admins: ${(error as Error).message}`,
        (error as Error).stack,
      );
      // Don't throw - notification failure shouldn't break the main flow
      return 0;
    }
  }
}
