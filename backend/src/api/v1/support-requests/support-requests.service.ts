import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  SupportRequestEntity,
  SupportRequestStatus,
  TicketResponseEntity,
  UserEntity,
  AdminNotificationType,
} from '@common/database/model';
import { CreateSupportRequestDto } from './dto/create-support-request.dto';
import { SupportRequestListDto } from './dto/support-request-list.dto';
import { TicketUtil } from '@common/utils/ticket.util';
import {
  successResponse,
  errorResponse,
  validateUUID,
} from '@common/utils';
import { AdminNotificationsService } from '../admin-notifications/admin-notifications.service';

/**
 * Service for managing user-facing support requests.
 * Handles creation, listing, and retrieval of support requests.
 */
@Injectable()
export class SupportRequestsService {
  private readonly logger = new Logger(SupportRequestsService.name);

  constructor(
    @InjectRepository(SupportRequestEntity)
    private supportRequestRepository: Repository<SupportRequestEntity>,
    @InjectRepository(TicketResponseEntity)
    private ticketResponseRepository: Repository<TicketResponseEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    private adminNotificationsService: AdminNotificationsService,
  ) {}

  /**
   * Create a new support request for the authenticated user.
   * @param userId - ID of the user creating the request
   * @param dto - Support request data (title, description, optional attachment)
   * @returns Created support request with success response
   */
  async createSupportRequest(
    userId: string,
    dto: CreateSupportRequestDto,
  ): Promise<any> {
    try {
      // Validate attachment URLs if provided
      if (dto.attachmentUrl) {
        this.validateAttachmentUrls(dto.attachmentUrl);
      }

      // Create new support request
      const supportRequest = this.supportRequestRepository.create({
        userId,
        title: dto.title,
        description: dto.description,
        attachmentUrl: dto.attachmentUrl || null,
        status: SupportRequestStatus.OPEN,
      });

      const savedRequest = await this.supportRequestRepository.save(supportRequest);

      // Notify all admins about the new support request
      try {
        const user = await this.userRepository.findOne({
          where: { id: userId },
          select: ['fullMobileNumber', 'email'],
        });

        const userIdentifier = user?.email || user?.fullMobileNumber || 'Unknown User';
        await this.adminNotificationsService.notifyAllAdmins(
          AdminNotificationType.TICKET,
          'New Support Ticket',
          `A new support ticket has been created by user ${userIdentifier}. Title: ${savedRequest.title} (ID: ${savedRequest.id.substring(0, 8).toUpperCase()})`,
        );
      } catch (notificationError) {
        // Log error but don't fail the request creation
        this.logger.error(
          'Failed to notify admins about new support request',
          notificationError,
        );
      }

      // Format response with user-friendly status mapping
      return successResponse({
        message: 'Support request submitted successfully',
        request: {
          id: savedRequest.id,
          title: savedRequest.title,
          description: savedRequest.description,
          status: this.mapStatusForUser(savedRequest.status),
          statusColor: TicketUtil.getStatusColor(savedRequest.status),
          attachmentUrl: savedRequest.attachmentUrl,
          createdAt: savedRequest.createdAt,
        },
      });
    } catch (error) {
      this.logger.error('Failed to create support request', error);
      throw new BadRequestException(
        errorResponse('Failed to send your request. Please try again later.'),
      );
    }
  }

