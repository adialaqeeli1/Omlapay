import {
  Injectable,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  SupportRequestEntity,
  SupportRequestStatus,
  TicketResponseEntity,
  UserKycEntity,
} from '@common/database/model';
import {
  TicketListDto,
  TicketListSortBy,
  TicketListSortOrder,
} from './dto/ticket-list.dto';
import { AddTicketResponseDto } from './dto/ticket-response.dto';
import { UpdateTicketStatusDto } from './dto/update-ticket-status.dto';
import { MailService } from '@common/services/mail/mail.service';
import { TicketUtil } from '@common/utils/ticket.util';
import { getFullNameFromKyc } from '@common/utils/kyc.util';
import { AdminNotificationsService } from '../admin-notifications/admin-notifications.service';
import { AdminNotificationType } from '@common/database/model';

@Injectable()
export class AdminTicketsService {
  private readonly logger = new Logger(AdminTicketsService.name);

  constructor(
    @InjectRepository(SupportRequestEntity)
    private ticketRepository: Repository<SupportRequestEntity>,
    @InjectRepository(TicketResponseEntity)
    private ticketResponseRepository: Repository<TicketResponseEntity>,
    @InjectRepository(UserKycEntity)
    private userKycRepository: Repository<UserKycEntity>,
    private mailService: MailService,
    private adminNotificationsService: AdminNotificationsService,
  ) {}

  async getTicketList(dto: TicketListDto) {
    const {
      search,
      status,
      fromDate,
      toDate,
      page = 1,
      limit = 10,
      sortBy = TicketListSortBy.CREATED_AT,
      sortOrder = TicketListSortOrder.DESC,
    } = dto;
    const skip = (page - 1) * limit;

    // Build query (base 1=1 so all filters use andWhere)
    const queryBuilder = this.ticketRepository
      .createQueryBuilder('ticket')
      .leftJoinAndSelect('ticket.user', 'user')
      .where('1=1');

    // Apply search (user email, phone, or ticket title)
    if (search && search.trim()) {
      const searchTerm = `%${search.trim()}%`;
      queryBuilder.andWhere(
        '(user.email ILIKE :search OR user.fullMobileNumber ILIKE :search OR ticket.title ILIKE :search)',
        { search: searchTerm },
      );
    }

    // Apply status filter
    if (status) {
      queryBuilder.andWhere('ticket.status = :status', { status });
    }

    // Apply date range filter
    if (fromDate && toDate) {
      queryBuilder.andWhere('ticket.createdAt BETWEEN :fromDate AND :toDate', {
        fromDate,
        toDate,
      });
    } else if (fromDate) {
      queryBuilder.andWhere('ticket.createdAt >= :fromDate', { fromDate });
    } else if (toDate) {
      queryBuilder.andWhere('ticket.createdAt <= :toDate', { toDate });
    }

    // Apply sort
    const orderColumn =
      sortBy === TicketListSortBy.USER
        ? 'user.email'
        : sortBy === TicketListSortBy.TITLE
          ? 'ticket.title'
          : sortBy === TicketListSortBy.STATUS
            ? 'ticket.status'
            : 'ticket.createdAt';
    const orderDir = sortOrder === TicketListSortOrder.ASC ? 'ASC' : 'DESC';
    queryBuilder.orderBy(orderColumn, orderDir);

    // Get total count
    const total = await queryBuilder.getCount();

    // Apply pagination
    const tickets = await queryBuilder.skip(skip).take(limit).getMany();

    // Format tickets
    const formattedTickets = tickets.map((ticket) => ({
      id: ticket.id,
      ticketId: ticket.id.substring(0, 8).toUpperCase(), // Short ticket ID
      title: ticket.title,
      createdDate: ticket.createdAt,
      status: ticket.status,
      statusColor: TicketUtil.getStatusColor(ticket.status), // Color mapping for UI
      userEmail: ticket.user.email || '—',
      userPhone: ticket.user.fullMobileNumber || '—',
    }));

    return {
      tickets: formattedTickets,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Returns count of open (pending) tickets for sidebar badge.
   * Mirrors notifications unread-count pattern.
   */
  async getOpenCount(): Promise<{ openCount: number }> {
    const count = await this.ticketRepository.count({
      where: { status: SupportRequestStatus.OPEN },
    });

    return {
      openCount: count,
    };
  }

  async getTicketDetails(ticketId: string) {
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId },
      relations: ['user'],
    });

    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    // Get all responses
    const responses = await this.ticketResponseRepository.find({
      where: { ticketId: ticket.id },
      relations: ['admin'],
      order: { createdAt: 'ASC' },
    });

