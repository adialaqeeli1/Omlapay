import 'dart:async';

import 'package:flutter/material.dart';

import '../services/forgot_passcode_service.dart';

class VerificationProvider extends ChangeNotifier {
  VerificationProvider({
    required String phoneNumber,
    required String countryCode,
  })  : _phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''),
        _countryCode = countryCode.trim();

  static const int otpLength = 6;
  static const int countdownStartSeconds = 5;

  final String _phoneNumber;
  final String _countryCode;

  String _otp = '';
  int _countdownSeconds = 0;
  Timer? _countdownTimer;
  bool _isVerifying = false;
  bool _hasError = false;
  bool _isRequestingOtp = false;

  String get phoneNumber => _phoneNumber;
  String get countryCode => _countryCode;
  String get otp => _otp;
  int get countdownSeconds => _countdownSeconds;
  bool get isResendCooldown => _countdownSeconds > 0;
  bool get isVerifying => _isVerifying;
  bool get hasError => _hasError;
  bool get isRequestingOtp => _isRequestingOtp;
  int get enteredDigitsCount => _otp.length;
  bool get isComplete => enteredDigitsCount == otpLength;
  bool get canEnterDigits => !_isVerifying;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;

  /// Returns formatted phone for display (e.g. "+966 xxx xxx 1234").
  String get formattedPhoneForDisplay {
    if (_phoneNumber.length < 4) {
      return '$_countryCode xxx xxx xxxx';
    }
    final lastFour = _phoneNumber.substring(_phoneNumber.length - 4);
    return '$_countryCode xxx xxx $lastFour';
  }

  void addDigit(String digit) {
    if (!canEnterDigits || _otp.length >= otpLength) return;
    final sanitized = digit.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitized.isEmpty) return;
    _otp = '$_otp${sanitized[0]}';
    _hasError = false;
    notifyListeners();
  }

  void removeLastDigit() {
    if (!canEnterDigits || _otp.isEmpty) return;
    _otp = _otp.substring(0, _otp.length - 1);
    _hasError = false;
    notifyListeners();
  }

  void clearOtp() {
    if (_otp.isEmpty && !_hasError) return;
    _otp = '';
    _hasError = false;
    notifyListeners();
  }

  /// Sets OTP from full string (e.g. from pin_code_fields). Keeps only digits.
  void setOtpFromString(String value) {
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
      await ForgotPasscodeService.requestOtp(_phoneNumber, _countryCode);
      _countdownSeconds = countdownStartSeconds;
      _countdownTimer?.cancel();
      _countdownTimer =
          Timer.periodic(const Duration(seconds: 1), _onCountdownTick);
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    if (!canResend) return;
    await requestOtp();
  }

  void _onCountdownTick(Timer timer) {
    if (_countdownSeconds <= 1) {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      _countdownSeconds = 0;
    } else {
      _countdownSeconds--;
    }
    notifyListeners();
  }

  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;

    _isVerifying = true;
    _hasError = false;
    notifyListeners();

    try {
      final isValid = await ForgotPasscodeService.verifyOtp(
        _phoneNumber,
        _countryCode,
        _otp,
      );
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

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
