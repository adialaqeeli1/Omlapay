import 'package:freezed_annotation/freezed_annotation.dart';

import 'support_request_model.dart';

part 'support_request_detail_model.freezed.dart';
part 'support_request_detail_model.g.dart';

@freezed
abstract class SupportRequestDetailModel with _$SupportRequestDetailModel {
  const factory SupportRequestDetailModel({
    required String id,
    required String title,
    @Default('') String description,
    @Default(SupportRequestStatus.pending) SupportRequestStatus status,
    String? statusColor,
    String? ticketId,
    @Default([]) List<SupportRequestAttachment> attachments,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<SupportRequestResponse> responses,
  }) = _SupportRequestDetailModel;

  factory SupportRequestDetailModel.fromJson(Map<String, dynamic> json) =>
      _$SupportRequestDetailModelFromJson(json);
}

@freezed
abstract class SupportRequestAttachment with _$SupportRequestAttachment {
  const factory SupportRequestAttachment({
    required String url,
    @Default('document') String type,
  }) = _SupportRequestAttachment;

  factory SupportRequestAttachment.fromJson(Map<String, dynamic> json) =>
      _$SupportRequestAttachmentFromJson(json);
}

@freezed
abstract class SupportRequestResponse with _$SupportRequestResponse {
  const factory SupportRequestResponse({
    required String id,
    @Default('') String message,
    required DateTime createdAt,
    @Default(false) bool isAdminResponse,
  }) = _SupportRequestResponse;

  factory SupportRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$SupportRequestResponseFromJson(json);
}
