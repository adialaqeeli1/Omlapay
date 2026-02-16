import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AdminAuthController } from './admin-auth.controller';
import { AdminAuthService } from './admin-auth.service';
import { AdminEntity } from '@common/database/model';
import { AdminSecurityEntity } from '@common/database/model';
import { AdminOtpEntity } from '@common/database/model';
import { AdminSessionEntity } from '@common/database/model';
import { AdminAuditLogEntity } from '@common/database/model';
import { AdminJwtAuthGuard } from '@common/guards';
import { MailModule } from '@common/services/mail/mail.module';
import { OtpModule } from '@common/services/otp/otp.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      AdminEntity,
      AdminSecurityEntity,
      AdminOtpEntity,
      AdminSessionEntity,
      AdminAuditLogEntity,
    ]),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET_KEY'),
        signOptions: { expiresIn: configService.get<string>('JWT_EXP_TIME') },
      }),
    }),
    MailModule,
    OtpModule,
  ],
  controllers: [AdminAuthController],
  providers: [AdminAuthService, AdminJwtAuthGuard],
  exports: [AdminAuthService, AdminJwtAuthGuard],
})
export class AdminAuthModule {}

