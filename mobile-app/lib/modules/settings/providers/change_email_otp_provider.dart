import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../auth/services/forgot_passcode_service.dart';

class ChangeEmailOtpProvider extends ChangeNotifier {
  ChangeEmailOtpProvider({required this.target});

  static const int otpLength = 6;
  static const int countdownStartSeconds = 5;

  final String target;

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
  bool get isComplete => _otp.length == otpLength;

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
      // Reuse existing mock OTP service; for email we pass target as identifier.
      await ForgotPasscodeService.requestOtp(target, '');
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

  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    notifyListeners();
    try {
      final isValid = await ForgotPasscodeService.verifyOtp(target, '', _otp);
      _hasError = !isValid;
      return isValid;
    } catch (_) {
      _hasError = true;
      return false;
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
