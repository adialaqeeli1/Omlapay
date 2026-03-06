import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  CoinEntity,
  TransactionEntity,
  WalletEntity,
} from '@common/database/model';
import { TransactionDirection, TransactionType } from '@common/database/model';
import { successResponse, encodeCursor, decodeCursor, maskAddress } from '@common/utils';

@Injectable()
export class SendHistoryUseCase {
  constructor(
    @InjectRepository(CoinEntity)
    private coinRepository: Repository<CoinEntity>,
    @InjectRepository(TransactionEntity)
    private transactionRepository: Repository<TransactionEntity>,
    @InjectRepository(WalletEntity)
    private walletRepository: Repository<WalletEntity>,
  ) {}

  async execute(
    userId: string,
    query: { asset?: string; after?: string; limit?: number },
  ) {
    const { asset = 'ALL', after, limit = 20 } = query;

    const qb = this.transactionRepository
      .createQueryBuilder('tx')
      .leftJoinAndSelect('tx.coin', 'coin')
      .where('tx.userId = :userId', { userId })
      .andWhere('tx.direction = :direction', {
        direction: TransactionDirection.OUT,
      })
      .andWhere('tx.txType = :txType', { txType: TransactionType.SENT })
      .orderBy('tx.createdAt', 'DESC')
      .addOrderBy('tx.id', 'DESC');

    if (asset !== 'ALL') {
      qb.andWhere('coin.symbol = :symbol', { symbol: asset });
    }

    if (after) {
      const decoded = decodeCursor(after);
      if (decoded) {
        qb.andWhere(
          '(tx.createdAt < :cursorCreatedAt OR (tx.createdAt = :cursorCreatedAt AND tx.id < :cursorId))',
          { cursorCreatedAt: decoded.timestamp, cursorId: decoded.id },
        );
      }
    }

    const transactions = await qb.take((limit ?? 20) + 1).getMany();
    const hasMore = transactions.length > limit;
    if (hasMore) transactions.pop();

    const items = transactions.map((tx) => ({
      id: tx.id,
      coinSymbol: tx.coin.symbol,
      amount: tx.amount,
      fee: tx.fee,
      status: tx.status,
      network: tx.network,
      receiverAddress: maskAddress(tx.receiverAddress),
      counterpartyPhone: tx.counterpartyPhone
        ? maskAddress(tx.counterpartyPhone)
        : null,
      createdAt: tx.createdAt,
    }));

    return successResponse({
      items,
      hasMore,
      nextCursor:
        hasMore && items.length > 0
          ? encodeCursor(items[items.length - 1].id, items[items.length - 1].createdAt)
          : null,
    });
  }
}
