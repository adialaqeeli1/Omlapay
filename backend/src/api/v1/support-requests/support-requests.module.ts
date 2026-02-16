import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SupportRequestsController } from './support-requests.controller';
import { SupportRequestsService } from './support-requests.service';
import {
  SupportRequestEntity,
  TicketResponseEntity,
  UserEntity,
} from '@common/database/model';
import { JwtAuthGuard } from '@common/guards';
import { AdminNotificationsModule } from '../admin-notifications/admin-notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      SupportRequestEntity,
      TicketResponseEntity,
      UserEntity,
    ]),
    AdminNotificationsModule,
  ],
  controllers: [SupportRequestsController],
  providers: [SupportRequestsService, JwtAuthGuard],
  exports: [SupportRequestsService],
})
export class SupportRequestsModule {}
