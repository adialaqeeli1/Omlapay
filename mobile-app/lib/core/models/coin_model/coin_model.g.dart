// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoinModel _$CoinModelFromJson(Map<String, dynamic> json) => _CoinModel(
  name: json['name'] as String,
  symbol: json['symbol'] as String,
  amount: json['amount'] as String,
  valueInUsd: json['valueInUsd'] as String,
  change24h: (json['change24h'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$CoinModelToJson(_CoinModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'amount': instance.amount,
      'valueInUsd': instance.valueInUsd,
      'change24h': instance.change24h,
    };
