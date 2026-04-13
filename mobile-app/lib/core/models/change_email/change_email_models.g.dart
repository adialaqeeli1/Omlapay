// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangeEmailStep1Data _$ChangeEmailStep1DataFromJson(
  Map<String, dynamic> json,
) => _ChangeEmailStep1Data(
  maskedPhone: json['masked_phone'] as String,
  otpExpirySeconds: (json['otp_expiry_seconds'] as num).toInt(),
  maskedEmail: json['masked_email'] as String?,
);

Map<String, dynamic> _$ChangeEmailStep1DataToJson(
  _ChangeEmailStep1Data instance,
) => <String, dynamic>{
  'masked_phone': instance.maskedPhone,
  'otp_expiry_seconds': instance.otpExpirySeconds,
  'masked_email': instance.maskedEmail,
};

_ChangeEmailStep2Data _$ChangeEmailStep2DataFromJson(
  Map<String, dynamic> json,
) => _ChangeEmailStep2Data(
  changeEmailToken: json['change_email_token'] as String,
);

Map<String, dynamic> _$ChangeEmailStep2DataToJson(
  _ChangeEmailStep2Data instance,
) => <String, dynamic>{'change_email_token': instance.changeEmailToken};

_ChangeEmailStep3Data _$ChangeEmailStep3DataFromJson(
  Map<String, dynamic> json,
) => _ChangeEmailStep3Data(
  changeEmailToken: json['change_email_token'] as String,
  email: json['email'] as String,
  otpExpirySeconds: (json['otp_expiry_seconds'] as num).toInt(),
);

Map<String, dynamic> _$ChangeEmailStep3DataToJson(
  _ChangeEmailStep3Data instance,
) => <String, dynamic>{
  'change_email_token': instance.changeEmailToken,
  'email': instance.email,
  'otp_expiry_seconds': instance.otpExpirySeconds,
};

_ChangeEmailStep4Data _$ChangeEmailStep4DataFromJson(
  Map<String, dynamic> json,
) => _ChangeEmailStep4Data(
  changeEmailToken: json['change_email_token'] as String,
);

Map<String, dynamic> _$ChangeEmailStep4DataToJson(
  _ChangeEmailStep4Data instance,
) => <String, dynamic>{'change_email_token': instance.changeEmailToken};

_ChangeEmailStep5Data _$ChangeEmailStep5DataFromJson(
  Map<String, dynamic> json,
) => _ChangeEmailStep5Data(email: json['email'] as String);

Map<String, dynamic> _$ChangeEmailStep5DataToJson(
  _ChangeEmailStep5Data instance,
) => <String, dynamic>{'email': instance.email};
