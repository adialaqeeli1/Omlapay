import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

@freezed
abstract class WalletNetworkModel with _$WalletNetworkModel {
  const factory WalletNetworkModel({
    @JsonKey(name: 'network') @Default('') String network,
    @JsonKey(name: 'networkDisplayName') @Default('') String networkDisplayName,
    @JsonKey(name: 'networkIconUrl') @Default('') String networkIconUrl,
    @Default(<WalletCoinModel>[]) List<WalletCoinModel> coins,
  }) = _WalletNetworkModel;

  factory WalletNetworkModel.fromJson(Map<String, dynamic> json) =>
      _$WalletNetworkModelFromJson(json);
}

@freezed
abstract class WalletCoinModel with _$WalletCoinModel {
  const factory WalletCoinModel({
    @JsonKey(name: 'name') @Default('') String name,
    @JsonKey(name: 'symbol') @Default('') String symbol,
    @JsonKey(name: 'address') String? address,
    @JsonKey(name: 'addressTag') String? addressTag,
    @Default('') String network,
    @Default('') String networkDisplayName,
    @Default('') String networkIconUrl,
    @JsonKey(name: 'currentBalance', fromJson: _parseDouble)
    @Default(0)
    double currentBalance,
    @JsonKey(name: 'currentBalanceSar', fromJson: _parseDouble)
    @Default(0)
    double currentBalanceSar,
  }) = _WalletCoinModel;

  factory WalletCoinModel.fromJson(Map<String, dynamic> json) =>
      _$WalletCoinModelFromJson(json);
}
