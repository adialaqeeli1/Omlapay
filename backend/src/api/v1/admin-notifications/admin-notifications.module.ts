import { Global, Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminNotificationsController } from './admin-notifications.controller';
import { AdminNotificationsService } from './admin-notifications.service';
import {
  AdminNotificationEntity,
  AdminEntity,
} from '@common/database/model';
import { AdminAuthModule } from '../admin-auth/admin-auth.module';
import { IAdminNotifier } from '@common/services/admin-notifier/admin-notifier.interface';

@Global()
@Module({
  imports: [
    TypeOrmModule.forFeature([AdminNotificationEntity, AdminEntity]),
    AdminAuthModule,
  ],
  controllers: [AdminNotificationsController],
  providers: [
    AdminNotificationsService,
    {
      provide: IAdminNotifier,
      useExisting: AdminNotificationsService,
    },
  ],
  exports: [AdminNotificationsService, IAdminNotifier],
})
export class AdminNotificationsModule {}
