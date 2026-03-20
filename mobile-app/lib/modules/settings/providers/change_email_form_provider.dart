import 'package:flutter/foundation.dart';

class ChangeEmailFormProvider extends ChangeNotifier {
  String _email = '';
  bool _submitted = false;

  String get email => _email;
  bool get isSubmitted => _submitted;

  bool get isValidEmail {
    return RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    ).hasMatch(_email.trim());
  }

  bool get canContinue => isValidEmail;

  String? get errorText {
    if (!_submitted) return null;
    if (_email.trim().isEmpty) return '';
    if (!isValidEmail) return '';
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
