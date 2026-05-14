import 'package:freezed_annotation/freezed_annotation.dart';

part 'scanned_qr_payload.freezed.dart';
part 'scanned_qr_payload.g.dart';

/// Normalised result of parsing a scanned QR string, regardless of whether
/// the source encoding was OmlaPay JSON, a Solana Pay URI, or a bare address.
@freezed
abstract class ScannedQrPayload with _$ScannedQrPayload {
  const factory ScannedQrPayload({
    String? address,
    @Default('') String symbol,
    double? amount,
  }) = _ScannedQrPayload;

  factory ScannedQrPayload.fromJson(Map<String, dynamic> json) =>
      _$ScannedQrPayloadFromJson(json);
}
