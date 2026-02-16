import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminTicketsController } from './admin-tickets.controller';
import { AdminTicketsService } from './admin-tickets.service';
import {
  SupportRequestEntity,
  TicketResponseEntity,
  UserEntity,
  UserKycEntity,
} from '@common/database/model';
import { AdminAuthModule } from '../admin-auth/admin-auth.module';
import { MailModule } from '@common/services/mail/mail.module';
import { AdminNotificationsModule } from '../admin-notifications/admin-notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      SupportRequestEntity,
      TicketResponseEntity,
      UserEntity,
      UserKycEntity,
    ]),
    AdminAuthModule,
    MailModule,
    AdminNotificationsModule,
  ],
  controllers: [AdminTicketsController],
  providers: [AdminTicketsService],
  exports: [AdminTicketsService],
})
export class AdminTicketsModule {}
