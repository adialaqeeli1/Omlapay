// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WalletNetworkModel _$WalletNetworkModelFromJson(Map<String, dynamic> json) =>
    _WalletNetworkModel(
      network: json['network'] as String? ?? '',
      networkDisplayName: json['networkDisplayName'] as String? ?? '',
      networkIconUrl: json['networkIconUrl'] as String? ?? '',
      coins:
          (json['coins'] as List<dynamic>?)
              ?.map((e) => WalletCoinModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <WalletCoinModel>[],
    );

Map<String, dynamic> _$WalletNetworkModelToJson(_WalletNetworkModel instance) =>
    <String, dynamic>{
      'network': instance.network,
      'networkDisplayName': instance.networkDisplayName,
      'networkIconUrl': instance.networkIconUrl,
      'coins': instance.coins,
    };

_WalletCoinModel _$WalletCoinModelFromJson(Map<String, dynamic> json) =>
    _WalletCoinModel(
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      address: json['address'] as String?,
      addressTag: json['addressTag'] as String?,
      network: json['network'] as String? ?? '',
      networkDisplayName: json['networkDisplayName'] as String? ?? '',
      networkIconUrl: json['networkIconUrl'] as String? ?? '',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$WalletCoinModelToJson(_WalletCoinModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'address': instance.address,
      'addressTag': instance.addressTag,
      'network': instance.network,
      'networkDisplayName': instance.networkDisplayName,
      'networkIconUrl': instance.networkIconUrl,
      'currentBalance': instance.currentBalance,
    };
