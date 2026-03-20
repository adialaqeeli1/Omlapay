// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  mobileNumber: json['mobileNumber'] as String,
  countryCode: json['countryCode'] as String,
  password: json['password'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  isVerified: json['isVerified'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'mobileNumber': instance.mobileNumber,
      'countryCode': instance.countryCode,
      'password': instance.password,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'isVerified': instance.isVerified,
    };
