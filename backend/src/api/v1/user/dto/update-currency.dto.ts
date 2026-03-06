import { IsEnum, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { DisplayCurrency } from '@common/database/model';

export class UpdateCurrencyDto {
  @ApiProperty({
    enum: DisplayCurrency,
    example: 'usd',
    description: 'Display currency for balance and prices (USD or SAR)',
  })
  @IsEnum(DisplayCurrency)
  @IsNotEmpty()
  currency: DisplayCurrency;
}
