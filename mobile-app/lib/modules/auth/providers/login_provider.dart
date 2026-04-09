import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/utils/api_message_helper.dart';
import '../../../core/utils/app_exception.dart';
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
  static const String extraCurrentPasscodeKey = 'currentPasscode';
  static const String extraResetTokenKey = 'resetToken';
  static const String extraPendingEmailKey = 'pendingEmail';

  /// Settings → change phone verify route: server-masked destination (e.g. +91 ******6660).
  static const String extraMaskedMobileKey = 'maskedMobile';

  /// Token from step2-verify used for step3/step4.
  static const String extraChangePhoneTokenKey = 'changePhoneToken';

  /// OTP resend window (`otp_expiry_seconds`).
  static const String extraOtpExpirySecondsKey = 'otpExpirySeconds';
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

  static bool _isApiSuccess(Map<String, dynamic> response) {
    final statusCode = response['statusCode'];
    if (statusCode is int && statusCode >= 200 && statusCode < 300) {
      return true;
    }
    return response['status']?.toString() == 'success';
  }

  static Map<String, dynamic>? _asJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final v = value.toLowerCase().trim();
      return v == 'true' || v == '1';
    }
    return false;
  }

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

        if (context.mounted) {
          final l10n = context.l10n!;
          if (!_isApiSuccess(response)) {
            SnackbarHelper.showError(
              context,
              ApiMessageHelper.localizedFromResponse(
                response,
                fallback: l10n.requestFailed,
                context: context,
              ),
            );
          } else {
            final data = _asJsonMap(response['data']);
            final maskedMobile = data?['masked_mobile']?.toString();
            final otpExpirySeconds =
                data?['otp_expiry_seconds'] as int? ??
                data?['expires_in'] as int? ??
                60;

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
        }
      } catch (e) {
        if (context.mounted) {
          final message = e is AppException
              ? e.localizedMessage(context.l10n)
              : context.l10n!.unknownError;
          SnackbarHelper.showError(context, message);
        }
      }
    } else {
      try {
        final checkResponse = await AuthService.checkUser(
          countryCode: currentPhoneCode,
          mobileNumber: digitsOnlyPhone,
        );

        if (!context.mounted) {
          _isSubmitting = false;
          notifyListeners();
          return;
        }

        final l10n = context.l10n!;

        if (!_isApiSuccess(checkResponse)) {
          SnackbarHelper.showError(
            context,
            ApiMessageHelper.localizedFromResponse(
              checkResponse,
              fallback: l10n.requestFailed,
              context: context,
            ),
          );
          _isSubmitting = false;
          notifyListeners();
          return;
        }

        final checkData = _asJsonMap(checkResponse['data']);
        final userExists =
            checkData != null && _readBool(checkData['userExists']);
        final hasPasscode =
            checkData != null && _readBool(checkData['hasPasscode']);

        if (userExists) {
          if (hasPasscode) {
            context.go(
              Routes.enterOrSetPasscode,
              extra: {
                extraModeKey: modeHardLogin,
                extraCountryCodeKey: currentPhoneCode,
                extraPhoneNumberKey: digitsOnlyPhone,
              },
            );
          } else {
            final registerResponse = await AuthService.registerRequest(
              countryCode: currentPhoneCode,
              mobileNumber: digitsOnlyPhone,
              termsAccepted: true,
            );

            if (!context.mounted) {
              _isSubmitting = false;
              notifyListeners();
              return;
            }

            if (!_isApiSuccess(registerResponse)) {
              SnackbarHelper.showError(
                context,
                ApiMessageHelper.localizedFromResponse(
                  registerResponse,
                  fallback: l10n.requestFailed,
                  context: context,
                ),
              );
            } else {
              final regData = _asJsonMap(registerResponse['data']);
              final otpExpirySeconds =
                  regData?['otp_expiry_seconds'] as int? ??
                  regData?['expires_in'] as int? ??
                  300;
              final maskedMobile =
                  regData?['masked_mobile']?.toString() ??
                  regData?['mobile_number']?.toString();

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
          }
        } else {
          SnackbarHelper.showError(context, l10n.userNotFound);
        }
      } catch (e) {
        if (context.mounted) {
          final message = e is AppException
              ? e.localizedMessage(context.l10n)
              : context.l10n!.unknownError;
          SnackbarHelper.showError(context, message);
        }
      }
    }
    _isSubmitting = false;
    notifyListeners();
  }
}
