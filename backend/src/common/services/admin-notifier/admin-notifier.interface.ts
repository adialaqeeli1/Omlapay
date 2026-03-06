import { AdminNotificationType } from '@common/database/model';

/**
 * Abstraction for notifying admins.
 * Decouples user/admin domains - UserService emits via this interface
 * without depending on AdminNotificationsService directly.
 */
export const IAdminNotifier = Symbol('IAdminNotifier');

export interface IAdminNotifier {
  notifyAllAdmins(
    type: AdminNotificationType,
    title: string,
    message: string,
  ): Promise<number>;
}
