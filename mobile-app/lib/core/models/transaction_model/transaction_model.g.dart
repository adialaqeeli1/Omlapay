// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    _TransactionModel(
      id: json['id'] as String,
      assetSymbol: json['assetSymbol'] as String,
      assetName: json['assetName'] as String,
      assetIconUrl: json['assetIconUrl'] as String?,
      amount: json['amount'] as String,
      network: json['network'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      txHash: json['txHash'] as String?,
      status: json['status'] as String,
    );

Map<String, dynamic> _$TransactionModelToJson(_TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assetSymbol': instance.assetSymbol,
      'assetName': instance.assetName,
      'assetIconUrl': instance.assetIconUrl,
      'amount': instance.amount,
      'network': instance.network,
      'createdAt': instance.createdAt.toIso8601String(),
      'txHash': instance.txHash,
      'status': instance.status,
    };
