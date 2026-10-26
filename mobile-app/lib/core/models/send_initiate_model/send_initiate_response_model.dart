import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_initiate_response_model.freezed.dart';
part 'send_initiate_response_model.g.dart';

@freezed
abstract class SendInitiateResponseModel with _$SendInitiateResponseModel {
  const factory SendInitiateResponseModel({
    @Default('') String sendToken,
    @Default(60) int otpExpirySeconds,
  }) = _SendInitiateResponseModel;

  factory SendInitiateResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SendInitiateResponseModelFromJson(json);
}
