import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminProfileController } from './admin-profile.controller';
import { AdminProfileService } from './admin-profile.service';
import { AdminEntity } from '@common/database/model';
import { AdminSecurityEntity } from '@common/database/model';
import { AdminOtpEntity } from '@common/database/model';
import { AdminSessionEntity } from '@common/database/model';
import { AdminAuditLogEntity } from '@common/database/model';
import { AdminAuthModule } from '../admin-auth/admin-auth.module';
import { MailModule } from '@common/services/mail/mail.module';
import { OtpModule } from '@common/services/otp/otp.module';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';

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
        signOptions: { expiresIn: '1h' },
      }),
    }),
    AdminAuthModule,
    MailModule,
    OtpModule,
  ],
  controllers: [AdminProfileController],
  providers: [AdminProfileService],
  exports: [AdminProfileService],
})
export class AdminProfileModule {}
