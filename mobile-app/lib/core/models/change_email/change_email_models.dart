import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_email_models.freezed.dart';
part 'change_email_models.g.dart';

/// Response from step1-request (OTP sent to current phone).
/// When 2FA is enabled, step1 also returns [maskedEmail].
@freezed
abstract class ChangeEmailStep1Data with _$ChangeEmailStep1Data {
  const factory ChangeEmailStep1Data({
    @JsonKey(name: 'masked_phone') required String maskedPhone,
    @JsonKey(name: 'otp_expiry_seconds') required int otpExpirySeconds,
    @JsonKey(name: 'masked_email') String? maskedEmail,
  }) = _ChangeEmailStep1Data;

  factory ChangeEmailStep1Data.fromJson(Map<String, dynamic> json) =>
      _$ChangeEmailStep1DataFromJson(json);
}

/// Response from step2-verify (current phone verified, token issued).
@freezed
abstract class ChangeEmailStep2Data with _$ChangeEmailStep2Data {
  const factory ChangeEmailStep2Data({
    @JsonKey(name: 'change_email_token') required String changeEmailToken,
  }) = _ChangeEmailStep2Data;

  factory ChangeEmailStep2Data.fromJson(Map<String, dynamic> json) =>
      _$ChangeEmailStep2DataFromJson(json);
}

/// Response from step3-request (OTP sent to new email).
@freezed
abstract class ChangeEmailStep3Data with _$ChangeEmailStep3Data {
  const factory ChangeEmailStep3Data({
    @JsonKey(name: 'change_email_token') required String changeEmailToken,
    required String email,
    @JsonKey(name: 'otp_expiry_seconds') required int otpExpirySeconds,
  }) = _ChangeEmailStep3Data;

  factory ChangeEmailStep3Data.fromJson(Map<String, dynamic> json) =>
      _$ChangeEmailStep3DataFromJson(json);
}

/// Response from step4-verify (new email verified, token issued).
@freezed
abstract class ChangeEmailStep4Data with _$ChangeEmailStep4Data {
  const factory ChangeEmailStep4Data({
    @JsonKey(name: 'change_email_token') required String changeEmailToken,
  }) = _ChangeEmailStep4Data;

  factory ChangeEmailStep4Data.fromJson(Map<String, dynamic> json) =>
      _$ChangeEmailStep4DataFromJson(json);
}

/// Response from step5-confirm (email changed successfully).
@freezed
abstract class ChangeEmailStep5Data with _$ChangeEmailStep5Data {
  const factory ChangeEmailStep5Data({
    required String email,
  }) = _ChangeEmailStep5Data;

  factory ChangeEmailStep5Data.fromJson(Map<String, dynamic> json) =>
      _$ChangeEmailStep5DataFromJson(json);
}
