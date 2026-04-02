import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_phone_models.freezed.dart';
part 'change_phone_models.g.dart';

@freezed
abstract class ChangePhoneRequestData with _$ChangePhoneRequestData {
  const factory ChangePhoneRequestData({
    @JsonKey(name: 'masked_mobile') required String maskedMobile,
    @JsonKey(name: 'otp_expiry_seconds') required int otpExpirySeconds,
  }) = _ChangePhoneRequestData;

  factory ChangePhoneRequestData.fromJson(Map<String, dynamic> json) =>
      _$ChangePhoneRequestDataFromJson(json);
}

@freezed
abstract class ChangePhoneVerifyData with _$ChangePhoneVerifyData {
  const factory ChangePhoneVerifyData({
    @JsonKey(name: 'masked_mobile') required String maskedMobile,
  }) = _ChangePhoneVerifyData;

  factory ChangePhoneVerifyData.fromJson(Map<String, dynamic> json) =>
      _$ChangePhoneVerifyDataFromJson(json);
}
