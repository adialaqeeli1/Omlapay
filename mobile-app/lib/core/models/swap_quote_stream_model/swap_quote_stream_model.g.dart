// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_quote_stream_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SwapQuoteStreamModel _$SwapQuoteStreamModelFromJson(
  Map<String, dynamic> json,
) => _SwapQuoteStreamModel(
  fromCoin: json['fromCoin'] as String? ?? '',
  toCoin: json['toCoin'] as String? ?? '',
  exchangeRate: json['exchangeRate'] as String? ?? '',
  inverseRate: json['inverseRate'] as String? ?? '',
  youPay: json['youPay'] as String? ?? '',
  youPayCoin: json['youPayCoin'] as String? ?? '',
  youReceive: json['youReceive'] as String? ?? '',
  youReceiveCoin: json['youReceiveCoin'] as String? ?? '',
  available: json['available'] as String? ?? '',
  minFromAmount: json['minFromAmount'] as String? ?? '',
  maxFromAmount: json['maxFromAmount'] as String? ?? '',
  fees: json['fees'] == null
      ? null
      : SwapQuoteStreamFees.fromJson(json['fees'] as Map<String, dynamic>),
  pay: json['pay'] == null
      ? null
      : SwapQuoteStreamPay.fromJson(json['pay'] as Map<String, dynamic>),
  receive: json['receive'] == null
      ? null
      : SwapQuoteStreamReceive.fromJson(
          json['receive'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SwapQuoteStreamModelToJson(
  _SwapQuoteStreamModel instance,
) => <String, dynamic>{
  'fromCoin': instance.fromCoin,
  'toCoin': instance.toCoin,
  'exchangeRate': instance.exchangeRate,
  'inverseRate': instance.inverseRate,
  'youPay': instance.youPay,
  'youPayCoin': instance.youPayCoin,
  'youReceive': instance.youReceive,
  'youReceiveCoin': instance.youReceiveCoin,
  'available': instance.available,
  'minFromAmount': instance.minFromAmount,
  'maxFromAmount': instance.maxFromAmount,
  'fees': instance.fees,
  'pay': instance.pay,
  'receive': instance.receive,
};

_SwapQuoteStreamFees _$SwapQuoteStreamFeesFromJson(Map<String, dynamic> json) =>
    _SwapQuoteStreamFees(
      omlapay: json['omlapay'] == null
          ? null
          : SwapQuoteFeeEntry.fromJson(json['omlapay'] as Map<String, dynamic>),
      binance: json['binance'] == null
          ? null
          : SwapQuoteFeeEntry.fromJson(json['binance'] as Map<String, dynamic>),
      total: json['total'] == null
          ? null
          : SwapQuoteFeeEntry.fromJson(json['total'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SwapQuoteStreamFeesToJson(
  _SwapQuoteStreamFees instance,
) => <String, dynamic>{
  'omlapay': instance.omlapay,
  'binance': instance.binance,
  'total': instance.total,
};

_SwapQuoteFeeEntry _$SwapQuoteFeeEntryFromJson(Map<String, dynamic> json) =>
    _SwapQuoteFeeEntry(
      percent: json['percent'] as String? ?? '',
      fromCoinAmount: json['fromCoinAmount'] as String? ?? '',
      toCoinAmount: json['toCoinAmount'] as String? ?? '',
      usd: json['usd'] as String? ?? '',
    );

Map<String, dynamic> _$SwapQuoteFeeEntryToJson(_SwapQuoteFeeEntry instance) =>
    <String, dynamic>{
      'percent': instance.percent,
      'fromCoinAmount': instance.fromCoinAmount,
      'toCoinAmount': instance.toCoinAmount,
      'usd': instance.usd,
    };

_SwapQuoteStreamPay _$SwapQuoteStreamPayFromJson(Map<String, dynamic> json) =>
    _SwapQuoteStreamPay(
      coin: json['coin'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      amountUsd: json['amountUsd'] as String? ?? '',
    );

Map<String, dynamic> _$SwapQuoteStreamPayToJson(_SwapQuoteStreamPay instance) =>
    <String, dynamic>{
      'coin': instance.coin,
      'amount': instance.amount,
      'amountUsd': instance.amountUsd,
    };

_SwapQuoteStreamReceive _$SwapQuoteStreamReceiveFromJson(
  Map<String, dynamic> json,
) => _SwapQuoteStreamReceive(
  coin: json['coin'] as String? ?? '',
  grossAmount: json['grossAmount'] as String? ?? '',
  grossAmountUsd: json['grossAmountUsd'] as String? ?? '',
  netAmount: json['netAmount'] as String? ?? '',
  netAmountUsd: json['netAmountUsd'] as String? ?? '',
);

Map<String, dynamic> _$SwapQuoteStreamReceiveToJson(
  _SwapQuoteStreamReceive instance,
) => <String, dynamic>{
  'coin': instance.coin,
  'grossAmount': instance.grossAmount,
  'grossAmountUsd': instance.grossAmountUsd,
  'netAmount': instance.netAmount,
  'netAmountUsd': instance.netAmountUsd,
};
