import { Global, Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SystemSettingsEntity } from '@common/database/model';
import { SystemSettingsService } from './system-settings.service';

@Global()
@Module({
  imports: [TypeOrmModule.forFeature([SystemSettingsEntity])],
  providers: [SystemSettingsService],
  exports: [SystemSettingsService],
})
export class SystemSettingsModule {}
