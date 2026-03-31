// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_phone_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangePhoneRequestData _$ChangePhoneRequestDataFromJson(
  Map<String, dynamic> json,
) => _ChangePhoneRequestData(
  maskedMobile: json['masked_mobile'] as String,
  otpExpirySeconds: (json['otp_expiry_seconds'] as num).toInt(),
);

Map<String, dynamic> _$ChangePhoneRequestDataToJson(
  _ChangePhoneRequestData instance,
) => <String, dynamic>{
  'masked_mobile': instance.maskedMobile,
  'otp_expiry_seconds': instance.otpExpirySeconds,
};

_ChangePhoneVerifyData _$ChangePhoneVerifyDataFromJson(
  Map<String, dynamic> json,
) => _ChangePhoneVerifyData(maskedMobile: json['masked_mobile'] as String);

Map<String, dynamic> _$ChangePhoneVerifyDataToJson(
  _ChangePhoneVerifyData instance,
) => <String, dynamic>{'masked_mobile': instance.maskedMobile};
