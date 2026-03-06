import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
} from '@nestjs/swagger';
import { SupportRequestsService } from './support-requests.service';
import { CreateSupportRequestDto } from './dto/create-support-request.dto';
import { SupportRequestListDto } from './dto/support-request-list.dto';
import { JwtAuthGuard } from '@common/guards';
import { CurrentUser } from '@common/decorators';

@ApiTags('Support Requests')
@Controller({ path: 'user/support-requests', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SupportRequestsController {
  constructor(
    private readonly supportRequestsService: SupportRequestsService,
  ) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create a new support request',
    description:
      'Submit a new support request with title, description, and optional attachments (PNG, JPG, PDF).',
  })
  @ApiResponse({
    status: 201,
    description: 'Support request created successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'Validation error or invalid file format',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  async createSupportRequest(
    @CurrentUser() user: any,
    @Body() dto: CreateSupportRequestDto,
  ) {
    return this.supportRequestsService.createSupportRequest(user.userId, dto);
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get list of user support requests',
    description:
      'Retrieve paginated list of support requests with optional status filtering. Status options: OPEN (shown as PENDING), SOLVED, REJECTED.',
  })
  @ApiResponse({
    status: 200,
    description: 'Support requests retrieved successfully',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  async getSupportRequests(
    @CurrentUser() user: any,
    @Query() dto: SupportRequestListDto,
  ) {
    return this.supportRequestsService.getSupportRequests(user.userId, dto);
  }

  @Post(':requestId/reopen')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Reopen a solved support request',
    description:
      'Reopens a support request that was previously marked as SOLVED. Rejected tickets cannot be reopened. Only the ticket owner can reopen.',
  })
  @ApiParam({
    name: 'requestId',
    description: 'Support request ID (UUID)',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Support request reopened successfully',
  })
  @ApiResponse({ status: 400, description: 'Request already open or cannot be reopened' })
  @ApiResponse({ status: 404, description: 'Support request not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async reopenSupportRequest(
    @CurrentUser() user: any,
    @Param('requestId', ParseUUIDPipe) requestId: string,
  ) {
    return this.supportRequestsService.reopenSupportRequest(
      user.userId,
      requestId,
    );
  }

  @Get(':requestId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get support request details',
    description:
      'Retrieve detailed information about a specific support request, including admin responses.',
  })
  @ApiParam({
    name: 'requestId',
    description: 'Support request ID (UUID)',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Support request details retrieved successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'Support request not found',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  async getSupportRequestDetails(
    @CurrentUser() user: any,
    @Param('requestId', ParseUUIDPipe) requestId: string,
  ) {
    return this.supportRequestsService.getSupportRequestDetails(
      user.userId,
      requestId,
    );
  }
}
