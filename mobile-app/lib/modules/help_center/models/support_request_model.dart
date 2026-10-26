import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_request_model.freezed.dart';
part 'support_request_model.g.dart';

enum SupportRequestStatus {
  @JsonValue('OPEN')
  open,
  @JsonValue('PENDING')
  pending,
  @JsonValue('SOLVED')
  solved,
  @JsonValue('REJECTED')
  rejected,
}

@freezed
abstract class SupportRequestsResponse with _$SupportRequestsResponse {
  const factory SupportRequestsResponse({
    @Default([]) List<SupportRequestModel> requests,
    SupportRequestPagination? pagination,
  }) = _SupportRequestsResponse;

  factory SupportRequestsResponse.fromJson(Map<String, dynamic> json) =>
      _$SupportRequestsResponseFromJson(json);
}

@freezed
abstract class SupportRequestPagination with _$SupportRequestPagination {
  const factory SupportRequestPagination({
    @Default('1') String page,
    @Default('10') String limit,
    @Default(0) int total,
    @Default(1) int totalPages,
  }) = _SupportRequestPagination;

  factory SupportRequestPagination.fromJson(Map<String, dynamic> json) =>
      _$SupportRequestPaginationFromJson(json);
}

@freezed
abstract class SupportRequestModel with _$SupportRequestModel {
  const factory SupportRequestModel({
    required String id,
    required String title,
    @Default(SupportRequestStatus.pending) SupportRequestStatus status,
    String? statusColor,
    required DateTime createdAt,
  }) = _SupportRequestModel;

  factory SupportRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SupportRequestModelFromJson(json);
}
