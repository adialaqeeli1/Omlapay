// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangeEmailStep1Data _$ChangeEmailStep1DataFromJson(
  Map<String, dynamic> json,
) => _ChangeEmailStep1Data(
  otpExpirySeconds: (json['otp_expiry_seconds'] as num).toInt(),
  maskedPhone: json['masked_phone'] as String?,
  maskedEmail: json['masked_email'] as String?,
);

Map<String, dynamic> _$ChangeEmailStep1DataToJson(
  _ChangeEmailStep1Data instance,
) => <String, dynamic>{
  'otp_expiry_seconds': instance.otpExpirySeconds,
  'masked_phone': instance.maskedPhone,
  'masked_email': instance.maskedEmail,
};

_ChangeEmailTokenData _$ChangeEmailTokenDataFromJson(
  Map<String, dynamic> json,
) => _ChangeEmailTokenData(
  changeEmailToken: json['change_email_token'] as String,
);

Map<String, dynamic> _$ChangeEmailTokenDataToJson(
  _ChangeEmailTokenData instance,
) => <String, dynamic>{'change_email_token': instance.changeEmailToken};

_ChangeEmailRequestNewEmailData _$ChangeEmailRequestNewEmailDataFromJson(
  Map<String, dynamic> json,
) => _ChangeEmailRequestNewEmailData(
  otpExpirySeconds: (json['otp_expiry_seconds'] as num).toInt(),
  changeEmailToken: json['change_email_token'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$ChangeEmailRequestNewEmailDataToJson(
  _ChangeEmailRequestNewEmailData instance,
) => <String, dynamic>{
  'otp_expiry_seconds': instance.otpExpirySeconds,
  'change_email_token': instance.changeEmailToken,
  'email': instance.email,
};

_ChangeEmailVerifyNewEmailData _$ChangeEmailVerifyNewEmailDataFromJson(
  Map<String, dynamic> json,
) => _ChangeEmailVerifyNewEmailData(email: json['email'] as String?);

Map<String, dynamic> _$ChangeEmailVerifyNewEmailDataToJson(
  _ChangeEmailVerifyNewEmailData instance,
) => <String, dynamic>{'email': instance.email};
