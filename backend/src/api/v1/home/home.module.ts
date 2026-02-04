import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { HomeController } from './home.controller';
import { HomeService } from './home.service';
import { UserEntity } from '@common/database/model';
import { WalletEntity } from '@common/database/model';
import { TransactionEntity } from '@common/database/model';
import { NotificationEntity } from '@common/database/model';
import { jwtConfig } from '@common/config/jwt.config';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      WalletEntity,
      TransactionEntity,
      NotificationEntity,
    ]),
    JwtModule.registerAsync(jwtConfig('7d')),
  ],
  controllers: [HomeController],
  providers: [HomeService],
})
export class HomeModule {}

