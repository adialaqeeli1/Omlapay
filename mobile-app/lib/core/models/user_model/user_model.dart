import 'package:freezed_annotation/freezed_annotation.dart';

import '../wallet_model/wallet_model.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Supports both API snake_case (`country_code`) and stored camelCase (`countryCode`).
Object? _readCountryCode(Map<dynamic, dynamic> json, String key) =>
    json['country_code'] ?? json['countryCode'];

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    String? id,
    @JsonKey(name: 'mobile_number') String? fullMobileNumber,
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
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  String get fullPhoneNumber => fullMobileNumber?.isNotEmpty == true
      ? fullMobileNumber!
      : '$countryCode$mobileNumber';
  String get fullName => '$firstName $lastName';
}
