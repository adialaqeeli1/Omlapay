// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoinModel _$CoinModelFromJson(Map<String, dynamic> json) => _CoinModel(
  id: json['id'] as String?,
  name: json['name'] as String,
  symbol: json['symbol'] as String,
  amount: json['amount'] as String,
  valueInUsd: json['valueInUsd'] as String,
  change24h: (json['change24h'] as num?)?.toDouble() ?? 0,
  decimals: (json['decimals'] as num?)?.toInt() ?? 0,
  network: json['network'] as String?,
  iconUrl: json['iconUrl'] as String?,
  networkIconUrl: json['networkIconUrl'] as String?,
  contractAddress: json['contractAddress'] as String?,
  minWithdrawal: json['minWithdrawal'] as String?,
  minDeposit: json['minDeposit'] as String?,
  withdrawalFee: json['withdrawalFee'] as String?,
  description: json['description'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  quoteSymbol: json['quoteSymbol'] as String?,
  quoteSymbolAr: json['quoteSymbolAr'] as String?,
  coinSymbolAr: json['symbol_ar'] as String?,
  coinNameAr: json['name_ar'] as String?,
);

Map<String, dynamic> _$CoinModelToJson(_CoinModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'symbol': instance.symbol,
      'amount': instance.amount,
      'valueInUsd': instance.valueInUsd,
      'change24h': instance.change24h,
      'decimals': instance.decimals,
      'network': instance.network,
      'iconUrl': instance.iconUrl,
      'networkIconUrl': instance.networkIconUrl,
      'contractAddress': instance.contractAddress,
      'minWithdrawal': instance.minWithdrawal,
      'minDeposit': instance.minDeposit,
      'withdrawalFee': instance.withdrawalFee,
      'description': instance.description,
      'price': instance.price,
      'quoteSymbol': instance.quoteSymbol,
      'quoteSymbolAr': instance.quoteSymbolAr,
      'symbol_ar': instance.coinSymbolAr,
      'name_ar': instance.coinNameAr,
    };
