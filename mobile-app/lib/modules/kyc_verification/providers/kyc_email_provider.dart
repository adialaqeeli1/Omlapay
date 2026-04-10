import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/extentions/string_extensions.dart';
import '../../../core/utils/app_exception.dart';
import '../services/kyc_email_service.dart';

class KycEmailProvider extends ChangeNotifier {
  static const int otpLength = 6;
  static const int countdownStartSeconds = 30;

  // -- Email state --
  String _email = '';
  bool _emailSubmitted = false;

  String get email => _email;
  bool get isEmailValid => _email.trim().isEmail;

  String? get emailError {
    if (!_emailSubmitted) return null;
    final trimmed = _email.trim();
    if (trimmed.isEmpty) return 'empty';
    if (!trimmed.isEmail) return 'invalid';
    return null;
  }

  void setEmail(String value) {
    _email = value;
    if (_emailSubmitted) notifyListeners();
  }

  void markEmailSubmitted() {
    _emailSubmitted = true;
    notifyListeners();
  }

  // -- OTP state --
  String _otp = '';
  int _countdownSeconds = 0;
  Timer? _timer;
  bool _isRequestingOtp = false;
  bool _isVerifying = false;
  bool _hasError = false;

  String get otp => _otp;
  int get countdownSeconds => _countdownSeconds;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;
  bool get isRequestingOtp => _isRequestingOtp;
  bool get isVerifying => _isVerifying;
  bool get hasError => _hasError;
  bool get isOtpComplete => _otp.length == otpLength;

  void setOtp(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final truncated =
        digits.length > otpLength ? digits.substring(0, otpLength) : digits;
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
      await KycEmailService.sendOtp(_email.trim());
      _countdownSeconds = countdownStartSeconds;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    if (!canResend) return;
    await requestOtp();
  }

  /// Returns `true` on success. Throws [AppException] on failure.
  Future<bool> verifyOtp() async {
    if (!isOtpComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    notifyListeners();
    try {
      final result = await KycEmailService.verifyOtp(_otp);
      _hasError = !result;
      return result;
    } on AppException {
      _hasError = true;
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
