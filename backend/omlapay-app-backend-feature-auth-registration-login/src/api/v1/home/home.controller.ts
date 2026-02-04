import { Controller, Get, HttpCode, HttpStatus, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { HomeService } from './home.service';
import { JwtAuthGuard } from '@common/guards';
import { CurrentUser } from '@common/decorators';

@ApiTags('Home')
@Controller({ path: 'home', version: '1' })
export class HomeController {
  constructor(private readonly homeService: HomeService) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get home screen data' })
  @ApiResponse({ status: 200, description: 'Home screen data retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getHomeData(@CurrentUser() user: any) {
    return this.homeService.getHomeData(user.userId);
  }
}

