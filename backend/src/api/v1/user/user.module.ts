import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { UserEntity } from '@common/database/model';
import { UserSecurityEntity } from '@common/database/model';
import { AuthSessionEntity } from '@common/database/model';
import { OtpRequestEntity } from '@common/database/model';
import { UserSettingsEntity } from '@common/database/model';
import { UserKycEntity } from '@common/database/model';
import { JwtAuthGuard } from '@common/guards';
import { OtpModule } from '@common/services/otp/otp.module';
import { MailModule } from '@common/services/mail/mail.module';
import { SumsubModule } from '@common/services/sumsub/sumsub.module';
import { BinanceModule } from '@common/services/binance/binance.module';
import { jwtConfig } from '@common/config/jwt.config';
import { AdminNotificationsModule } from '../admin-notifications/admin-notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      UserSecurityEntity,
      AuthSessionEntity,
      OtpRequestEntity,
      UserSettingsEntity,
      UserKycEntity,
    ]),
    JwtModule.registerAsync(jwtConfig('24h')),
    OtpModule,
    MailModule,
    SumsubModule,
    BinanceModule,
    AdminNotificationsModule,
  ],
  controllers: [UserController],
  providers: [UserService, JwtAuthGuard],
  exports: [UserService],
})
export class UserModule {}
