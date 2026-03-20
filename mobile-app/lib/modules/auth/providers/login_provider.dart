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

  /// Settings → change passcode: verify current PIN, then new + confirm, then SMS verification.
  static const String modeChangePasscodeCurrent = 'change_passcode_current';
  static const String modeChangePasscodeNew = 'change_passcode_new';
  static const String modeChangePasscodeConfirm = 'change_passcode_confirm';
  static const String modeChangeEmailConfirmPasscode =
      'change_email_confirm_passcode';
  static const String extraPendingPasscodeKey = 'pendingPasscode';
  static const String extraPendingEmailKey = 'pendingEmail';
  static const String extraVerificationPurposeKey = 'verificationPurpose';
  static const String purposeChangePasscode = 'change_passcode';
  static const String purposeChangeEmailPhone = 'change_email_phone';
  static const String purposeChangeEmailNewEmail = 'change_email_new_email';
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

  Future<void> onContinuePressed(
    BuildContext context, {
    bool isRegister = false,
  }) async {
    if (!canContinue) {
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    if (isRegister) {
      context.go(
        Routes.registerVerification,
        extra: {
          extraCountryCodeKey: countryCode,
          extraPhoneNumberKey: digitsOnlyPhone,
        },
      );
    } else {
      context.go(
        Routes.enterOrSetPasscode,
        extra: {
          extraModeKey: modeHardLogin,
          extraCountryCodeKey: countryCode,
          extraPhoneNumberKey: digitsOnlyPhone,
        },
      );
    }
    _isSubmitting = false;
    notifyListeners();
  }
}
