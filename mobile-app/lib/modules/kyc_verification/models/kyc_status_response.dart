import 'package:freezed_annotation/freezed_annotation.dart';

part 'kyc_status_response.freezed.dart';
part 'kyc_status_response.g.dart';

@freezed
abstract class KycStatusResponse with _$KycStatusResponse {
  const factory KycStatusResponse({
    SumsubStatus? sumsub,
    BinanceStatus? binance,
  }) = _KycStatusResponse;

  factory KycStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$KycStatusResponseFromJson(json);
}

@freezed
abstract class SumsubStatus with _$SumsubStatus {
  const factory SumsubStatus({
    String? status,
    String? referenceId,
    String? verifiedAt,
    String? rejectionReason,
    @JsonKey(name: 'rejectionReason_ar') String? rejectionReasonAr,
    String? rejectType,
    String? reviewAnswer,
    String? updatedAt,
  }) = _SumsubStatus;

  factory SumsubStatus.fromJson(Map<String, dynamic> json) =>
      _$SumsubStatusFromJson(json);
}

@freezed
abstract class BinanceStatus with _$BinanceStatus {
  const factory BinanceStatus({
    String? status,
    String? referenceId,
    String? verifiedAt,
    String? rejectionReason,
    @JsonKey(name: 'rejectionReason_ar') String? rejectionReasonAr,
    @Default(false) bool canStart,
    @Default(false) bool canCreateApiKeys,
    @Default(false) bool hasApiKeys,
    String? updatedAt,
  }) = _BinanceStatus;

  factory BinanceStatus.fromJson(Map<String, dynamic> json) =>
      _$BinanceStatusFromJson(json);
}
