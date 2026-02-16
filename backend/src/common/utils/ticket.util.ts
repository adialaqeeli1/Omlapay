import { SupportRequestStatus } from '@common/database/model';

/**
 * Ticket status color mapping utility.
 * Maps ticket statuses to their corresponding UI colors.
 */
export class TicketUtil {
  /**
   * Color mapping for ticket statuses.
   * OPEN → Yellow (shown as PENDING in user-facing APIs)
   * SOLVED → Green
   * REJECTED → Red
   */
  private static readonly STATUS_COLOR_MAP: Record<SupportRequestStatus, string> = {
    [SupportRequestStatus.OPEN]: 'yellow',
    [SupportRequestStatus.SOLVED]: 'green',
    [SupportRequestStatus.REJECTED]: 'red',
  };

  /**
   * Get the color for a ticket status.
   * @param status - Ticket status enum value
   * @returns Color name (yellow for OPEN/PENDING, green for SOLVED, red for REJECTED)
   */
  static getStatusColor(status: SupportRequestStatus): string {
    return this.STATUS_COLOR_MAP[status] || 'gray';
  }

  /**
   * Get all status color mappings.
   * Useful for frontend to have a complete mapping reference.
   * @returns Object mapping status to color
   */
  static getStatusColorMap(): Record<SupportRequestStatus, string> {
    return { ...this.STATUS_COLOR_MAP };
  }
}
