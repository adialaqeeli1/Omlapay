// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String?,
  fullMobileNumber: _readPhoneNumber(json, 'fullMobileNumber') as String?,
  status: json['status'] as String?,
  email: json['email'] as String?,
  mobileNumber: json['mobileNumber'] as String? ?? '',
  countryCode: _readCountryCode(json, 'countryCode') as String? ?? '',
  password: json['password'] as String? ?? '',
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  isVerified: json['isVerified'] as bool? ?? false,
  twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
  wallets:
      (json['wallets'] as List<dynamic>?)
          ?.map((e) => WalletNetworkModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  walletsAvailable: json['walletsAvailable'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullMobileNumber': instance.fullMobileNumber,
      'status': instance.status,
      'email': instance.email,
      'mobileNumber': instance.mobileNumber,
      'countryCode': instance.countryCode,
      'password': instance.password,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'isVerified': instance.isVerified,
      'twoFactorEnabled': instance.twoFactorEnabled,
      'wallets': instance.wallets,
      'walletsAvailable': instance.walletsAvailable,
    };
