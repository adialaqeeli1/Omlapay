import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AboutEntity } from '@common/database/model';
import { successResponse, errorResponse } from '@common/utils';

/**
 * Service for handling About Omlapay content.
 * Public endpoint (no authentication required).
 */
@Injectable()
export class AboutService {
  private readonly logger = new Logger(AboutService.name);

  constructor(
    @InjectRepository(AboutEntity)
    private aboutRepository: Repository<AboutEntity>,
  ) {}

  /**
   * Get About Omlapay content.
   * @param language - Language preference ('en' or 'ar'), defaults to 'en'
   * @returns About Omlapay content including description and features
   */
  async getAbout(language: string = 'en') {
    try {
      const about = await this.aboutRepository.findOne({
        where: {
          language: language.toLowerCase(),
          isActive: true,
        },
        order: { createdAt: 'DESC' }, // Get latest version
      });

      // Fallback to English if requested language not found
      if (!about && language.toLowerCase() !== 'en') {
        const englishAbout = await this.aboutRepository.findOne({
          where: {
            language: 'en',
            isActive: true,
          },
          order: { createdAt: 'DESC' },
        });

        if (englishAbout) {
          return successResponse({
            description: englishAbout.description,
            features: englishAbout.features || [],
            mission: englishAbout.mission,
            vision: englishAbout.vision,
            language: englishAbout.language,
          });
        }
      }

      if (!about) {
        throw new NotFoundException(
          errorResponse('About Omlapay content not found.'),
        );
      }

      return successResponse({
        description: about.description,
        features: about.features || [],
        mission: about.mission,
        vision: about.vision,
        language: about.language,
      });
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      this.logger.error(
        `Error fetching About Omlapay: ${(error as Error).message}`,
      );
      throw new NotFoundException(
        errorResponse('Unable to fetch About Omlapay. Please try again later.'),
      );
    }
  }
}