    // Get user info
    const user = ticket.user;

    // Derive full name from KYC provider payload if available
    const kyc = await this.userKycRepository.findOne({
      where: { userId: user.id },
    });
    const fullName = getFullNameFromKyc(kyc);

    return {
      ticket: {
        id: ticket.id,
        ticketId: ticket.id.substring(0, 8).toUpperCase(),
        title: ticket.title,
        description: ticket.description,
        status: ticket.status,
        statusColor: TicketUtil.getStatusColor(ticket.status), // Color mapping for UI
        createdAt: ticket.createdAt,
        updatedAt: ticket.updatedAt,
      },
      user: {
        email: user.email || '—',
        phoneNumber: user.fullMobileNumber || '—',
        fullName,
      },
      attachments: ticket.attachmentUrl
        ? ticket.attachmentUrl.split(',').map((rawUrl) => {
            const url = rawUrl.trim();
            return {
              url,
              type: this.getAttachmentType(url),
            };
          })
        : [],
      responses: responses.map((response) => ({
        id: response.id,
        message: response.message,
        isAdmin: !!response.adminId,
        adminId: response.adminId || null,
        createdAt: response.createdAt,
      })),
    };
  }

  async addTicketResponse(
    ticketId: string,
    adminId: string,
    dto: AddTicketResponseDto,
  ) {
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId },
      relations: ['user'],
    });

    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    // Create response
    const response = await this.ticketResponseRepository.save({
      ticketId: ticket.id,
      adminId,
      message: dto.message,
    });

    // Send email to user if email exists
    if (ticket.user.email) {
      try {
        await this.mailService.sendTicketResponse(
          ticket.user.email,
          ticket.title,
          dto.message,
        );
      } catch (error) {
        this.logger.warn(
          `Failed to send ticket response email: ${error instanceof Error ? error.message : 'Unknown error'}`,
        );
      }
    }

    // Notify all admins about ticket update (excluding the admin who responded)
    try {
      await this.adminNotificationsService.notifyAllAdmins(
        AdminNotificationType.TICKET,
        'Ticket Updated',
        `A support ticket has received a new response. Ticket: ${ticket.title} (ID: ${ticket.id.substring(0, 8).toUpperCase()})`,
      );
    } catch (error) {
      this.logger.warn(
        `Failed to notify admins about ticket update: ${error instanceof Error ? error.message : 'Unknown error'}`,
      );
    }

    return {
      message: 'Response added successfully',
      response: {
        id: response.id,
        message: response.message,
        createdAt: response.createdAt,
      },
    };
  }

  async updateTicketStatus(
    ticketId: string,
    adminId: string,
    dto: UpdateTicketStatusDto,
  ) {
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId },
      relations: ['user'],
    });

    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }

    // Update status
    ticket.status = dto.status;
    await this.ticketRepository.save(ticket);

    // Add comment as response if provided
    if (dto.comment) {
      await this.ticketResponseRepository.save({
        ticketId: ticket.id,
        adminId,
        message: dto.comment,
      });
    }

    // Notify all admins about ticket status change
    try {
      const statusMessages = {
        OPEN: 'opened',
        SOLVED: 'solved',
        REJECTED: 'rejected',
      };
      await this.adminNotificationsService.notifyAllAdmins(
        AdminNotificationType.TICKET,
        'Ticket Status Changed',
        `A support ticket status has been updated to ${statusMessages[dto.status] || dto.status}. Ticket: ${ticket.title} (ID: ${ticket.id.substring(0, 8).toUpperCase()})`,
      );
    } catch (error) {
      this.logger.warn(
        `Failed to notify admins about ticket status change: ${error instanceof Error ? error.message : 'Unknown error'}`,
      );
    }

    return {
      message: 'Ticket status updated successfully',
      ticket: {
        id: ticket.id,
        status: ticket.status,
        statusColor: TicketUtil.getStatusColor(ticket.status), // Color mapping for UI
        updatedAt: ticket.updatedAt,
      },
    };
  }

  private getAttachmentType(url: string): 'image' | 'document' {
    const extension = url.split('.').pop()?.toLowerCase();
    const imageExtensions = ['jpg', 'jpeg', 'png'];
    const documentExtensions = ['pdf'];

    if (imageExtensions.includes(extension || '')) {
      return 'image';
    }
    if (documentExtensions.includes(extension || '')) {
      return 'document';
    }
    return 'document'; // Default
  }
}
