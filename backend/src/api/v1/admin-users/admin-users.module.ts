import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminUsersController } from './admin-users.controller';
import { AdminUsersService } from './admin-users.service';
import { UserEntity } from '@common/database/model';
import { WalletEntity } from '@common/database/model';
import { TransactionEntity } from '@common/database/model';
import { SwapEntity } from '@common/database/model';
import { UserKycEntity } from '@common/database/model';
import { UserStatusHistoryEntity } from '@common/database/model';
import { AdminAuthModule } from '../admin-auth/admin-auth.module';
import { MailModule } from '@common/services/mail/mail.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      WalletEntity,
      TransactionEntity,
      SwapEntity,
      UserKycEntity,
      UserStatusHistoryEntity,
    ]),
    AdminAuthModule,
    MailModule,
  ],
  controllers: [AdminUsersController],
  providers: [AdminUsersService],
  exports: [AdminUsersService],
})
export class AdminUsersModule {}
