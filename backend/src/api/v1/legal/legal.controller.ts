import { Controller, Get, HttpCode, HttpStatus, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { LegalService } from './legal.service';

@ApiTags('Legal & Public Info')
@Controller({ path: 'legal', version: '1' })
export class LegalController {
  constructor(private readonly legalService: LegalService) {}

  @Get('faqs')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get all FAQs (public endpoint)',
    description: 'Returns list of frequently asked questions. No authentication required.',
  })
  @ApiQuery({
    name: 'language',
    required: false,
    description: 'Language preference (en or ar). Currently not used but reserved for future multilingual FAQs.',
    example: 'en',
  })
  @ApiResponse({
    status: 200,
    description: 'FAQs retrieved successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'FAQs not found or unable to fetch',
  })
  async getFaqs(@Query('language') language?: string) {
    return this.legalService.getFaqs(language);
  }

  @Get('terms')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get Terms & Conditions (public endpoint)',
    description: 'Returns Terms & Conditions content. No authentication required.',
  })
  @ApiQuery({
    name: 'language',
    required: false,
    description: 'Language preference (en or ar). Defaults to English if not specified or if requested language not available.',
    example: 'en',
  })
  @ApiResponse({
    status: 200,
    description: 'Terms & Conditions retrieved successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'Terms & Conditions not found',
  })
  async getTerms(@Query('language') language?: string) {
    return this.legalService.getTerms(language);
  }

  @Get('privacy')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get Privacy Policy (public endpoint)',
    description: 'Returns Privacy Policy content. No authentication required.',
  })
  @ApiQuery({
    name: 'language',
    required: false,
    description: 'Language preference (en or ar). Defaults to English if not specified or if requested language not available.',
    example: 'en',
  })
  @ApiResponse({
    status: 200,
    description: 'Privacy Policy retrieved successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'Privacy Policy not found',
  })
  async getPrivacyPolicy(@Query('language') language?: string) {
    return this.legalService.getPrivacyPolicy(language);
  }
}
