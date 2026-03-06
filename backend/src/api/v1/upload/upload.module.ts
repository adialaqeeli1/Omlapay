import { Module } from '@nestjs/common';
import { UploadController } from './upload.controller';
import { JwtAuthGuard } from '@common/guards';

@Module({
  controllers: [UploadController],
  providers: [JwtAuthGuard],
})
export class UploadModule {}
