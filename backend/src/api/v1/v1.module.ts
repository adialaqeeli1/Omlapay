import { Module } from '@nestjs/common';
import { UserModule } from './user/user.module';
import { AuthModule } from './auth/auth.module';
import { HomeModule } from './home/home.module';
import { NotificationsModule } from './notifications/notifications.module';
import { DevToolsModule } from './dev-tools/dev-tools.module';
import { CoinsModule } from './coins/coins.module';
import { LegalModule } from './legal/legal.module';
import { AboutModule } from './about/about.module';
import { SupportRequestsModule } from './support-requests/support-requests.module';
import { AdminAuthModule } from './admin-auth/admin-auth.module';
import { AdminDashboardModule } from './admin-dashboard/admin-dashboard.module';
import { AdminProfileModule } from './admin-profile/admin-profile.module';
import { AdminUsersModule } from './admin-users/admin-users.module';
import { AdminTicketsModule } from './admin-tickets/admin-tickets.module';
import { AdminNotificationsModule } from './admin-notifications/admin-notifications.module';

/**
 * V1 API Module
 * 
 * Contains all version 1 endpoints.
 * All routes are prefixed with /v1/ automatically via NestJS versioning
 * configured in main.ts and controller decorators.
 */
@Module({
  imports: [
    // User-facing modules
    UserModule,
    AuthModule,
    HomeModule,
    NotificationsModule,
    CoinsModule,
    LegalModule,
    AboutModule,
    SupportRequestsModule,
    
    // Admin modules
    AdminAuthModule,
    AdminDashboardModule,
    AdminProfileModule,
    AdminUsersModule,
    AdminTicketsModule,
    AdminNotificationsModule,
    
    // Development tools
    DevToolsModule,
  ],
})
export class V1Module {}
