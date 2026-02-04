import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import { SupportRequestEntity, SupportRequestStatus } from '@common/database/model';
import { TicketResponseEntity } from '@common/database/model';
import { UserEntity } from '@common/database/model';
import { TicketListDto } from './dto/ticket-list.dto';
import { AddTicketResponseDto } from './dto/ticket-response.dto';
import { UpdateTicketStatusDto } from './dto/update-ticket-status.dto';
import { MailService } from '@common/services/mail/mail.service';

@Injectable()
export class AdminTicketsService {
  constructor(
    @InjectRepository(SupportRequestEntity)
    private ticketRepository: Repository<SupportRequestEntity>,
    @InjectRepository(TicketResponseEntity)
    private ticketResponseRepository: Repository<TicketResponseEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    private mailService: MailService,
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

    return {
      ticket: {
        id: ticket.id,
        ticketId: ticket.id.substring(0, 8).toUpperCase(),
        title: ticket.title,
        description: ticket.description,
        status: ticket.status,
        createdAt: ticket.createdAt,
        updatedAt: ticket.updatedAt,
      },
      user: {
        email: user.email || '—',
        phoneNumber: user.fullMobileNumber || '—',
        fullName: '—', // Will be fetched from 3rd party KYC if available
      },
      attachments: ticket.attachmentUrl
        ? [
            {
              url: ticket.attachmentUrl,
              type: this.getAttachmentType(ticket.attachmentUrl),
            },
          ]
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

    return {
      message: 'Ticket status updated successfully',
      ticket: {
        id: ticket.id,
        status: ticket.status,
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
