import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_confirm_response_model.freezed.dart';
part 'send_confirm_response_model.g.dart';

@freezed
abstract class SendConfirmResponseModel with _$SendConfirmResponseModel {
  const factory SendConfirmResponseModel({
    @Default('') String transactionId,
    @Default('') String amount,
    @Default('') String coin,
    @Default('') String status,
    @Default('') String estimatedCompletion,
  }) = _SendConfirmResponseModel;

  factory SendConfirmResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SendConfirmResponseModelFromJson(json);
}
