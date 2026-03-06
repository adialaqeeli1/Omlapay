import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity, UserKycEntity } from '@common/database/model';
import { UserKycGuardService } from './user-kyc-guard.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([UserEntity, UserKycEntity]),
  ],
  providers: [UserKycGuardService],
  exports: [UserKycGuardService],
})
export class UserKycGuardModule {}
