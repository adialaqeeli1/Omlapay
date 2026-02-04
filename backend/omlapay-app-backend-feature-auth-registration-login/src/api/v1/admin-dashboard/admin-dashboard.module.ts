import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminDashboardController } from './admin-dashboard.controller';
import { AdminDashboardService } from './admin-dashboard.service';
import { TransactionEntity } from '@common/database/model';
import { UserEntity } from '@common/database/model';
import { UserKycEntity } from '@common/database/model';
import { SwapEntity } from '@common/database/model';
import { AdminAuthModule } from '../admin-auth/admin-auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      TransactionEntity,
      UserEntity,
      UserKycEntity,
      SwapEntity,
    ]),
    AdminAuthModule,
  ],
  controllers: [AdminDashboardController],
  providers: [AdminDashboardService],
  exports: [AdminDashboardService],
})
export class AdminDashboardModule {}
