import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';

import '../../../core/utils/snackbar_helper.dart';
import '../../../routes/app_router.dart';
import '../services/auth_service.dart';

class LoginProvider extends ChangeNotifier {
  static const String defaultCountryCode = '+966';
  static const String extraCountryCodeKey = 'countryCode';
  static const String extraPhoneNumberKey = 'phoneNumber';
  static const String extraRegistrationTokenKey = 'registrationToken';
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
  static const String extraResetTokenKey = 'resetToken';
  static const String extraPendingEmailKey = 'pendingEmail';
  static const String extraVerificationPurposeKey = 'verificationPurpose';
  static const String purposeChangePasscode = 'change_passcode';
  static const String purposeChangeEmailPhone = 'change_email_phone';

  String _rawPhone = '';
  bool _isSubmitting = false;
  Country? _selectedCountry;

  LoginProvider() {
    _initDefaultCountry();
  }

  void _initDefaultCountry() {
    try {
      final localeCountryCode =
          WidgetsBinding.instance.platformDispatcher.locale.countryCode;
      if (localeCountryCode != null && localeCountryCode.isNotEmpty) {
        _selectedCountry = CountryService().findByCode(localeCountryCode);
      }
    } catch (_) {}
    _selectedCountry ??= CountryService().findByCode('SA');
  }

  Country get selectedCountry => _selectedCountry!;
  String get currentPhoneCode => '+${selectedCountry.phoneCode}';
  String get currentFlagEmoji => selectedCountry.flagEmoji;

  void updateCountry(Country country) {
    _selectedCountry = country;
    notifyListeners();
  }

  String get rawPhone => _rawPhone;
  bool get isSubmitting => _isSubmitting;

  String get digitsOnlyPhone => _rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

  bool get canContinue =>
      !_isSubmitting && RegExp(r'^\d{7,15}$').hasMatch(digitsOnlyPhone);

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
      try {
        final response = await AuthService.registerRequest(
          countryCode: currentPhoneCode,
          mobileNumber: digitsOnlyPhone,
          termsAccepted: true,
        );

        final data = response['data'] as Map<String, dynamic>?;
        final maskedMobile = data?['masked_mobile'] as String?;
        final otpExpirySeconds = data?['otp_expiry_seconds'] as int? ?? 60;

        if (context.mounted) {
          context.push(
            Routes.registerVerification,
            extra: {
              extraCountryCodeKey: currentPhoneCode,
              extraPhoneNumberKey: digitsOnlyPhone,
              'maskedMobile': maskedMobile,
              'otpExpirySeconds': otpExpirySeconds,
              'isRegistration': true,
            },
          );
        }
      } catch (e) {
        if (context.mounted) {
          SnackbarHelper.showError(context, e.toString());
        }
      }
    } else {
      try {
        final checkResponse = await AuthService.checkUser(
          countryCode: currentPhoneCode,
          mobileNumber: digitsOnlyPhone,
        );

        if (checkResponse['status'] == 'success') {
          final data = checkResponse['data'];
          if (data != null && data['userExists'] == true) {
            if (data['hasPasscode'] == true) {
              if (context.mounted) {
                context.go(
                  Routes.enterOrSetPasscode,
                  extra: {
                    extraModeKey: modeHardLogin,
                    extraCountryCodeKey: currentPhoneCode,
                    extraPhoneNumberKey: digitsOnlyPhone,
                  },
                );
              }
            } else {
              final registerResponse = await AuthService.registerRequest(
                countryCode: currentPhoneCode,
                mobileNumber: digitsOnlyPhone,
                termsAccepted: true,
              );
              
              if (registerResponse['status'] == 'success') {
                final otpExpirySeconds = registerResponse['data']?['expires_in'] ?? 300;
                final maskedMobile = registerResponse['data']?['mobile_number'];

                if (context.mounted) {
                  context.push(
                    Routes.registerVerification,
                    extra: {
                      extraCountryCodeKey: currentPhoneCode,
                      extraPhoneNumberKey: digitsOnlyPhone,
                      'maskedMobile': maskedMobile,
                      'otpExpirySeconds': otpExpirySeconds,
                      'isRegistration': true,
                    },
                  );
                }
              } else {
                if (context.mounted) {
                  SnackbarHelper.showError(
                    context, 
                    registerResponse['message']?.toString() ?? 'Failed to send OTP',
                  );
                }
              }
            }
          } else {
            if (context.mounted) {
              SnackbarHelper.showError(context, 'User not found with this mobile number.');
            }
          }
        } else {
          if (context.mounted) {
            SnackbarHelper.showError(
              context, 
              checkResponse['message']?.toString() ?? 'Failed to verify user',
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          SnackbarHelper.showError(context, e.toString());
        }
      }
    }
    _isSubmitting = false;
    notifyListeners();
  }
}
