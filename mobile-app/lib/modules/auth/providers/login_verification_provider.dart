import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/extentions/string_extensions.dart';
import '../services/auth_service.dart';

/// Owns OTP-screen state for the new hard-login flow.
/// Backed by `/v1/auth/login/{send-otp,verify-otp,resend-otp}`. After
/// `verifyOtp()` returns true, [otpVerificationToken] holds the token the
/// final `/v1/auth/login` call needs.
class LoginVerificationProvider extends ChangeNotifier {
  LoginVerificationProvider({
    required String countryCode,
    required String phoneNumber,
    String? maskedMobile,
    int initialCountdown = countdownStartSeconds,
  })  : _countryCode = countryCode.trim(),
        _phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''),
        _maskedMobile = maskedMobile,
        _initialCountdown = initialCountdown;

  static const int otpLength = 6;
  static const int countdownStartSeconds = 60;

  final String _countryCode;
  final String _phoneNumber;
  final String? _maskedMobile;
  final int _initialCountdown;

  String _otp = '';
  int _countdownSeconds = 0;
  Timer? _countdownTimer;
  bool _isRequestingOtp = false;
  bool _isVerifying = false;
  bool _hasError = false;
  String? _otpVerificationToken;

  String get countryCode => _countryCode;
  String get phoneNumber => _phoneNumber;
  String get otp => _otp;
  String? get otpVerificationToken => _otpVerificationToken;
  int get countdownSeconds => _countdownSeconds;
  bool get isResendCooldown => _countdownSeconds > 0;
  bool get isRequestingOtp => _isRequestingOtp;
  bool get isVerifying => _isVerifying;
  bool get hasError => _hasError;
  int get enteredDigitsCount => _otp.length;
  bool get isComplete => enteredDigitsCount == otpLength;
  bool get canEnterDigits => !_isVerifying;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;

  /// Returns formatted phone for display (e.g. "+966 XXX XXX 1234").
  String get formattedPhoneForDisplay =>
      _maskedMobile ?? maskedPhoneForDisplay(_countryCode, _phoneNumber);

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
    final truncated = digits.length > otpLength
        ? digits.substring(0, otpLength)
        : digits;
    if (_otp == truncated) return;
    _otp = truncated;
    _hasError = false;
    notifyListeners();
  }

  /// Initial OTP request — fires when the screen mounts via
  /// `OtpVerificationView.onInitialRequest`. Returns the API success message
  /// (or null) so the screen can show it in a snackbar if desired.
  Future<String?> requestOtp() async {
    if (_isRequestingOtp) return null;
    _isRequestingOtp = true;
    notifyListeners();
    try {
      final response = await AuthService.loginSendOtp(
        countryCode: _countryCode,
        mobileNumber: _phoneNumber,
      );
      _applyCountdownFromResponse(response);
      _startCountdown();
      return response['message'] as String?;
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  Future<String?> resendOtp() async {
    if (!canResend) return null;
    _isRequestingOtp = true;
    notifyListeners();
    try {
      final response = await AuthService.loginResendOtp(
        countryCode: _countryCode,
        mobileNumber: _phoneNumber,
      );
      _applyCountdownFromResponse(response);
      _startCountdown();
      return response['message'] as String?;
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  /// Verifies the entered OTP. On success, [otpVerificationToken] is set and
  /// the method returns true. On failure, [hasError] is set and returns false.
  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    notifyListeners();
    try {
      final response = await AuthService.loginVerifyOtp(
        countryCode: _countryCode,
        mobileNumber: _phoneNumber,
        otp: _otp,
      );
      final isSuccess = _isApiSuccess(response);
      final data = response['data'];
      final token = data is Map<String, dynamic>
          ? data['otpVerificationToken']?.toString()
          : null;
      if (isSuccess && token != null && token.isNotEmpty) {
        _otpVerificationToken = token;
        _hasError = false;
        return true;
      }
      _hasError = true;
      _otp = '';
      return false;
    } catch (e) {
      _hasError = true;
      _otp = '';
      rethrow;
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  void _applyCountdownFromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    int? expirySeconds;
    if (data is Map<String, dynamic>) {
      final raw = data['otp_expiry_seconds'] ?? data['expires_in_seconds'];
      if (raw is int) expirySeconds = raw;
    }
    _countdownSeconds = expirySeconds ??
        (_initialCountdown > 0 ? _initialCountdown : countdownStartSeconds);
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), _onCountdownTick);
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

  static bool _isApiSuccess(Map<String, dynamic> response) {
    final statusCode = response['statusCode'];
    if (statusCode is int && statusCode >= 200 && statusCode < 300) {
      return true;
    }
    return response['status']?.toString() == 'success';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
