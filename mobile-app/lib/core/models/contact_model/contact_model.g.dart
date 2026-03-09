// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactModel _$ContactModelFromJson(Map<String, dynamic> json) => ContactModel(
  id: json['id'] as String,
  name: json['name'] as String,
  phoneNumber: json['phoneNumber'] as String,
  imagePath: json['imagePath'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
  network: json['network'] as String? ?? 'TRC20',
);

Map<String, dynamic> _$ContactModelToJson(ContactModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'imagePath': instance.imagePath,
      'isVerified': instance.isVerified,
      'network': instance.network,
    };
