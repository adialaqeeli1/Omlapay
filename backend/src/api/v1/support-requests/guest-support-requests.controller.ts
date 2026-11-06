import {
  Body,
  Controller,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { ApiHeader, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { ThrottleCodeSend, ThrottleLookup } from '@common/decorators';
import { SupportRequestsService } from './support-requests.service';
import { CreateGuestSupportRequestDto } from './dto/create-support-request.dto';
import { SupportRequestListDto } from './dto/support-request-list.dto';

const GUEST_TOKEN_HEADER = {
  name: 'X-Guest-Token',
  required: false,
  description:
    'Secret guest token returned as data.guest_token by the first guest request (kept by the app in secure storage).',
};

/**
 * Support without an account. A guest is identified only by the server-issued guest token,
 * never by the device identifier the app also sends (shared by phones of the same model).
 */
@ApiTags('Guest support requests')
@Controller({ path: 'guest/support-requests', version: '1' })
export class GuestSupportRequestsController {
  constructor(private readonly supportRequests: SupportRequestsService) {}

  @Post()
  @ThrottleCodeSend()
  @HttpCode(HttpStatus.CREATED)
  @ApiHeader(GUEST_TOKEN_HEADER)
  @ApiOperation({
    summary: 'Send a support request without an account',
    description:
      'Without a known X-Guest-Token, a new token is created and returned once as data.guest_token.',
  })
  @ApiResponse({ status: 201, description: 'Request created' })
  async create(
    @Headers('x-guest-token') guestToken: string | undefined,
    @Body() dto: CreateGuestSupportRequestDto,
  ): Promise<unknown> {
    return this.supportRequests.createGuestSupportRequest(dto, guestToken);
  }

  @Get()
  @ThrottleLookup()
  @ApiHeader(GUEST_TOKEN_HEADER)
  @ApiOperation({
    summary: "This guest's support requests (empty without a known token)",
  })
  async list(
    @Headers('x-guest-token') guestToken: string | undefined,
    @Query() dto: SupportRequestListDto,
  ): Promise<unknown> {
    return this.supportRequests.getGuestSupportRequests(guestToken, dto);
  }

  @Get(':requestId')
  @ThrottleLookup()
  @ApiHeader(GUEST_TOKEN_HEADER)
  @ApiOperation({ summary: "One of this guest's support requests" })
  @ApiResponse({ status: 404, description: 'Not found, or not this guest' })
  async detail(
    @Headers('x-guest-token') guestToken: string | undefined,
    @Param('requestId', ParseUUIDPipe) requestId: string,
  ): Promise<unknown> {
    return this.supportRequests.getGuestSupportRequestDetails(
      guestToken,
      requestId,
    );
  }
}
