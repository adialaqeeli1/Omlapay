import 'package:flutter/widgets.dart';
import 'package:country_picker/country_picker.dart';

import '../../../core/models/change_phone/change_phone_models.dart';
import '../services/change_phone_service.dart';

class ChangePhoneFormProvider extends ChangeNotifier {
  ChangePhoneFormProvider({
    String? currentPhone,
    String? accountCountryDialCode,
    required this.changePhoneToken,
  }) : _currentPhoneDigits = _sanitizeDigits(currentPhone ?? ''),
       _accountCountryDialCode = _normalizeDialCode(accountCountryDialCode) {
    _initSelectedCountryFromDevice();
  }

  /// Token obtained from step 3 (verify passcode). Replaced by the fresh token
  /// returned by step 4 once the new phone number request succeeds.
  String changePhoneToken;

  /// Signed-in user's dial code (e.g. `+966`) for "same number" validation only.
  final String? _accountCountryDialCode;
  final String _currentPhoneDigits;
  String _phone = '';
  bool _submitted = false;
  bool _isSubmitting = false;
  Country? _selectedCountry;

  String get phone => _phone;
  bool get isSubmitted => _submitted;
  bool get isSubmitting => _isSubmitting;
  String get digitsOnly => _sanitizeDigits(_phone);
  Country get selectedCountry => _selectedCountry!;
  String get currentPhoneCode => '+${selectedCountry.phoneCode}';
  String get currentFlagEmoji => selectedCountry.flagEmoji;

  bool get isValidPhone => RegExp(r'^\d{7,15}$').hasMatch(digitsOnly);

  bool get isSameAsCurrentPhone {
    if (_currentPhoneDigits.isEmpty || digitsOnly != _currentPhoneDigits) {
      return false;
    }
    final account = _accountCountryDialCode;
    if (account == null || account.isEmpty) return false;
    return currentPhoneCode == account;
  }

  bool get canContinue => validationError == null;

  ChangePhoneValidationError? get validationError {
    if (!_submitted) return null;
    if (digitsOnly.isEmpty) {
      return ChangePhoneValidationError.empty;
    }
    if (!isValidPhone) {
      return ChangePhoneValidationError.invalidLength;
    }
    if (isSameAsCurrentPhone) {
      return ChangePhoneValidationError.sameAsCurrent;
    }
    return null;
  }

  void onPhoneChanged(String value) {
    final sanitized = _sanitizeDigits(value);
    final next = sanitized.length > 15 ? sanitized.substring(0, 15) : sanitized;
    if (_phone == next) return;
    _phone = next;
    notifyListeners();
  }

  void updateCountry(Country country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void markSubmitted() {
    _submitted = true;
    notifyListeners();
  }

  /// Calls [change-phone/step4-request-new-phone]. Returns `null` if validation
  /// fails. Updates [changePhoneToken] with the fresh token returned by the API
  /// (used by step 5 to verify the new phone OTP).
  Future<ChangePhoneRequestData?> submitRequestChange() async {
    markSubmitted();
    if (!canContinue) {
      notifyListeners();
      return null;
    }
    _isSubmitting = true;
    notifyListeners();
    try {
      final result = await ChangePhoneService.step4RequestNewPhone(
        changePhoneToken: changePhoneToken,
        countryCode: currentPhoneCode,
        newMobileNumber: digitsOnly,
      );
      final refreshedToken = result.changePhoneToken;
      if (refreshedToken != null && refreshedToken.isNotEmpty) {
        changePhoneToken = refreshedToken;
      }
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  static String _sanitizeDigits(String input) =>
      input.replaceAll(RegExp(r'[^0-9]'), '');

  /// Same default strategy as [LoginProvider]: device locale → Saudi Arabia.
  void _initSelectedCountryFromDevice() {
    try {
      final localeCountryCode =
          WidgetsBinding.instance.platformDispatcher.locale.countryCode;
      if (localeCountryCode != null && localeCountryCode.isNotEmpty) {
        _selectedCountry = CountryService().findByCode(localeCountryCode);
      }
    } catch (_) {}
    _selectedCountry ??= CountryService().findByCode('SA');
  }

  static String? _normalizeDialCode(String? code) {
    if (code == null) return null;
    final trimmed = code.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('+')) return trimmed;
    return '+$trimmed';
  }
}

enum ChangePhoneValidationError { empty, invalidLength, sameAsCurrent }
