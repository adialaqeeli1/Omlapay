import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminFeesController } from './admin-fees.controller';
import { AdminFeesService } from './admin-fees.service';
import {
  AdminEntity,
  AdminOtpEntity,
  AdminAuditLogEntity,
  TransactionEntity,
  SwapEntity,
  UserEntity,
} from '@common/database/model';
import { MailModule } from '@common/services/mail/mail.module';
import { SuperAdminGuard } from '@common/guards';
import { AdminAuthModule } from '../admin-auth/admin-auth.module';

/** Depends on SystemSettingsModule and BinanceModule (via CommonModule @Global). */
@Module({
  imports: [
    AdminAuthModule,
    TypeOrmModule.forFeature([
      AdminEntity,
      AdminOtpEntity,
      AdminAuditLogEntity,
      TransactionEntity,
      SwapEntity,
      UserEntity,
    ]),
    MailModule,
  ],
  controllers: [AdminFeesController],
  providers: [AdminFeesService, SuperAdminGuard],
  exports: [AdminFeesService],
})
export class AdminFeesModule {}
