/// Saudi mobile numbers only, matching the backend's rule (ALLOWED_PHONE_COUNTRY_CODES=966):
/// +966 followed by 9 digits starting with 5.
///
/// Accepts the forms people type or paste: 5XXXXXXXX, 05XXXXXXXX, 9665XXXXXXXX,
/// 009665XXXXXXXX and +9665XXXXXXXX (spaces, dashes and brackets are ignored).
class SaudiPhone {
  SaudiPhone._();

  /// Dial code sent to the API as `country_code`.
  static const String dialCode = '+966';

  /// ISO country code used for the flag shown next to the number.
  static const String isoCode = 'SA';

  /// Longest accepted input in digits (009665XXXXXXXX).
  static const int maxInputDigits = 14;

  static final RegExp _nationalMobile = RegExp(r'^5\d{8}$');

  /// The 9-digit national number (5XXXXXXXX), or null when [input] is not a Saudi mobile number.
  static String? toNational(String input) {
    var digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00966')) {
      digits = digits.substring(5);
    } else if (digits.startsWith('966') && digits.length == 12) {
      digits = digits.substring(3);
    } else if (digits.startsWith('0') && digits.length == 10) {
      digits = digits.substring(1);
    }
    return _nationalMobile.hasMatch(digits) ? digits : null;
  }

  static bool isValid(String input) => toNational(input) != null;

  /// Whether to show the "Saudi mobile numbers only" hint: enough digits were typed for a
  /// complete number, but it is not a Saudi mobile number.
  static bool shouldShowError(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 9 && !isValid(input);
  }
}
