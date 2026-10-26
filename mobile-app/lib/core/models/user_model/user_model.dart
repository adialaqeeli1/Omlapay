import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String mobileNumber,
    required String countryCode,
    required String password, // 6 digit numeric
    required String firstName,
    required String lastName,
    @Default(false) bool isVerified,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  String get fullPhoneNumber => '$countryCode$mobileNumber';
  String get fullName => '$firstName $lastName';
}
