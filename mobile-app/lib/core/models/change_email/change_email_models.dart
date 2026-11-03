import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_email_models.freezed.dart';
part 'change_email_models.g.dart';

/// Response from step1-request. The server sends OTPs to both the user's
/// current phone and email and returns masked previews for each.
@freezed
abstract class ChangeEmailStep1Data with _$ChangeEmailStep1Data {
  const factory ChangeEmailStep1Data({
    @JsonKey(name: 'otp_expiry_seconds') required int otpExpirySeconds,
    @JsonKey(name: 'masked_phone') String? maskedPhone,
    @JsonKey(name: 'masked_email') String? maskedEmail,
  }) = _ChangeEmailStep1Data;

  factory ChangeEmailStep1Data.fromJson(Map<String, dynamic> json) =>
      _$ChangeEmailStep1DataFromJson(json);
}

/// Response from step2-verify-phone (phone+email OTPs verified, token issued).
/// Same shape is also returned by step3-verify-passcode.
@freezed
abstract class ChangeEmailTokenData with _$ChangeEmailTokenData {
  const factory ChangeEmailTokenData({
    @JsonKey(name: 'change_email_token') required String changeEmailToken,
  }) = _ChangeEmailTokenData;

  factory ChangeEmailTokenData.fromJson(Map<String, dynamic> json) =>
      _$ChangeEmailTokenDataFromJson(json);
}

/// Response from step4-request-new-email (OTP sent to new email).
@freezed
abstract class ChangeEmailRequestNewEmailData
    with _$ChangeEmailRequestNewEmailData {
  const factory ChangeEmailRequestNewEmailData({
    @JsonKey(name: 'otp_expiry_seconds') required int otpExpirySeconds,
    @JsonKey(name: 'change_email_token') String? changeEmailToken,
    String? email,
  }) = _ChangeEmailRequestNewEmailData;

  factory ChangeEmailRequestNewEmailData.fromJson(Map<String, dynamic> json) =>
      _$ChangeEmailRequestNewEmailDataFromJson(json);
}

/// Response from step5-verify-new-email (new email verified — flow complete).
@freezed
abstract class ChangeEmailVerifyNewEmailData
    with _$ChangeEmailVerifyNewEmailData {
  const factory ChangeEmailVerifyNewEmailData({
    String? email,
  }) = _ChangeEmailVerifyNewEmailData;

  factory ChangeEmailVerifyNewEmailData.fromJson(Map<String, dynamic> json) =>
      _$ChangeEmailVerifyNewEmailDataFromJson(json);
}
