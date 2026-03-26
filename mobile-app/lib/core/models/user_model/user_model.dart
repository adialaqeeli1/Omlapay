import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    String? id,
    @JsonKey(name: 'mobile_number') String? fullMobileNumber,
    String? status,
    
    @Default('') String mobileNumber,
    @Default('') String countryCode,
    @Default('') String password, // 6 digit numeric
    @Default('') String firstName,
    @Default('') String lastName,
    @Default(false) bool isVerified,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  String get fullPhoneNumber =>
      fullMobileNumber?.isNotEmpty == true ? fullMobileNumber! : '$countryCode$mobileNumber';
  String get fullName => '$firstName $lastName';
}
