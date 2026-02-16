import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LegalController } from './legal.controller';
import { LegalService } from './legal.service';
import {
  FaqEntity,
  LegalContentEntity,
} from '@common/database/model';

@Module({
  imports: [
    TypeOrmModule.forFeature([FaqEntity, LegalContentEntity]),
  ],
  controllers: [LegalController],
  providers: [LegalService],
  exports: [LegalService],
})
export class LegalModule {}
