import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../../auth/services/forgot_passcode_service.dart';
import '../services/change_email_service.dart';

class ChangeEmailOtpProvider extends ChangeNotifier {
  ChangeEmailOtpProvider._({
    String? newEmail,
    String? phoneCountryCode,
    String? phoneMobileNumber,
  }) : _newEmail = newEmail,
       _phoneCountryCode = phoneCountryCode,
       _phoneMobileNumber = phoneMobileNumber;

  factory ChangeEmailOtpProvider.forNewEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(email, 'email', 'must not be empty');
    }
    return ChangeEmailOtpProvider._(newEmail: trimmed);
  }

  factory ChangeEmailOtpProvider.forPhone({
    required String countryCode,
    required String mobileNumber,
  }) {
    return ChangeEmailOtpProvider._(
      phoneCountryCode: countryCode.trim(),
      phoneMobileNumber: mobileNumber.replaceAll(RegExp(r'[^0-9]'), ''),
    );
  }

  static const int otpLength = 6;
  static const int countdownStartSeconds = 5;

  final String? _newEmail;
  final String? _phoneCountryCode;
  final String? _phoneMobileNumber;

  bool get _isNewEmailFlow {
    final e = _newEmail;
    return e != null && e.isNotEmpty;
  }

  String _otp = '';
  int _countdownSeconds = 0;
  Timer? _timer;
  bool _isRequestingOtp = false;
  bool _isVerifying = false;
  bool _hasError = false;
  bool _phoneOtpEverRequested = false;

  String get otp => _otp;
  int get countdownSeconds => _countdownSeconds;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;
  bool get isRequestingOtp => _isRequestingOtp;
  bool get isVerifying => _isVerifying;
  bool get hasError => _hasError;
  bool get isComplete => _otp.length == otpLength;

  void setOtp(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final truncated = digits.length > otpLength
        ? digits.substring(0, otpLength)
        : digits;
    if (_otp == truncated) return;
    _otp = truncated;
    _hasError = false;
    notifyListeners();
  }

  Future<void> requestOtp() async {
    if (_isRequestingOtp) return;
    _isRequestingOtp = true;
    notifyListeners();
    try {
      if (_isNewEmailFlow) {
        final email = _newEmail!;
        final expiry = await ChangeEmailService.requestChange(newEmail: email);
        _countdownSeconds = expiry > 0 ? expiry : countdownStartSeconds;
      } else {
        await ForgotPasscodeService.requestOtp(
          _phoneMobileNumber!,
          _phoneCountryCode!,
        );
        _phoneOtpEverRequested = true;
        _countdownSeconds = countdownStartSeconds;
      }
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    if (!canResend) return;
    _isRequestingOtp = true;
    notifyListeners();
    try {
      if (_isNewEmailFlow) {
        final email = _newEmail!;
        final expiry = await ChangeEmailService.requestChange(newEmail: email);
        _countdownSeconds = expiry > 0 ? expiry : countdownStartSeconds;
      } else if (_phoneOtpEverRequested) {
        await ForgotPasscodeService.resendOtp(
          _phoneMobileNumber!,
          _phoneCountryCode!,
        );
        _countdownSeconds = countdownStartSeconds;
      } else {
        await ForgotPasscodeService.requestOtp(
          _phoneMobileNumber!,
          _phoneCountryCode!,
        );
        _phoneOtpEverRequested = true;
        _countdownSeconds = countdownStartSeconds;
      }
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  /// Returns true on success. Throws [AppException] with a localized API
  /// message on failure. Forgot-passcode verify returns false when the server
  /// rejects OTP without throwing.
  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    notifyListeners();
    try {
      if (_isNewEmailFlow) {
        await ChangeEmailService.verifyChange(newEmail: _newEmail!, otp: _otp);
        _hasError = false;
        return true;
      }
      final isValid = await ForgotPasscodeService.verifyOtp(
        _phoneMobileNumber!,
        _phoneCountryCode!,
        _otp,
        requireResetToken: false,
      );
      _hasError = !isValid;
      return isValid;
    } on AppException {
      rethrow;
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  void _tick(Timer timer) {
    if (_countdownSeconds <= 1) {
      _timer?.cancel();
      _timer = null;
      _countdownSeconds = 0;
    } else {
      _countdownSeconds--;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
