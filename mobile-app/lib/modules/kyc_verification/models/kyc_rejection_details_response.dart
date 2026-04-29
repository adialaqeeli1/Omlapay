import 'package:freezed_annotation/freezed_annotation.dart';

part 'kyc_rejection_details_response.freezed.dart';
part 'kyc_rejection_details_response.g.dart';

@freezed
abstract class KycRejectionDetailsResponse with _$KycRejectionDetailsResponse {
  const factory KycRejectionDetailsResponse({
    @Default(false) bool canResubmit,
    String? rejectedProvider,
    String? rejectionReason,
    @JsonKey(name: 'rejectionReason_ar') String? rejectionReasonAr,
    String? rejectType,
    KycPreviousData? previousData,
    KycDocuments? documents,
  }) = _KycRejectionDetailsResponse;

  factory KycRejectionDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$KycRejectionDetailsResponseFromJson(json);
}

@freezed
abstract class KycPreviousData with _$KycPreviousData {
  const factory KycPreviousData({
    String? firstName,
    String? lastName,
    String? dob,
    String? country,
    String? nationality,
    String? address,
    String? city,
  }) = _KycPreviousData;

  factory KycPreviousData.fromJson(Map<String, dynamic> json) =>
      _$KycPreviousDataFromJson(json);
}

@freezed
abstract class KycDocuments with _$KycDocuments {
  const factory KycDocuments({
    String? frontUrl,
    String? backUrl,
    String? faceUrl,
  }) = _KycDocuments;

  factory KycDocuments.fromJson(Map<String, dynamic> json) =>
      _$KycDocumentsFromJson(json);
}
