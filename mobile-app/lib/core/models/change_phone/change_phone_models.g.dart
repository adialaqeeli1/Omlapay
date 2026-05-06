// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_phone_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangePhoneRequestData _$ChangePhoneRequestDataFromJson(
  Map<String, dynamic> json,
) => _ChangePhoneRequestData(
  otpExpirySeconds: (json['otp_expiry_seconds'] as num).toInt(),
  verificationType: json['verification_type'] as String?,
  maskedMobile: json['masked_phone'] as String?,
  maskedEmail: json['masked_email'] as String?,
  changePhoneToken: json['change_phone_token'] as String?,
);

Map<String, dynamic> _$ChangePhoneRequestDataToJson(
  _ChangePhoneRequestData instance,
) => <String, dynamic>{
  'otp_expiry_seconds': instance.otpExpirySeconds,
  'verification_type': instance.verificationType,
  'masked_phone': instance.maskedMobile,
  'masked_email': instance.maskedEmail,
  'change_phone_token': instance.changePhoneToken,
};

_ChangePhoneStep2Data _$ChangePhoneStep2DataFromJson(
  Map<String, dynamic> json,
) => _ChangePhoneStep2Data(
  changePhoneToken: json['change_phone_token'] as String,
);

Map<String, dynamic> _$ChangePhoneStep2DataToJson(
  _ChangePhoneStep2Data instance,
) => <String, dynamic>{'change_phone_token': instance.changePhoneToken};

_ChangePhoneVerifyData _$ChangePhoneVerifyDataFromJson(
  Map<String, dynamic> json,
) => _ChangePhoneVerifyData(maskedMobile: json['masked_mobile'] as String);

Map<String, dynamic> _$ChangePhoneVerifyDataToJson(
  _ChangePhoneVerifyData instance,
) => <String, dynamic>{'masked_mobile': instance.maskedMobile};
