import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TrustedDeviceEntity } from '@common/database/model';
import { TrustedDeviceService } from './trusted-device.service';

@Module({
  imports: [TypeOrmModule.forFeature([TrustedDeviceEntity])],
  providers: [TrustedDeviceService],
  exports: [TrustedDeviceService],
})
export class TrustedDeviceModule {}
