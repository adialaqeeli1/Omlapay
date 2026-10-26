import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_quote_model.freezed.dart';
part 'send_quote_model.g.dart';

@freezed
abstract class SendQuoteModel with _$SendQuoteModel {
  const factory SendQuoteModel({
    @Default('') String coin,
    @Default('') String network,
    @Default('') String amount,
    @Default('') String amountUsd,
    @Default('') String fee,
    @Default('') String sentAmount,
    @Default('') String available,
    @Default('') String recipientType,
    String? recipientName,
    @Default(false) bool isRegistered,
  }) = _SendQuoteModel;

  factory SendQuoteModel.fromJson(Map<String, dynamic> json) =>
      _$SendQuoteModelFromJson(json);
}
