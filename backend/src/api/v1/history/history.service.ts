import {
  Injectable,
  BadRequestException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Brackets } from 'typeorm';
import {
  UserEntity,
  TransactionEntity,
  CoinEntity,
} from '@common/database/model';
import {
  TransactionDirection,
  TransactionType,
  TransactionStatus,
} from '@common/database/model';
import {
  successResponse,
  encodeCursor,
  decodeCursor,
  maskAddress,
} from '@common/utils';
import { type AssetFilter } from '@common/constants';
import { HistoryTypeFilter, MAX_DATE_RANGE_MONTHS } from './history.constants';

@Injectable()
export class HistoryService {
  private readonly logger = new Logger(HistoryService.name);

  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(TransactionEntity)
    private transactionRepository: Repository<TransactionEntity>,
    @InjectRepository(CoinEntity)
    private coinRepository: Repository<CoinEntity>,
  ) {}

  /**
   * Unified transaction history: Receive, Send, Failed.
   * Supports asset filter, type filter, date range, pagination.
   */
  async getHistory(
    userId: string,
    query: {
      asset?: AssetFilter;
      type?: HistoryTypeFilter;
      startDate?: string;
      endDate?: string;
      after?: string;
      limit?: number;
    },
  ) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new BadRequestException({
        status: 'error',
        message: 'User not found.',
      });
    }

    const {
      asset = 'ALL',
      type = 'ALL',
      startDate,
      endDate,
      after,
      limit = 50,
    } = query;

    if (startDate && endDate) {
      const start = new Date(startDate);
      const end = new Date(endDate);
      if (start > end) {
        throw new BadRequestException({
          status: 'error',
          message: 'Start date must be earlier than end date.',
        });
      }
      const monthsDiff =
        (end.getFullYear() - start.getFullYear()) * 12 +
        (end.getMonth() - start.getMonth());
      if (monthsDiff > MAX_DATE_RANGE_MONTHS) {
        throw new BadRequestException({
          status: 'error',
          message: `Maximum date range is ${MAX_DATE_RANGE_MONTHS} months.`,
        });
      }
      const now = new Date();
      if (end > now) {
        throw new BadRequestException({
          status: 'error',
          message: 'Future dates are not allowed.',
        });
      }
    }

    const qb = this.transactionRepository
      .createQueryBuilder('tx')
      .leftJoinAndSelect('tx.coin', 'coin')
      .where('tx.userId = :userId', { userId })
      .orderBy('tx.createdAt', 'DESC')
      .addOrderBy('tx.id', 'DESC');

    if (type === 'SENT') {
      qb.andWhere('tx.direction = :dir', { dir: TransactionDirection.OUT });
      qb.andWhere('tx.txType = :txType', { txType: TransactionType.SENT });
    } else if (type === 'RECEIVE') {
      qb.andWhere('tx.direction = :dir', { dir: TransactionDirection.IN });
      qb.andWhere('tx.txType = :txType', { txType: TransactionType.RECEIVED });
    }

    if (asset !== 'ALL') {
      qb.andWhere('coin.symbol = :symbol', { symbol: asset });
    }

    if (startDate) {
      qb.andWhere('tx.createdAt >= :startDate', {
        startDate: new Date(startDate + 'T00:00:00.000Z'),
      });
    }
    if (endDate) {
      qb.andWhere('tx.createdAt <= :endDate', {
        endDate: new Date(endDate + 'T23:59:59.999Z'),
      });
    }

    if (after) {
      const decoded = decodeCursor(after);
      if (decoded) {
        qb.andWhere(
          new Brackets((sub) => {
            sub
              .where('tx.createdAt < :cursorCreatedAt')
              .orWhere('(tx.createdAt = :cursorCreatedAt AND tx.id < :cursorId)');
          }),
          {
            cursorCreatedAt: decoded.timestamp,
            cursorId: decoded.id,
          },
        );
      }
    }

    const transactions = await qb.take(limit + 1).getMany();
    const hasMore = transactions.length > limit;
    if (hasMore) transactions.pop();

    const now = new Date();
    const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);

    const recently: TransactionEntity[] = [];
    const byMonth: Record<string, TransactionEntity[]> = {};

    for (const tx of transactions) {
      if (tx.createdAt >= oneDayAgo) {
        recently.push(tx);
      } else {
        const key = `${tx.createdAt.getFullYear()}-${String(tx.createdAt.getMonth() + 1).padStart(2, '0')}`;
        if (!byMonth[key]) byMonth[key] = [];
        byMonth[key].push(tx);
      }
    }

    const groupedBy: Record<string, TransactionEntity[]> = {
      Recently: recently,
    };

    const months = Object.keys(byMonth).sort().reverse();
    for (const m of months) {
      const [y, mo] = m.split('-');
      const d = new Date(parseInt(y, 10), parseInt(mo, 10) - 1);
      const label = d.toLocaleString('default', {
        month: 'long',
        year: 'numeric',
      });
      groupedBy[label] = byMonth[m] ?? [];
    }

    const formatTx = (tx: TransactionEntity) => {
      const isReceive =
        tx.direction === TransactionDirection.IN &&
        tx.txType === TransactionType.RECEIVED;
      const isFailed = tx.status === TransactionStatus.FAILED;
      const decimals = tx.coin?.decimals ?? 8;
      const amountNum = parseFloat(tx.amount);
      let amountDisplay: string;
      if (isReceive) {
        amountDisplay = `+${amountNum.toFixed(decimals)}`;
      } else {
        amountDisplay = isFailed
          ? `${amountNum.toFixed(decimals)}`
          : `-${amountNum.toFixed(decimals)}`;
      }

      return {
        id: tx.id,
        assetSymbol: tx.coin?.symbol ?? 'UNKNOWN',
        assetName: tx.coin?.name ?? 'Unknown',
        assetIconUrl: tx.coin?.iconUrl ?? null,
        amount: amountDisplay,
        amountRaw: tx.amount,
        direction: tx.direction,
        txType: tx.txType,
        status: tx.status,
        network: tx.network,
        createdAt: tx.createdAt,
        txHash: tx.txHash,
        receiverAddress: maskAddress(tx.receiverAddress),
        counterpartyPhone: tx.counterpartyPhone
          ? maskAddress(tx.counterpartyPhone)
          : null,
      };
    };

    const formatted = transactions.map(formatTx);
    const formattedGroupedBy: Record<string, ReturnType<typeof formatTx>[]> = {};
    for (const [key, txs] of Object.entries(groupedBy)) {
      formattedGroupedBy[key] = txs.map(formatTx);
    }

    let nextCursor: string | null = null;
    if (hasMore && transactions.length > 0) {
      const last = transactions[transactions.length - 1];
      nextCursor = encodeCursor(last.id, last.createdAt);
    }

    return successResponse({
      transactions: formatted,
      groupedBy: formattedGroupedBy,
      pagination: {
        nextCursor,
        hasMore,
        limit,
      },
    });
  }

  /**
   * Get single transaction detail (receive or send).
   */
  async getTransactionDetail(userId: string, transactionId: string) {
    const tx = await this.transactionRepository.findOne({
      where: { id: transactionId, userId },
      relations: ['coin'],
    });

    if (!tx) {
      throw new NotFoundException({
        status: 'error',
        message: 'Transaction not found.',
      });
    }

    const isReceive =
      tx.direction === TransactionDirection.IN &&
      tx.txType === TransactionType.RECEIVED;
    const isFailed = tx.status === TransactionStatus.FAILED;
    const decimals = tx.coin?.decimals ?? 8;
    const amountNum = parseFloat(tx.amount);

    const base = {
      id: tx.id,
      assetSymbol: tx.coin?.symbol ?? 'UNKNOWN',
      assetName: tx.coin?.name ?? 'Unknown',
      amount: tx.amount,
      amountDisplay: isReceive
        ? `+${amountNum.toFixed(decimals)}`
        : isFailed
          ? amountNum.toFixed(decimals)
          : `-${amountNum.toFixed(decimals)}`,
      fee: tx.fee,
      status: tx.status,
      network: tx.network,
      txHash: tx.txHash,
      errorMessage: tx.errorMessage,
      createdAt: tx.createdAt,
      senderAddress: maskAddress(tx.senderAddress),
      receiverAddress: maskAddress(tx.receiverAddress),
      counterpartyPhone: tx.counterpartyPhone
        ? maskAddress(tx.counterpartyPhone)
        : null,
    };

    return successResponse(base);
  }

}
