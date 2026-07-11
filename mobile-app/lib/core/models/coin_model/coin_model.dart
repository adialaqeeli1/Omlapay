import 'package:freezed_annotation/freezed_annotation.dart';

part 'coin_model.freezed.dart';
part 'coin_model.g.dart';

@freezed
abstract class CoinModel with _$CoinModel {
  const factory CoinModel({
    String? id,
    required String name,
    required String symbol,
    required String amount,
    required String valueInUsd,
    @Default(0) double change24h,
    @Default(0) int decimals,
    String? network,
    String? iconUrl,
    String? networkIconUrl,
    String? contractAddress,
    String? minWithdrawal,
    String? minDeposit,
    String? withdrawalFee,
    String? description,
    double? price,
    String? quoteSymbol,
    String? quoteSymbolAr,
    @JsonKey(name: 'symbol_ar') String? coinSymbolAr,
    @JsonKey(name: 'name_ar') String? coinNameAr,
    String? minSendAmount,
    String? maxSendAmount,
    String? swapMinAmount,
    String? swapMaxAmount,
  }) = _CoinModel;

  factory CoinModel.fromJson(Map<String, dynamic> json) =>
      _$CoinModelFromJson(json);
}