  /**
   * Get list of support requests for the authenticated user.
   * Supports filtering by status and pagination.
   * @param userId - ID of the user
   * @param dto - Filter and pagination parameters
   * @returns Paginated list of support requests
   */
  async getSupportRequests(
    userId: string,
    dto: SupportRequestListDto,
  ): Promise<any> {
    try {
      const { status, page = 1, limit = 10 } = dto;
      const skip = (page - 1) * limit;

      // Build query
      const queryBuilder = this.supportRequestRepository
        .createQueryBuilder('request')
        .where('request.userId = :userId', { userId });

      // Apply status filter
      if (status) {
        queryBuilder.andWhere('request.status = :status', { status });
      }

      // Get total count
      const total = await queryBuilder.getCount();

      // Apply pagination and ordering
      const requests = await queryBuilder
        .orderBy('request.createdAt', 'DESC')
        .skip(skip)
        .take(limit)
        .getMany();

      // Format requests with user-friendly status mapping
      const formattedRequests = requests.map((request) => ({
        id: request.id,
        title: request.title,
        status: this.mapStatusForUser(request.status),
        statusColor: TicketUtil.getStatusColor(request.status),
        createdAt: request.createdAt,
      }));

      return successResponse({
        requests: formattedRequests,
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
        },
      });
    } catch (error) {
      this.logger.error('Failed to fetch support requests', error);
      throw new BadRequestException(
        errorResponse('Failed to fetch requests. Please try again later.'),
      );
    }
  }

  /**
   * Get details of a specific support request.
   * Includes ticket responses from admins.
   * @param userId - ID of the user
   * @param requestId - ID of the support request
   * @returns Support request details with responses
   */
  async getSupportRequestDetails(
    userId: string,
    requestId: string,
  ): Promise<any> {
    try {
      // Validate input using utility functions
      validateUUID(userId, 'User ID');
      validateUUID(requestId, 'Request ID');

      // Find support request belonging to the user
      const request = await this.supportRequestRepository.findOne({
        where: { id: requestId, userId },
      });

      if (!request) {
        throw new NotFoundException({
          status: 'error',
          message: 'Support request not found.',
        });
      }

      // Get admin responses for this request
      const responses = await this.ticketResponseRepository.find({
        where: { ticketId: request.id },
        order: { createdAt: 'ASC' },
      });

      // Format attachment URLs if present
      const attachments = request.attachmentUrl
        ? request.attachmentUrl.split(',').map((url) => ({
            url: url.trim(),
            type: this.getAttachmentType(url.trim()),
          }))
        : [];

      // Format response
      return successResponse({
        request: {
          id: request.id,
          title: request.title,
          description: request.description,
          status: this.mapStatusForUser(request.status),
          statusColor: TicketUtil.getStatusColor(request.status),
          attachments,
          createdAt: request.createdAt,
          updatedAt: request.updatedAt,
          responses: responses.map((response) => ({
            id: response.id,
            message: response.message,
            createdAt: response.createdAt,
            isAdminResponse: !!response.adminId,
          })),
        },
      });
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      this.logger.error('Failed to fetch support request details', error);
      throw new BadRequestException(
        errorResponse('Failed to fetch request details. Please try again later.'),
      );
    }
  }

  /**
   * Validate attachment URLs format and file types.
   * @param attachmentUrl - Comma-separated URLs
   * @throws BadRequestException if validation fails
   */
  private validateAttachmentUrls(attachmentUrl: string): void {
    const urls = attachmentUrl.split(',').map((url) => url.trim());
    const allowedExtensions = ['.png', '.jpg', '.jpeg', '.pdf'];

    for (const url of urls) {
      // Check if URL is valid
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        throw new BadRequestException(
          errorResponse('Invalid file format. Please upload PNG, JPG, or PDF only.'),
        );
      }

      // Check file extension
      const hasValidExtension = allowedExtensions.some((ext) =>
        url.toLowerCase().endsWith(ext),
      );

      if (!hasValidExtension) {
        throw new BadRequestException(
          errorResponse('Invalid file format. Please upload PNG, JPG, or PDF only.'),
        );
      }
    }
  }

  /**
   * Map database status to user-friendly status.
   * OPEN → PENDING for user-facing APIs.
   * @param status - Database status enum
   * @returns User-friendly status string
   */
  private mapStatusForUser(status: SupportRequestStatus): string {
    // Map OPEN to PENDING for user-facing responses
    if (status === SupportRequestStatus.OPEN) {
      return 'PENDING';
    }
    return status;
  }

  /**
   * Get attachment type from URL.
   * @param url - File URL
   * @returns 'image' or 'document'
   */
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
