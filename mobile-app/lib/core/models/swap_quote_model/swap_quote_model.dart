import 'package:freezed_annotation/freezed_annotation.dart';

part 'swap_quote_model.freezed.dart';
part 'swap_quote_model.g.dart';

@freezed
abstract class SwapQuoteModel with _$SwapQuoteModel {
  const factory SwapQuoteModel({
    @Default('') String fromCoin,
    @Default('') String toCoin,
    @Default('') String fromAmount,
    @Default('') String fromAmountUsd,
    @Default('') String estimatedToAmount,
    @Default('') String estimatedToAmountUsd,
    @Default('') String exchangeRate,
    @Default('') String binanceFee,
    @Default('') String omlapayFee,
    @Default('') String totalFee,
    @Default('') String available,
    @Default('') String minFromAmount,
    @Default('') String maxFromAmount,
  }) = _SwapQuoteModel;

  factory SwapQuoteModel.fromJson(Map<String, dynamic> json) =>
      _$SwapQuoteModelFromJson(json);
}
