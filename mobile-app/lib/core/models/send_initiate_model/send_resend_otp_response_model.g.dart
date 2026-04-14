// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_resend_otp_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SendResendOtpResponseModel _$SendResendOtpResponseModelFromJson(
  Map<String, dynamic> json,
) => _SendResendOtpResponseModel(
  sendToken: json['sendToken'] as String? ?? '',
  otpExpirySeconds: (json['otpExpirySeconds'] as num?)?.toInt() ?? 60,
  remainingResends: (json['remainingResends'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SendResendOtpResponseModelToJson(
  _SendResendOtpResponseModel instance,
) => <String, dynamic>{
  'sendToken': instance.sendToken,
  'otpExpirySeconds': instance.otpExpirySeconds,
  'remainingResends': instance.remainingResends,
};
