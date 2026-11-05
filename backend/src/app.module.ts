import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CommonModule } from './common/common.module';
import { V1Module } from './api/v1/v1.module';

/**
 * App Module
 * 
 * Root module that orchestrates the entire application.
 * 
 * Structure:
 * - CommonModule: Shared infrastructure (database, config, services)
 * - V1Module: API version 1 endpoints
 * - V2Module: API version 2 endpoints (future)
 * 
 * This architecture supports:
 * - Clean API versioning
 * - Microservices migration path
 * - Clear separation of concerns
 */
@Module({
  imports: [
    // Rate limit per client IP: 120 requests/minute by default; stricter limits on login,
    // OTP and passcode-reset routes via @ThrottleCodeSend / @ThrottleCredentialCheck / @ThrottleLookup.
    ThrottlerModule.forRoot([{ name: 'default', ttl: 60_000, limit: 120 }]),
    CommonModule,
    V1Module,
  ],
  controllers: [AppController],
  providers: [AppService, { provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class AppModule {}
