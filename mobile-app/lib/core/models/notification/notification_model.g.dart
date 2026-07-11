// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationsResponse _$NotificationsResponseFromJson(
  Map<String, dynamic> json,
) => _NotificationsResponse(
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  notifications:
      (json['notifications'] as List<dynamic>?)
          ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  pagination: json['pagination'] == null
      ? null
      : PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NotificationsResponseToJson(
  _NotificationsResponse instance,
) => <String, dynamic>{
  'unreadCount': instance.unreadCount,
  'notifications': instance.notifications,
  'pagination': instance.pagination,
};

_PaginationInfo _$PaginationInfoFromJson(Map<String, dynamic> json) =>
    _PaginationInfo(
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
      limit: json['limit'] as String? ?? '20',
    );

Map<String, dynamic> _$PaginationInfoToJson(_PaginationInfo instance) =>
    <String, dynamic>{
      'nextCursor': instance.nextCursor,
      'hasMore': instance.hasMore,
      'limit': instance.limit,
    };

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      titleAr: json['title_ar'] as String?,
      message: json['message'] as String,
      messageAr: json['message_ar'] as String?,
      type:
          $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']) ??
          NotificationType.system,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'title_ar': instance.titleAr,
      'message': instance.message,
      'message_ar': instance.messageAr,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
      'referenceId': instance.referenceId,
      'referenceType': instance.referenceType,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.system: 'SYSTEM',
  NotificationType.promo: 'PROMO',
  NotificationType.security: 'SECURITY',
  NotificationType.tx: 'TX',
};
