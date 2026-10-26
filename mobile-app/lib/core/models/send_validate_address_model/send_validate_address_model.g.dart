// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_validate_address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SendValidateAddressModel _$SendValidateAddressModelFromJson(
  Map<String, dynamic> json,
) => _SendValidateAddressModel(
  type: json['type'] as String?,
  isSelf: json['isSelf'] as bool? ?? false,
  network: json['network'] as String?,
  networks:
      (json['networks'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  coin: json['coin'] as String?,
  guessedCoin: json['guessedCoin'] as String?,
  confidence: json['confidence'] as String?,
  candidates:
      (json['candidates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  maskedPhone: json['maskedPhone'] as String?,
);

Map<String, dynamic> _$SendValidateAddressModelToJson(
  _SendValidateAddressModel instance,
) => <String, dynamic>{
  'type': instance.type,
  'isSelf': instance.isSelf,
  'network': instance.network,
  'networks': instance.networks,
  'coin': instance.coin,
  'guessedCoin': instance.guessedCoin,
  'confidence': instance.confidence,
  'candidates': instance.candidates,
  'maskedPhone': instance.maskedPhone,
};
