// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_confirm_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SendConfirmResponseModel _$SendConfirmResponseModelFromJson(
  Map<String, dynamic> json,
) => _SendConfirmResponseModel(
  transactionId: json['transactionId'] as String? ?? '',
  amount: json['amount'] as String? ?? '',
  coin: json['coin'] as String? ?? '',
  status: json['status'] as String? ?? '',
  estimatedCompletion: json['estimatedCompletion'] as String? ?? '',
);

Map<String, dynamic> _$SendConfirmResponseModelToJson(
  _SendConfirmResponseModel instance,
) => <String, dynamic>{
  'transactionId': instance.transactionId,
  'amount': instance.amount,
  'coin': instance.coin,
  'status': instance.status,
  'estimatedCompletion': instance.estimatedCompletion,
};
