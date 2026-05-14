// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_qr_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScannedQrPayload _$ScannedQrPayloadFromJson(Map<String, dynamic> json) =>
    _ScannedQrPayload(
      address: json['address'] as String?,
      symbol: json['symbol'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ScannedQrPayloadToJson(_ScannedQrPayload instance) =>
    <String, dynamic>{
      'address': instance.address,
      'symbol': instance.symbol,
      'amount': instance.amount,
    };
