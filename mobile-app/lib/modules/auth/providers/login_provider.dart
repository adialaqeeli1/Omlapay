import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/app_router.dart';

class LoginProvider extends ChangeNotifier {
  static const String countryCode = '+966';
  static const String extraCountryCodeKey = 'countryCode';
  static const String extraPhoneNumberKey = 'phoneNumber';
  static const String extraModeKey = 'mode';
  static const String modeHardLogin = 'hard_login';
  static const String modeSoftLogin = 'soft_login';
  static const String modeRegister = 'register';
  static const String modeResetPasscode = 'reset_passcode';
  static const String modeConfirmPasscode = 'confirm_passcode';
  static const String extraPendingPasscodeKey = 'pendingPasscode';
  static const int _requiredPhoneLength = 9;

  String _rawPhone = '';
  bool _isSubmitting = false;

  String get rawPhone => _rawPhone;
  bool get isSubmitting => _isSubmitting;

  String get digitsOnlyPhone => _rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

  bool get canContinue =>
      !_isSubmitting && digitsOnlyPhone.length == _requiredPhoneLength;

  void onPhoneChanged(String value) {
    if (_rawPhone == value) {
      return;
    }
    _rawPhone = value;
    notifyListeners();
  }

  Future<void> onContinuePressed(BuildContext context) async {
    if (!canContinue) {
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    context.go(
      Routes.enterOrSetPasscode,
      extra: {
        extraModeKey: modeHardLogin,
        extraCountryCodeKey: countryCode,
        extraPhoneNumberKey: digitsOnlyPhone,
      },
    );
    _isSubmitting = false;
    notifyListeners();
  }
}
