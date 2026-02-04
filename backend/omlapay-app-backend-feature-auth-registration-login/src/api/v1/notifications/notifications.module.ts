import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { NotificationEntity } from '@common/database/model';
import { jwtConfig } from '@common/config/jwt.config';

@Module({
  imports: [
    TypeOrmModule.forFeature([NotificationEntity]),
    JwtModule.registerAsync(jwtConfig('7d')),
  ],
  controllers: [NotificationsController],
  providers: [NotificationsService],
})
export class NotificationsModule {}

