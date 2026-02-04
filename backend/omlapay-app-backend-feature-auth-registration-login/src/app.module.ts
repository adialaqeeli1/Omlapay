import { Module } from '@nestjs/common';
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
    CommonModule,
    V1Module,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
