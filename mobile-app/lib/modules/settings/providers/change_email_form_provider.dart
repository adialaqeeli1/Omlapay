import 'package:flutter/foundation.dart';

class ChangeEmailFormProvider extends ChangeNotifier {
  ChangeEmailFormProvider({String? currentEmail})
    : _currentEmail = currentEmail?.trim().toLowerCase() ?? '';

  final String _currentEmail;
  String _email = '';
  bool _submitted = false;

  String get email => _email;
  bool get isSubmitted => _submitted;
  String get normalizedEmail => _email.trim().toLowerCase();

  bool get isValidEmail {
    return RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    ).hasMatch(normalizedEmail);
  }

  bool get isSameAsCurrentEmail =>
      _currentEmail.isNotEmpty && normalizedEmail == _currentEmail;

  bool get canContinue => validationError == null;

  ChangeEmailValidationError? get validationError {
    if (!_submitted) return null;
    if (normalizedEmail.isEmpty) {
      return ChangeEmailValidationError.empty;
    }
    if (!isValidEmail) {
      return ChangeEmailValidationError.invalid;
    }
    // if (isSameAsCurrentEmail) {
    //   return ChangeEmailValidationError.sameAsCurrent;
    // }
    return null;
  }

  void onEmailChanged(String value) {
    if (_email == value) return;
    _email = value;
    notifyListeners();
  }

  void markSubmitted() {
    _submitted = true;
    notifyListeners();
  }
}

enum ChangeEmailValidationError { empty, invalid }
