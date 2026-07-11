import 'package:freezed_annotation/freezed_annotation.dart';

import '../wallet_model/wallet_model.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Supports both API snake_case (`country_code`) and stored camelCase (`countryCode`).
Object? _readCountryCode(Map<dynamic, dynamic> json, String key) =>
    json['country_code'] ?? json['countryCode'];

/// Supports `mobile_number` (login API) and `phone` (account-details API).
Object? _readPhoneNumber(Map<dynamic, dynamic> json, String key) =>
    json['mobile_number'] ?? json['phone'] ?? json['fullMobileNumber'];

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    String? id,
    @JsonKey(readValue: _readPhoneNumber) String? fullMobileNumber,
    String? status,
    String? email,

    @Default('') String mobileNumber,
    @Default('') @JsonKey(readValue: _readCountryCode) String countryCode,
    @Default('') String password, // 6 digit numeric
    @Default('') String firstName,
    @Default('') String lastName,
    @Default(false) bool isVerified,
    @Default(false) bool twoFactorEnabled,
    @Default([]) List<WalletNetworkModel> wallets,
    @Default(false) bool walletsAvailable,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  String get fullPhoneNumber => fullMobileNumber?.isNotEmpty == true
      ? fullMobileNumber!
      : '$countryCode$mobileNumber';
  String get fullName => '$firstName $lastName';
}
