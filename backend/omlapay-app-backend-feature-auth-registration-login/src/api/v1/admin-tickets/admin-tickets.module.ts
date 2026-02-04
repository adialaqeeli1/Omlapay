import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminTicketsController } from './admin-tickets.controller';
import { AdminTicketsService } from './admin-tickets.service';
import { SupportRequestEntity } from '@common/database/model';
import { TicketResponseEntity } from '@common/database/model';
import { UserEntity } from '@common/database/model';
import { AdminAuthModule } from '../admin-auth/admin-auth.module';
import { MailModule } from '@common/services/mail/mail.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      SupportRequestEntity,
      TicketResponseEntity,
      UserEntity,
    ]),
    AdminAuthModule,
    MailModule,
  ],
  controllers: [AdminTicketsController],
  providers: [AdminTicketsService],
  exports: [AdminTicketsService],
})
export class AdminTicketsModule {}
