import 'package:flutter/widgets.dart';
import 'package:country_picker/country_picker.dart';

import '../../../core/models/change_phone/change_phone_models.dart';
import '../../../core/utils/saudi_phone.dart';
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

  /// National number sent to the API (5XXXXXXXX), whichever form was typed.
  String get digitsOnly =>
      SaudiPhone.toNational(_phone) ?? _sanitizeDigits(_phone);
  Country get selectedCountry => _selectedCountry!;
  String get currentPhoneCode => SaudiPhone.dialCode;
  String get currentFlagEmoji => selectedCountry.flagEmoji;

  /// Saudi mobile numbers only, the same rule as the backend.
  bool get isValidPhone => SaudiPhone.isValid(_phone);

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
    // if (isSameAsCurrentPhone) {
    //   return ChangePhoneValidationError.sameAsCurrent;
    // }
    return null;
  }

  void onPhoneChanged(String value) {
    final sanitized = _sanitizeDigits(value);
    final next = sanitized.length > SaudiPhone.maxInputDigits
        ? sanitized.substring(0, SaudiPhone.maxInputDigits)
        : sanitized;
    if (_phone == next) return;
    _phone = next;
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

  /// Saudi mobile numbers only (same rule as the backend), so the country is fixed.
  void _initSelectedCountryFromDevice() {
    _selectedCountry = CountryService().findByCode(SaudiPhone.isoCode);
  }

  static String? _normalizeDialCode(String? code) {
    if (code == null) return null;
    final trimmed = code.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('+')) return trimmed;
    return '+$trimmed';
  }
}

enum ChangePhoneValidationError { empty, invalidLength }
