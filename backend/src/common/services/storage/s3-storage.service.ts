import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  S3Client,
  PutObjectCommand,
  PutObjectCommandInput,
} from '@aws-sdk/client-s3';
import { randomUUID } from 'crypto';
import * as path from 'path';
import type {
  IStorageService,
  UploadResult,
  UploadOptions,
} from './storage.interface';
import type { MulterFile } from './multer-file.interface';
import { getStorageRoot } from './storage-path.util';

const ALLOWED_MIME_TYPES = [
  'image/png',
  'image/jpeg',
  'image/jpg',
  'application/pdf',
];

const MIME_TO_EXT: Record<string, string> = {
  'image/png': 'png',
  'image/jpeg': 'jpeg',
  'image/jpg': 'jpg',
  'application/pdf': 'pdf',
};

const MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024; // 5MB

/**
 * AWS S3 storage implementation.
 * Stores files in an S3 bucket and returns public URLs.
 * Requires: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, S3_BUCKET_NAME.
 * Optional: AWS_REGION, S3_PUBLIC_URL (for CloudFront/custom domain).
 */
@Injectable()
export class S3StorageService implements IStorageService {
  private readonly logger = new Logger(S3StorageService.name);
  private readonly s3Client: S3Client;
  private readonly bucket: string;
  private readonly region: string;
  private readonly publicUrlBase: string;

  constructor(private configService: ConfigService) {
    const accessKeyId = this.configService.get<string>('AWS_ACCESS_KEY_ID');
    const secretAccessKey =
      this.configService.get<string>('AWS_SECRET_ACCESS_KEY');
    this.bucket = this.configService.get<string>('S3_BUCKET_NAME') || '';
    this.region =
      this.configService.get<string>('AWS_REGION') || 'us-east-1';

    if (!accessKeyId || !secretAccessKey || !this.bucket) {
      throw new Error(
        'S3 storage requires AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and S3_BUCKET_NAME',
      );
    }

    this.s3Client = new S3Client({
      region: this.region,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
    });

    const customBase = this.configService.get<string>('S3_PUBLIC_URL');
    this.publicUrlBase =
      customBase?.replace(/\/$/, '') ||
      `https://${this.bucket}.s3.${this.region}.amazonaws.com`;

    this.logger.log(
      `S3 storage initialized: bucket=${this.bucket}, region=${this.region}`,
    );
  }

  async upload(file: MulterFile, options?: UploadOptions): Promise<UploadResult> {
    this.validateFile(file);

    const ext = MIME_TO_EXT[file.mimetype] || this.getExtFromFilename(file.originalname);
    const key = this.buildKey(options, ext);

    const body = file.buffer ?? (file.path ? await this.readFileBuffer(file.path) : null);
    if (!body) {
      throw new Error('Invalid file: no buffer or path');
    }

    const params: PutObjectCommandInput = {
      Bucket: this.bucket,
      Key: key,
      Body: body,
      ContentType: file.mimetype,
      CacheControl: 'max-age=31536000',
    };

    await this.s3Client.send(new PutObjectCommand(params));

    const url = `${this.publicUrlBase}/${key.replace(/\\/g, '/')}`;

    this.logger.log(`File uploaded to S3: ${key} -> ${url}`);

    return {
      url,
      key,
      filename: file.originalname,
      mimetype: file.mimetype,
      size: file.size,
    };
  }

  async uploadMultiple(
    files: MulterFile[],
    options?: UploadOptions,
  ): Promise<UploadResult[]> {
    const results: UploadResult[] = [];
    for (const file of files) {
      const result = await this.upload(file, options);
      results.push(result);
    }
    return results;
  }

  private async readFileBuffer(filePath: string): Promise<Buffer> {
    const fs = await import('fs/promises');
    return fs.readFile(filePath);
  }

  private validateFile(file: MulterFile): void {
    if (!file) {
      throw new Error('Invalid file: missing file object');
    }
    const hasContent = file.path || (file.buffer && file.buffer.length > 0);
    if (!hasContent) {
      throw new Error('Invalid file: missing file content');
    }
    if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
      throw new Error(
        `Invalid file type: ${file.mimetype}. Allowed: PNG, JPG, JPEG, PDF`,
      );
    }
    if (file.size > MAX_FILE_SIZE_BYTES) {
      throw new Error(`File too large: max 5MB allowed`);
    }
  }

  private buildKey(options?: UploadOptions, ext?: string): string {
    const root = getStorageRoot(this.configService.get<string>('NODE_ENV'));
    const parts: string[] = [root];
    if (options?.prefix) {
      parts.push(options.prefix);
    }
    if (options?.userId) {
      parts.push(options.userId);
    }
    parts.push(`${randomUUID()}.${ext || 'bin'}`);
    return parts.join('/');
  }

  private getExtFromFilename(filename: string): string {
    const ext = path.extname(filename).slice(1).toLowerCase();
    return ['png', 'jpg', 'jpeg', 'pdf'].includes(ext) ? ext : 'bin';
  }
}
