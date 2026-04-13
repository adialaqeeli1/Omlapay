// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_request_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SupportRequestDetailModel _$SupportRequestDetailModelFromJson(
  Map<String, dynamic> json,
) => _SupportRequestDetailModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  status:
      $enumDecodeNullable(_$SupportRequestStatusEnumMap, json['status']) ??
      SupportRequestStatus.pending,
  statusColor: json['statusColor'] as String?,
  ticketId: json['ticketId'] as String?,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map(
            (e) => SupportRequestAttachment.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  responses: json['responses'] as List<dynamic>? ?? const [],
);

Map<String, dynamic> _$SupportRequestDetailModelToJson(
  _SupportRequestDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'status': _$SupportRequestStatusEnumMap[instance.status]!,
  'statusColor': instance.statusColor,
  'ticketId': instance.ticketId,
  'attachments': instance.attachments,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'responses': instance.responses,
};

const _$SupportRequestStatusEnumMap = {
  SupportRequestStatus.open: 'OPEN',
  SupportRequestStatus.pending: 'PENDING',
  SupportRequestStatus.solved: 'SOLVED',
  SupportRequestStatus.rejected: 'REJECTED',
};

_SupportRequestAttachment _$SupportRequestAttachmentFromJson(
  Map<String, dynamic> json,
) => _SupportRequestAttachment(
  url: json['url'] as String,
  type: json['type'] as String? ?? 'document',
);

Map<String, dynamic> _$SupportRequestAttachmentToJson(
  _SupportRequestAttachment instance,
) => <String, dynamic>{'url': instance.url, 'type': instance.type};
