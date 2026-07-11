// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    _TransactionModel(
      id: json['id'] as String,
      assetSymbol: json['coin_symbol'] as String,
      assetName: json['coinName'] as String?,
      assetNameAr: json['coinName_ar'] as String?,
      assetIconUrl: json['assetIconUrl'] as String?,
      amount: json['amount'] as String,
      amountDisplay: json['amountDisplay'] as String?,
      amountUsd: json['amountUsd'] as String?,
      amountSar: json['amountSAR'] as String?,
      network: json['network'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      txHash: json['txHash'] as String?,
      blockchainLink: json['blockchain_link'] as String?,
      status: json['status'] as String,
      direction: json['direction'] as String?,
      type: json['type'] as String?,
      networkIconUrl: json['networkIconUrl'] as String?,
      fee: json['fee'] as String?,
      errorMessage: json['errorMessage'] as String?,
      errorMessageAr: json['errorMessageAr'] as String?,
      senderAddress: json['senderAddress'] as String?,
      receiverAddress: json['receiverAddress'] as String?,
      counterpartyPhone: json['counterpartyPhone'] as String?,
      transactionType: json['txType'] as String?,
      pairLabel: json['pairLabel'] as String?,
      fromAsset: json['fromAsset'] == null
          ? null
          : TransactionSwapAsset.fromJson(
              json['fromAsset'] as Map<String, dynamic>,
            ),
      toAsset: json['toAsset'] == null
          ? null
          : TransactionSwapAsset.fromJson(
              json['toAsset'] as Map<String, dynamic>,
            ),
      exchangeRate: json['exchangeRate'] as String?,
    );

Map<String, dynamic> _$TransactionModelToJson(_TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coin_symbol': instance.assetSymbol,
      'coinName': instance.assetName,
      'coinName_ar': instance.assetNameAr,
      'assetIconUrl': instance.assetIconUrl,
      'amount': instance.amount,
      'amountDisplay': instance.amountDisplay,
      'amountUsd': instance.amountUsd,
      'amountSAR': instance.amountSar,
      'network': instance.network,
      'createdAt': instance.createdAt.toIso8601String(),
      'txHash': instance.txHash,
      'blockchain_link': instance.blockchainLink,
      'status': instance.status,
      'direction': instance.direction,
      'type': instance.type,
      'networkIconUrl': instance.networkIconUrl,
      'fee': instance.fee,
      'errorMessage': instance.errorMessage,
      'errorMessageAr': instance.errorMessageAr,
      'senderAddress': instance.senderAddress,
      'receiverAddress': instance.receiverAddress,
      'counterpartyPhone': instance.counterpartyPhone,
      'txType': instance.transactionType,
      'pairLabel': instance.pairLabel,
      'fromAsset': instance.fromAsset,
      'toAsset': instance.toAsset,
      'exchangeRate': instance.exchangeRate,
    };
