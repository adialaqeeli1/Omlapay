import { Controller, Get, HttpCode, HttpStatus, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { AboutService } from './about.service';

@ApiTags('Legal & Public Info')
@Controller({ path: 'about', version: '1' })
export class AboutController {
  constructor(private readonly aboutService: AboutService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get About Omlapay information (public endpoint)',
    description:
      'Returns information about Omlapay including description, features, mission, and vision. No authentication required.',
  })
  @ApiQuery({
    name: 'language',
    required: false,
    description: 'Language preference (en or ar). Defaults to English if not specified or if requested language not available.',
    example: 'en',
  })
  @ApiResponse({
    status: 200,
    description: 'About Omlapay information retrieved successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'About Omlapay content not found',
  })
  async getAbout(@Query('language') language?: string) {
    return this.aboutService.getAbout(language);
  }
}
