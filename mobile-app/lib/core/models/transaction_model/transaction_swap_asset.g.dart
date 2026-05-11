// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_swap_asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionSwapAsset _$TransactionSwapAssetFromJson(
  Map<String, dynamic> json,
) => _TransactionSwapAsset(
  symbol: json['symbol'] as String?,
  name: json['name'] as String?,
  nameAr: json['name_ar'] as String?,
  iconUrl: json['iconUrl'] as String?,
  amount: json['amount'] as String?,
  amountDisplay: json['amountDisplay'] as String?,
);

Map<String, dynamic> _$TransactionSwapAssetToJson(
  _TransactionSwapAsset instance,
) => <String, dynamic>{
  'symbol': instance.symbol,
  'name': instance.name,
  'name_ar': instance.nameAr,
  'iconUrl': instance.iconUrl,
  'amount': instance.amount,
  'amountDisplay': instance.amountDisplay,
};
