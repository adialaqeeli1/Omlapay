import 'package:freezed_annotation/freezed_annotation.dart';

part 'swap_quote_stream_model.freezed.dart';
part 'swap_quote_stream_model.g.dart';

/// Live swap quote payload from `/v1/swap/quote/stream` (status == "ok").
@freezed
abstract class SwapQuoteStreamModel with _$SwapQuoteStreamModel {
  const factory SwapQuoteStreamModel({
    @Default('') String fromCoin,
    @Default('') String toCoin,
    @Default('') String exchangeRate,
    @Default('') String inverseRate,
    @Default('') String youPay,
    @Default('') String youPayCoin,
    @Default('') String youReceive,
    @Default('') String youReceiveCoin,
    @Default('') String available,
    @Default('') String minFromAmount,
    @Default('') String maxFromAmount,
    SwapQuoteStreamFees? fees,
    SwapQuoteStreamPay? pay,
    SwapQuoteStreamReceive? receive,
  }) = _SwapQuoteStreamModel;

  factory SwapQuoteStreamModel.fromJson(Map<String, dynamic> json) =>
      _$SwapQuoteStreamModelFromJson(json);
}

@freezed
abstract class SwapQuoteStreamFees with _$SwapQuoteStreamFees {
  const factory SwapQuoteStreamFees({
    SwapQuoteFeeEntry? omlapay,
    SwapQuoteFeeEntry? binance,
    SwapQuoteFeeEntry? total,
  }) = _SwapQuoteStreamFees;

  factory SwapQuoteStreamFees.fromJson(Map<String, dynamic> json) =>
      _$SwapQuoteStreamFeesFromJson(json);
}

@freezed
abstract class SwapQuoteFeeEntry with _$SwapQuoteFeeEntry {
  const factory SwapQuoteFeeEntry({
    @Default('') String percent,
    @Default('') String fromCoinAmount,
    @Default('') String toCoinAmount,
    @Default('') String usd,
  }) = _SwapQuoteFeeEntry;

  factory SwapQuoteFeeEntry.fromJson(Map<String, dynamic> json) =>
      _$SwapQuoteFeeEntryFromJson(json);
}

@freezed
abstract class SwapQuoteStreamPay with _$SwapQuoteStreamPay {
  const factory SwapQuoteStreamPay({
    @Default('') String coin,
    @Default('') String amount,
    @Default('') String amountUsd,
  }) = _SwapQuoteStreamPay;

  factory SwapQuoteStreamPay.fromJson(Map<String, dynamic> json) =>
      _$SwapQuoteStreamPayFromJson(json);
}

@freezed
abstract class SwapQuoteStreamReceive with _$SwapQuoteStreamReceive {
  const factory SwapQuoteStreamReceive({
    @Default('') String coin,
    @Default('') String grossAmount,
    @Default('') String grossAmountUsd,
    @Default('') String netAmount,
    @Default('') String netAmountUsd,
  }) = _SwapQuoteStreamReceive;

  factory SwapQuoteStreamReceive.fromJson(Map<String, dynamic> json) =>
      _$SwapQuoteStreamReceiveFromJson(json);
}
