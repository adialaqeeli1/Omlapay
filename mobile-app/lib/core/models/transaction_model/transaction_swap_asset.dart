import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_swap_asset.freezed.dart';
part 'transaction_swap_asset.g.dart';

@freezed
abstract class TransactionSwapAsset with _$TransactionSwapAsset {
  const factory TransactionSwapAsset({
    String? symbol,
    String? name,
    @JsonKey(name: 'name_ar') String? nameAr,
    String? iconUrl,
    String? amount,
    String? amountDisplay,
  }) = _TransactionSwapAsset;

  factory TransactionSwapAsset.fromJson(Map<String, dynamic> json) =>
      _$TransactionSwapAssetFromJson(json);
}
