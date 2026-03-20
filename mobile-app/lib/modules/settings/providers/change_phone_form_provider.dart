import 'package:flutter/foundation.dart';

class ChangePhoneFormProvider extends ChangeNotifier {
  ChangePhoneFormProvider({this.countryCode = '+966', String? currentPhone})
    : _currentPhoneDigits = _sanitizeDigits(currentPhone ?? '');

  final String countryCode;
  final String _currentPhoneDigits;
  String _phone = '';
  bool _submitted = false;

  String get phone => _phone;
  bool get isSubmitted => _submitted;
  String get digitsOnly => _sanitizeDigits(_phone);

  bool get isValidPhone => digitsOnly.length == 9;

  bool get isSameAsCurrentPhone =>
      _currentPhoneDigits.isNotEmpty && digitsOnly == _currentPhoneDigits;

  bool get canContinue => validationError == null;

  ChangePhoneValidationError? get validationError {
    if (!_submitted) return null;
    if (digitsOnly.isEmpty) {
      return ChangePhoneValidationError.empty;
    }
    if (digitsOnly.length != 9) {
      return ChangePhoneValidationError.invalidLength;
    }
    if (isSameAsCurrentPhone) {
      return ChangePhoneValidationError.sameAsCurrent;
    }
    return null;
  }

  void onPhoneChanged(String value) {
    final sanitized = _sanitizeDigits(value);
    final next = sanitized.length > 9 ? sanitized.substring(0, 9) : sanitized;
    if (_phone == next) return;
    _phone = next;
    notifyListeners();
  }

  void markSubmitted() {
    _submitted = true;
    notifyListeners();
  }

  static String _sanitizeDigits(String input) =>
      input.replaceAll(RegExp(r'[^0-9]'), '');
}

enum ChangePhoneValidationError { empty, invalidLength, sameAsCurrent }
