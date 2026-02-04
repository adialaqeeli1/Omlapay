import { Module } from '@nestjs/common';
import { SumsubService } from './sumsub.service';

/** Sumsub KYC: SDK tokens, applicant lookup, webhook verification. */
@Module({
  providers: [SumsubService],
  exports: [SumsubService],
})
export class SumsubModule {}

