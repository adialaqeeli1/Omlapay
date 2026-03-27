import '../models/user_model/user_model.dart';

/// Parts needed for auth/forgot-passcode requests (`country_code` + `mobile_number`).
typedef AuthPhoneParts = ({String countryCode, String mobileNumber});

/// Returns dial code (e.g. `+966`) and national digits for API calls.
///
/// Prefer explicit [UserModel.countryCode] + [UserModel.mobileNumber] when set.
/// Otherwise parses [UserModel.fullMobileNumber], which the backend sets to
/// `buildFullMobileNumber(country_code, mobile_number)` (only `mobile_number` in JSON).
AuthPhoneParts authPhonePartsForUser(UserModel user) {
  final trimmedCc = user.countryCode.trim();
  final national = user.mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (trimmedCc.isNotEmpty && national.isNotEmpty) {
    final dial = trimmedCc.startsWith('+') ? trimmedCc : '+$trimmedCc';
    return (countryCode: dial, mobileNumber: national);
  }
  return splitFullMobileNumber(user.fullMobileNumber);
}

/// Splits the concatenated full number from the API into dial + national parts.
/// Matches backend-supported codes: `+966` (9 digits) and `+91` (10 digits).
AuthPhoneParts splitFullMobileNumber(String? fullMobileNumber) {
  if (fullMobileNumber == null || fullMobileNumber.isEmpty) {
    return (countryCode: '', mobileNumber: '');
  }
  final digits = fullMobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('966') && digits.length == 12) {
    return (countryCode: '+966', mobileNumber: digits.substring(3));
  }
  if (digits.startsWith('91') && digits.length == 12) {
    return (countryCode: '+91', mobileNumber: digits.substring(2));
  }
  return (countryCode: '', mobileNumber: '');
}
