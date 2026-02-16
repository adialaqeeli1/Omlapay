import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  SupportRequestEntity,
  TicketResponseEntity,
  UserKycEntity,
} from '@common/database/model';
import { TicketListDto } from './dto/ticket-list.dto';
import { AddTicketResponseDto } from './dto/ticket-response.dto';
import { UpdateTicketStatusDto } from './dto/update-ticket-status.dto';
import { MailService } from '@common/services/mail/mail.service';
import { TicketUtil } from '@common/utils/ticket.util';
import { AdminNotificationsService } from '../admin-notifications/admin-notifications.service';
import { AdminNotificationType } from '@common/database/model';

@Injectable()
export class AdminTicketsService {
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
    const { status, fromDate, toDate, page = 1, limit = 10 } = dto;
    const skip = (page - 1) * limit;

    // Build query
    const queryBuilder = this.ticketRepository.createQueryBuilder('ticket');

    // Apply status filter
    if (status) {
      queryBuilder.where('ticket.status = :status', { status });
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

    // Get total count
    const total = await queryBuilder.getCount();

    // Apply pagination and ordering
    const tickets = await queryBuilder
      .leftJoinAndSelect('ticket.user', 'user')
      .orderBy('ticket.createdAt', 'DESC')
      .skip(skip)
      .take(limit)
      .getMany();

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
    const fullName = kyc?.providerPayload
      ? `${(kyc.providerPayload as any)?.info?.firstName || ''} ${
          (kyc.providerPayload as any)?.info?.lastName || ''
        }`.trim() || '—'
      : '—';

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
        // Don't fail if email sending fails
        console.error('Failed to send ticket response email:', error);
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
      // Don't fail if notification fails
      console.error('Failed to notify admins about ticket update:', error);
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
      // Don't fail if notification fails
      console.error('Failed to notify admins about ticket status change:', error);
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
