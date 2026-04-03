import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationType {
  @JsonValue('SYSTEM')
  system,
  @JsonValue('PROMO')
  promo,
  @JsonValue('SECURITY')
  security,
  @JsonValue('TX')
  tx,
}

@freezed
abstract class NotificationsResponse with _$NotificationsResponse {
  const factory NotificationsResponse({
    @Default(0) int unreadCount,
    @Default([]) List<NotificationModel> notifications,
    PaginationInfo? pagination,
  }) = _NotificationsResponse;

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationsResponseFromJson(json);
}

@freezed
abstract class PaginationInfo with _$PaginationInfo {
  const factory PaginationInfo({
    String? nextCursor,
    @Default(false) bool hasMore,
    @Default('20') String limit,
  }) = _PaginationInfo;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) =>
      _$PaginationInfoFromJson(json);
}

@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String title,
    required String message,
    @Default(NotificationType.system) NotificationType type,
    @Default(false) bool isRead,
    required DateTime createdAt,
    String? referenceId,
    String? referenceType,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
