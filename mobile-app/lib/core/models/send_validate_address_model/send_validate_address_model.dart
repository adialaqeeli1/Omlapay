import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_validate_address_model.freezed.dart';
part 'send_validate_address_model.g.dart';

/// Response payload of `GET /send/validate-address`.
///
/// [isSelf] is `true` when the resolved recipient is the current user's own
/// account, which the send flow uses to block self-transfers.
@freezed
abstract class SendValidateAddressModel with _$SendValidateAddressModel {
  const factory SendValidateAddressModel({
    String? type,
    @Default(false) bool isSelf,
    String? network,
    @Default(<String>[]) List<String> networks,
    String? coin,
    String? guessedCoin,
    String? confidence,
    @Default(<String>[]) List<String> candidates,
    String? maskedPhone,
  }) = _SendValidateAddressModel;

  factory SendValidateAddressModel.fromJson(Map<String, dynamic> json) =>
      _$SendValidateAddressModelFromJson(json);
}
