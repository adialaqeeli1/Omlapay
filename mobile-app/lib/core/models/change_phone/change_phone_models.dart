import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_phone_models.freezed.dart';
part 'change_phone_models.g.dart';

/// Response from step1-request and step3-request (OTP sent to a phone number).
/// When 2FA is enabled, step1 also returns [maskedEmail].
@freezed
abstract class ChangePhoneRequestData with _$ChangePhoneRequestData {
  const factory ChangePhoneRequestData({
    @JsonKey(name: 'masked_phone') required String maskedMobile,
    @JsonKey(name: 'otp_expiry_seconds') required int otpExpirySeconds,
    @JsonKey(name: 'masked_email') String? maskedEmail,
  }) = _ChangePhoneRequestData;

  factory ChangePhoneRequestData.fromJson(Map<String, dynamic> json) =>
      _$ChangePhoneRequestDataFromJson(json);
}

/// Response from step2-verify (current phone verified, token issued).
@freezed
abstract class ChangePhoneStep2Data with _$ChangePhoneStep2Data {
  const factory ChangePhoneStep2Data({
    @JsonKey(name: 'change_phone_token') required String changePhoneToken,
  }) = _ChangePhoneStep2Data;

  factory ChangePhoneStep2Data.fromJson(Map<String, dynamic> json) =>
      _$ChangePhoneStep2DataFromJson(json);
}

/// Response from step4-verify (new phone verified).
@freezed
abstract class ChangePhoneVerifyData with _$ChangePhoneVerifyData {
  const factory ChangePhoneVerifyData({
    @JsonKey(name: 'masked_mobile') required String maskedMobile,
  }) = _ChangePhoneVerifyData;

  factory ChangePhoneVerifyData.fromJson(Map<String, dynamic> json) =>
      _$ChangePhoneVerifyDataFromJson(json);
}
