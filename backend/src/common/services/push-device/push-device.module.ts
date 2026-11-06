import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PushDeviceEntity } from '@common/database/model';
import { PushDeviceService } from './push-device.service';

@Module({
  imports: [TypeOrmModule.forFeature([PushDeviceEntity])],
  providers: [PushDeviceService],
  exports: [PushDeviceService],
})
export class PushDeviceModule {}
