import {
  Controller,
  Post,
  UseGuards,
  UseInterceptors,
  UploadedFiles,
  BadRequestException,
  HttpCode,
  HttpStatus,
  Query,
} from '@nestjs/common';
import { FileFieldsInterceptor } from '@nestjs/platform-express';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiConsumes,
  ApiBody,
  ApiQuery,
} from '@nestjs/swagger';
import { Inject } from '@nestjs/common';
import { JwtAuthGuard } from '@common/guards';
import { CurrentUser } from '@common/decorators';
import { successResponse, errorResponse } from '@common/utils';
import type { IStorageService } from '@common/services/storage/storage.interface';
import type { MulterFile } from '@common/services/storage/multer-file.interface';

const ALLOWED_PREFIXES: readonly string[] = [
  'support-requests',
  'profile',
  'attachments',
];
const DEFAULT_PREFIX = 'attachments';
const MAX_FILES = 10;

/**
 * Generic file upload controller.
 * Use prefix query param to scope uploads (e.g. support-requests, profile).
 */
@ApiTags('Upload')
@Controller({ path: 'user/upload', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UploadController {
  constructor(
    @Inject('IStorageService')
    private readonly storageService: IStorageService,
  ) {}

  @Post()
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(
    FileFieldsInterceptor([{ name: 'files', maxCount: MAX_FILES }], {
      limits: { fileSize: 5 * 1024 * 1024 }, // 5MB per file
      fileFilter: (_req, file, cb) => {
        const allowed = ['image/png', 'image/jpeg', 'image/jpg', 'application/pdf'];
        cb(null, allowed.includes(file.mimetype));
      },
    }),
  )
  @ApiOperation({
    summary: 'Upload files',
    description:
      'Upload files (PNG, JPG, PDF). Use prefix to scope: support-requests, profile, attachments. Max 10 files, 5MB each.',
  })
  @ApiQuery({
    name: 'prefix',
    required: false,
    enum: ['support-requests', 'profile', 'attachments'],
    description: 'Storage prefix (e.g. support-requests, profile)',
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        files: {
          type: 'array',
          items: { type: 'string', format: 'binary' },
        },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Files uploaded successfully' })
  @ApiResponse({ status: 400, description: 'No files or invalid format' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async upload(
    @CurrentUser() user: any,
    @UploadedFiles() files: { files?: MulterFile[] },
    @Query('prefix') prefix?: string,
  ) {
    const fileList = files?.files;
    if (!fileList || fileList.length === 0) {
      throw new BadRequestException(
        errorResponse(
          'At least one file is required (form field "files"). Allowed: PNG, JPG, JPEG, PDF. Max 5MB per file.',
        ),
      );
    }

    if (fileList.length > MAX_FILES) {
      throw new BadRequestException(
        errorResponse(`Maximum ${MAX_FILES} files allowed per upload.`),
      );
    }

    const resolvedPrefix =
      prefix && ALLOWED_PREFIXES.includes(prefix) ? prefix : DEFAULT_PREFIX;

    try {
      const results = await this.storageService.uploadMultiple(fileList, {
        userId: user.userId,
        prefix: resolvedPrefix,
      });

      const urls = results.map((r) => r.url);
      const attachmentUrl = urls.join(',');

      return successResponse(
        {
          message: 'Files uploaded successfully',
          urls,
          attachmentUrl,
        },
        'Upload complete',
      );
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Upload failed';
      throw new BadRequestException(errorResponse(message));
    }
  }
}
