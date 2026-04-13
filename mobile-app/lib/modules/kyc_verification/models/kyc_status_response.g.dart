// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KycStatusResponse _$KycStatusResponseFromJson(Map<String, dynamic> json) =>
    _KycStatusResponse(
      sumsub: json['sumsub'] == null
          ? null
          : SumsubStatus.fromJson(json['sumsub'] as Map<String, dynamic>),
      binance: json['binance'] == null
          ? null
          : BinanceStatus.fromJson(json['binance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$KycStatusResponseToJson(_KycStatusResponse instance) =>
    <String, dynamic>{'sumsub': instance.sumsub, 'binance': instance.binance};

_SumsubStatus _$SumsubStatusFromJson(Map<String, dynamic> json) =>
    _SumsubStatus(
      status: json['status'] as String?,
      referenceId: json['referenceId'] as String?,
      verifiedAt: json['verifiedAt'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      rejectType: json['rejectType'] as String?,
      reviewAnswer: json['reviewAnswer'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$SumsubStatusToJson(_SumsubStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'referenceId': instance.referenceId,
      'verifiedAt': instance.verifiedAt,
      'rejectionReason': instance.rejectionReason,
      'rejectType': instance.rejectType,
      'reviewAnswer': instance.reviewAnswer,
      'updatedAt': instance.updatedAt,
    };

_BinanceStatus _$BinanceStatusFromJson(Map<String, dynamic> json) =>
    _BinanceStatus(
      status: json['status'] as String?,
      referenceId: json['referenceId'] as String?,
      verifiedAt: json['verifiedAt'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      canStart: json['canStart'] as bool? ?? false,
      canCreateApiKeys: json['canCreateApiKeys'] as bool? ?? false,
      hasApiKeys: json['hasApiKeys'] as bool? ?? false,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$BinanceStatusToJson(_BinanceStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'referenceId': instance.referenceId,
      'verifiedAt': instance.verifiedAt,
      'rejectionReason': instance.rejectionReason,
      'canStart': instance.canStart,
      'canCreateApiKeys': instance.canCreateApiKeys,
      'hasApiKeys': instance.hasApiKeys,
      'updatedAt': instance.updatedAt,
    };
