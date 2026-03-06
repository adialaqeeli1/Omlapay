import { Global, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { S3StorageService } from './s3-storage.service';
import type { IStorageService } from './storage.interface';

export { IStorageService, UploadResult, UploadOptions } from './storage.interface';

/**
 * Storage module - S3-only file upload/storage.
 */
@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: 'IStorageService',
      useClass: S3StorageService,
    },
    S3StorageService,
  ],
  exports: ['IStorageService', S3StorageService],
})
export class StorageModule {}
