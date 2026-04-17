// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_quote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SwapQuoteModel _$SwapQuoteModelFromJson(Map<String, dynamic> json) =>
    _SwapQuoteModel(
      fromCoin: json['fromCoin'] as String? ?? '',
      toCoin: json['toCoin'] as String? ?? '',
      fromAmount: json['fromAmount'] as String? ?? '',
      fromAmountUsd: json['fromAmountUsd'] as String? ?? '',
      estimatedToAmount: json['estimatedToAmount'] as String? ?? '',
      estimatedToAmountUsd: json['estimatedToAmountUsd'] as String? ?? '',
      exchangeRate: json['exchangeRate'] as String? ?? '',
      binanceFee: json['binanceFee'] as String? ?? '',
      omlapayFee: json['omlapayFee'] as String? ?? '',
      totalFee: json['totalFee'] as String? ?? '',
      available: json['available'] as String? ?? '',
      minFromAmount: json['minFromAmount'] as String? ?? '',
      maxFromAmount: json['maxFromAmount'] as String? ?? '',
    );

Map<String, dynamic> _$SwapQuoteModelToJson(_SwapQuoteModel instance) =>
    <String, dynamic>{
      'fromCoin': instance.fromCoin,
      'toCoin': instance.toCoin,
      'fromAmount': instance.fromAmount,
      'fromAmountUsd': instance.fromAmountUsd,
      'estimatedToAmount': instance.estimatedToAmount,
      'estimatedToAmountUsd': instance.estimatedToAmountUsd,
      'exchangeRate': instance.exchangeRate,
      'binanceFee': instance.binanceFee,
      'omlapayFee': instance.omlapayFee,
      'totalFee': instance.totalFee,
      'available': instance.available,
      'minFromAmount': instance.minFromAmount,
      'maxFromAmount': instance.maxFromAmount,
    };
