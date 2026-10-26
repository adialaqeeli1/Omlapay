// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_initiate_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SendInitiateResponseModel _$SendInitiateResponseModelFromJson(
  Map<String, dynamic> json,
) => _SendInitiateResponseModel(
  sendToken: json['sendToken'] as String? ?? '',
  otpExpirySeconds: (json['otpExpirySeconds'] as num?)?.toInt() ?? 60,
);

Map<String, dynamic> _$SendInitiateResponseModelToJson(
  _SendInitiateResponseModel instance,
) => <String, dynamic>{
  'sendToken': instance.sendToken,
  'otpExpirySeconds': instance.otpExpirySeconds,
};
