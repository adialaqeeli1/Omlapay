// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeModel _$HomeModelFromJson(Map<String, dynamic> json) => _HomeModel(
  profileImage: json['profileImage'] as String?,
  totalBalance: json['totalBalance'] as String? ?? '0.00',
  totalBalanceSar: json['totalBalanceSar'] as String? ?? '0.00',
  recentTransactions:
      (json['recentTransactions'] as List<dynamic>?)
          ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$HomeModelToJson(_HomeModel instance) =>
    <String, dynamic>{
      'profileImage': instance.profileImage,
      'totalBalance': instance.totalBalance,
      'totalBalanceSar': instance.totalBalanceSar,
      'recentTransactions': instance.recentTransactions,
      'unreadNotifications': instance.unreadNotifications,
    };
