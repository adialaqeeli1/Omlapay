import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  FaqEntity,
  LegalContentEntity,
  LegalContentType,
} from '@common/database/model';
import { successResponse, errorResponse } from '@common/utils';

/**
 * Service for handling public legal and informational content.
 * All endpoints are public (no authentication required).
 */
@Injectable()
export class LegalService {
  private readonly logger = new Logger(LegalService.name);

  constructor(
    @InjectRepository(FaqEntity)
    private faqRepository: Repository<FaqEntity>,
    @InjectRepository(LegalContentEntity)
    private legalContentRepository: Repository<LegalContentEntity>,
  ) {}

  /**
   * Get all active FAQs.
   * @param language - Optional language filter ('en' or 'ar')
   * @returns List of active FAQs
   */
  async getFaqs(language?: string) {
    try {
      const faqs = await this.faqRepository.find({
        where: { isActive: true },
        order: { createdAt: 'ASC' },
      });

      return successResponse({
        faqs: faqs.map((faq) => ({
          id: faq.id,
          question: faq.question,
          answer: faq.answer,
        })),
      });
    } catch (error) {
      this.logger.error(`Error fetching FAQs: ${(error as Error).message}`);
      throw new NotFoundException(
        errorResponse('Unable to fetch FAQs. Please try again later.'),
      );
    }
  }

  /**
   * Get Terms & Conditions content.
   * @param language - Language preference ('en' or 'ar'), defaults to 'en'
   * @returns Terms & Conditions content
   */
  async getTerms(language: string = 'en') {
    try {
      const terms = await this.legalContentRepository.findOne({
        where: {
          type: LegalContentType.TERMS,
          language: language.toLowerCase(),
          isActive: true,
        },
        order: { createdAt: 'DESC' }, // Get latest version
      });

      // Fallback to English if requested language not found
      if (!terms && language.toLowerCase() !== 'en') {
        const englishTerms = await this.legalContentRepository.findOne({
          where: {
            type: LegalContentType.TERMS,
            language: 'en',
            isActive: true,
          },
          order: { createdAt: 'DESC' },
        });

        if (englishTerms) {
          return successResponse({
            content: englishTerms.content,
            version: englishTerms.version,
            language: englishTerms.language,
          });
        }
      }

      if (!terms) {
        throw new NotFoundException(
          errorResponse('Terms & Conditions content not found.'),
        );
      }

      return successResponse({
        content: terms.content,
        version: terms.version,
        language: terms.language,
      });
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      this.logger.error(
        `Error fetching Terms & Conditions: ${(error as Error).message}`,
      );
      throw new NotFoundException(
        errorResponse('Unable to fetch Terms & Conditions. Please try again later.'),
      );
    }
  }

  /**
   * Get Privacy Policy content.
   * @param language - Language preference ('en' or 'ar'), defaults to 'en'
   * @returns Privacy Policy content
   */
  async getPrivacyPolicy(language: string = 'en') {
    try {
      const privacy = await this.legalContentRepository.findOne({
        where: {
          type: LegalContentType.PRIVACY,
          language: language.toLowerCase(),
          isActive: true,
        },
        order: { createdAt: 'DESC' }, // Get latest version
      });

      // Fallback to English if requested language not found
      if (!privacy && language.toLowerCase() !== 'en') {
        const englishPrivacy = await this.legalContentRepository.findOne({
          where: {
            type: LegalContentType.PRIVACY,
            language: 'en',
            isActive: true,
          },
          order: { createdAt: 'DESC' },
        });

        if (englishPrivacy) {
          return successResponse({
            content: englishPrivacy.content,
            version: englishPrivacy.version,
            language: englishPrivacy.language,
          });
        }
      }

      if (!privacy) {
        throw new NotFoundException(
          errorResponse('Privacy Policy content not found.'),
        );
      }

      return successResponse({
        content: privacy.content,
        version: privacy.version,
        language: privacy.language,
      });
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      this.logger.error(
        `Error fetching Privacy Policy: ${(error as Error).message}`,
      );
      throw new NotFoundException(
        errorResponse('Unable to fetch Privacy Policy. Please try again later.'),
      );
    }
  }
}
