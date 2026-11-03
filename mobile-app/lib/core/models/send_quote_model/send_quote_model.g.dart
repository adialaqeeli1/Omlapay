// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_quote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SendQuoteModel _$SendQuoteModelFromJson(Map<String, dynamic> json) =>
    _SendQuoteModel(
      coin: json['coin'] as String? ?? '',
      network: json['network'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      amountUsd: json['amountUsd'] as String? ?? '',
      fee: json['fee'] as String? ?? '',
      sentAmount: json['sentAmount'] as String? ?? '',
      available: json['available'] as String? ?? '',
      recipientType: json['recipientType'] as String? ?? '',
      recipientName: json['recipientName'] as String?,
      isRegistered: json['isRegistered'] as bool? ?? false,
    );

Map<String, dynamic> _$SendQuoteModelToJson(_SendQuoteModel instance) =>
    <String, dynamic>{
      'coin': instance.coin,
      'network': instance.network,
      'amount': instance.amount,
      'amountUsd': instance.amountUsd,
      'fee': instance.fee,
      'sentAmount': instance.sentAmount,
      'available': instance.available,
      'recipientType': instance.recipientType,
      'recipientName': instance.recipientName,
      'isRegistered': instance.isRegistered,
    };
