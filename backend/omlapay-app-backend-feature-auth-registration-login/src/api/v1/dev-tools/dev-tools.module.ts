import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DevToolsController } from './dev-tools.controller';
import { DevToolsService } from './dev-tools.service';
import { UserEntity } from '@common/database/model';
import { UserSecurityEntity } from '@common/database/model';
import { UserSettingsEntity } from '@common/database/model';
import { CoinEntity } from '@common/database/model';
import { WalletEntity } from '@common/database/model';
import { TransactionEntity } from '@common/database/model';
import { NotificationEntity } from '@common/database/model';
import { SwapEntity } from '@common/database/model';
import { UserKycEntity } from '@common/database/model';
import { AuthSessionEntity } from '@common/database/model';
import { OtpRequestEntity } from '@common/database/model';
import { AdminEntity } from '@common/database/model';
import { AdminSecurityEntity } from '@common/database/model';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      UserSecurityEntity,
      UserSettingsEntity,
      CoinEntity,
      WalletEntity,
      TransactionEntity,
      NotificationEntity,
      SwapEntity,
      UserKycEntity,
      AuthSessionEntity,
      OtpRequestEntity,
      AdminEntity,
      AdminSecurityEntity,
    ]),
  ],
  controllers: [DevToolsController],
  providers: [DevToolsService],
})
export class DevToolsModule {}

