import { Global, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DatabaseModule } from './database/database.module';
import { MailModule } from './services/mail/mail.module';
import { OtpModule } from './services/otp/otp.module';
import { BinanceModule } from './services/binance/binance.module';
import { jwtConfig } from './config/jwt.config';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AuthSessionEntity } from './database/model/auth-session.entity';

/**
 * Common Module
 * 
 * This module contains shared infrastructure that is used across all API versions.
 * It includes database, configuration, and shared services.
 */
@Global()
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    JwtModule.registerAsync(jwtConfig()),
    TypeOrmModule.forFeature([AuthSessionEntity]),
    DatabaseModule,
    MailModule,
    OtpModule,
    BinanceModule,
  ],
  providers: [JwtAuthGuard],
  exports: [
    DatabaseModule,
    MailModule,
    OtpModule,
    BinanceModule,
    JwtModule,
    JwtAuthGuard,
    TypeOrmModule, // Export TypeORM to make repositories available globally
  ],
})
export class CommonModule {}
