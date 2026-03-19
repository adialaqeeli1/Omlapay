// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    _TransactionModel(
      id: json['id'] as String,
      coinSymbol: json['coinSymbol'] as String,
      coinName: json['coinName'] as String,
      amount: json['amount'] as String,
      valueInCurrency: json['valueInCurrency'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      date: DateTime.parse(json['date'] as String),
      toAddress: json['toAddress'] as String?,
      fromAddress: json['fromAddress'] as String?,
      transactionHash: json['transactionHash'] as String?,
      fee: (json['fee'] as num?)?.toDouble(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$TransactionModelToJson(_TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coinSymbol': instance.coinSymbol,
      'coinName': instance.coinName,
      'amount': instance.amount,
      'valueInCurrency': instance.valueInCurrency,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'date': instance.date.toIso8601String(),
      'toAddress': instance.toAddress,
      'fromAddress': instance.fromAddress,
      'transactionHash': instance.transactionHash,
      'fee': instance.fee,
      'note': instance.note,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.sent: 'sent',
  TransactionType.received: 'received',
  TransactionType.swap: 'swap',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.completed: 'completed',
  TransactionStatus.failed: 'failed',
};
