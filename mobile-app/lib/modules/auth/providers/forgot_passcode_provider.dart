import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/extentions/string_extensions.dart';
import '../services/forgot_passcode_service.dart';

class ForgotPasscodeProvider extends ChangeNotifier {
  ForgotPasscodeProvider({
    required String phoneNumber,
    required String countryCode,
    int initialCountdown = ForgotPasscodeService.defaultOtpExpirySeconds,
  }) : _phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''),
       _countryCode = countryCode.trim(),
       _initialCountdown = initialCountdown;

  static const int otpLength = 6;
  final String _phoneNumber;
  final String _countryCode;
  final int _initialCountdown;

  String _otp = '';
  int _countdownSeconds = 0;
  Timer? _countdownTimer;
  bool _isVerifying = false;
  bool _hasError = false;
  bool _isRequestingOtp = false;
  String? _resetToken;

  String get phoneNumber => _phoneNumber;
  String get countryCode => _countryCode;

  /// Returns formatted phone for display (e.g. "+966 XXX XXX 1234").
  String get formattedPhoneForDisplay =>
      maskedPhoneForDisplay(_countryCode, _phoneNumber);
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
  String? get resetToken => _resetToken;

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

  /// Sets OTP from full string (e.g. from single TextField). Keeps only digits.
  void setOtpFromString(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final truncated = digits.length > otpLength
        ? digits.substring(0, otpLength)
        : digits;
    if (_otp == truncated) return;
    _otp = truncated;
    _hasError = false;
    notifyListeners();
  }

  Future<String?> requestOtp() async {
    if (_isRequestingOtp) return null;
    _isRequestingOtp = true;
    notifyListeners();

    try {
      final response = await ForgotPasscodeService.requestOtp(
        _phoneNumber,
        _countryCode,
      );
      _countdownSeconds = response.otpExpirySeconds > 0
          ? response.otpExpirySeconds
          : _initialCountdown;
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        _onCountdownTick,
      );
      return response.message;
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  Future<String?> resendOtp() async {
    if (!canResend || _isRequestingOtp) return null;
    _isRequestingOtp = true;
    notifyListeners();

    try {
      final response = await ForgotPasscodeService.resendOtp(
        _phoneNumber,
        _countryCode,
      );
      _countdownSeconds = response.otpExpirySeconds > 0
          ? response.otpExpirySeconds
          : _initialCountdown;
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        _onCountdownTick,
      );
      return response.message;
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
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
      final response = await ForgotPasscodeService.verifyOtpAndGetResetToken(
        _phoneNumber,
        _countryCode,
        _otp,
      );
      _resetToken = response.resetToken;
      _hasError = false;
      return true;
    } catch (_) {
      _hasError = true;
      rethrow;
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
