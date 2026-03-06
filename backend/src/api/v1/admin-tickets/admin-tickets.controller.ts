import {
  Controller,
  Get,
  Post,
  Param,
  Query,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AdminTicketsService } from './admin-tickets.service';
import { TicketListDto } from './dto/ticket-list.dto';
import { AddTicketResponseDto } from './dto/ticket-response.dto';
import { UpdateTicketStatusDto } from './dto/update-ticket-status.dto';
import { AdminJwtAuthGuard } from '@common/guards';
import { CurrentAdmin } from '@common/decorators';

@ApiTags('Admin Tickets')
@Controller({ path: 'admin/tickets', version: '1' })
@UseGuards(AdminJwtAuthGuard)
@ApiBearerAuth()
export class AdminTicketsController {
  constructor(private readonly adminTicketsService: AdminTicketsService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get ticket list with search, filters, and pagination',
    description:
      'Search by user email/phone or ticket title. Filter by status (Open, Solved, Rejected) and date range. Sort by user, title, createdAt, or status.',
  })
  @ApiResponse({ status: 200, description: 'Ticket list retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getTicketList(@Query() dto: TicketListDto) {
    return this.adminTicketsService.getTicketList(dto);
  }

  @Get('open-count')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get open ticket count for sidebar badge' })
  @ApiResponse({ status: 200, description: 'Open count retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getOpenCount() {
    return this.adminTicketsService.getOpenCount();
  }

  @Get(':ticketId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get ticket details with responses' })
  @ApiResponse({ status: 200, description: 'Ticket details retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Ticket not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getTicketDetails(@Param('ticketId') ticketId: string) {
    return this.adminTicketsService.getTicketDetails(ticketId);
  }

  @Post(':ticketId/response')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Add admin response to ticket (sends email to user)' })
  @ApiResponse({ status: 200, description: 'Response added successfully' })
  @ApiResponse({ status: 404, description: 'Ticket not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addTicketResponse(
    @Param('ticketId') ticketId: string,
    @CurrentAdmin() adminId: string,
    @Body() dto: AddTicketResponseDto,
  ) {
    return this.adminTicketsService.addTicketResponse(ticketId, adminId, dto);
  }

  @Post(':ticketId/status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update ticket status (with optional comment)' })
  @ApiResponse({ status: 200, description: 'Ticket status updated successfully' })
  @ApiResponse({ status: 404, description: 'Ticket not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateTicketStatus(
    @Param('ticketId') ticketId: string,
    @CurrentAdmin() adminId: string,
    @Body() dto: UpdateTicketStatusDto,
  ) {
    return this.adminTicketsService.updateTicketStatus(ticketId, adminId, dto);
  }
}
