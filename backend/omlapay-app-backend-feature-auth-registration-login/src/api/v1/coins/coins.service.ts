import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CoinEntity } from '@common/database/model';
import { successResponse, errorResponse } from '@common/utils';

@Injectable()
export class CoinsService {
  constructor(
    @InjectRepository(CoinEntity)
    private coinRepository: Repository<CoinEntity>,
  ) {}

  async getSupportedCoins() {
    try {
      const coins = await this.coinRepository.find({
        where: { isActive: true },
        order: { name: 'ASC' },
        select: ['id', 'symbol', 'name', 'decimals'],
      });

      return successResponse({
        coins: coins.map((coin) => ({
          id: coin.id,
          symbol: coin.symbol,
          name: coin.name,
          decimals: coin.decimals,
        })),
      });
    } catch (error) {
      throw new InternalServerErrorException(
        errorResponse('Unable to fetch supported coins.'),
      );
    }
  }
}

