import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_resend_otp_response_model.freezed.dart';
part 'send_resend_otp_response_model.g.dart';

@freezed
abstract class SendResendOtpResponseModel with _$SendResendOtpResponseModel {
  const factory SendResendOtpResponseModel({
    @Default('') String sendToken,
    @Default(60) int otpExpirySeconds,
    @Default(0) int remainingResends,
  }) = _SendResendOtpResponseModel;

  factory SendResendOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SendResendOtpResponseModelFromJson(json);
}
