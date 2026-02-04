import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { UserEntity } from '@common/database/model';
import { UserSecurityEntity } from '@common/database/model';
import { UserSettingsEntity } from '@common/database/model';
import { AuthSessionEntity } from '@common/database/model';
import { OtpRequestEntity } from '@common/database/model';
import { OtpModule } from '@common/services/otp/otp.module';
import { MailModule } from '@common/services/mail/mail.module';
import { jwtConfig } from '@common/config/jwt.config';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      UserSecurityEntity,
      UserSettingsEntity,
      AuthSessionEntity,
      OtpRequestEntity,
    ]),
    JwtModule.registerAsync(jwtConfig('24h')),
    OtpModule,
    MailModule,
  ],
  controllers: [AuthController],
  providers: [AuthService],
  exports: [AuthService],
})
export class AuthModule {}
