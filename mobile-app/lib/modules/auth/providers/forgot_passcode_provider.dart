import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/extentions/string_extensions.dart';
import '../services/forgot_passcode_service.dart';

class ForgotPasscodeProvider extends ChangeNotifier {
  ForgotPasscodeProvider({
    required String phoneNumber,
    required String countryCode,
    int initialCountdown = ForgotPasscodeService.defaultOtpExpirySeconds,
    String? maskedMobile,
    String? maskedEmail,
    String? verificationType,
  }) : _phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''),
       _countryCode = countryCode.trim(),
       _initialCountdown = initialCountdown,
       _maskedMobile = maskedMobile,
       _maskedEmail = maskedEmail,
       _verificationType = verificationType {
    // If the caller already triggered the request OTP API (e.g. from the
    // "Forgot passcode" tap on the previous screen) and passed a positive
    // [initialCountdown], start the countdown immediately so the screen does
    // not fire a duplicate request when it mounts.
    if (initialCountdown > 0) {
      _countdownSeconds = initialCountdown;
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        _onCountdownTick,
      );
    }
  }

  static const int otpLength = 6;
  final String _phoneNumber;
  final String _countryCode;
  final int _initialCountdown;

  String _phoneOtp = '';
  String _emailOtp = '';
  int _countdownSeconds = 0;
  Timer? _countdownTimer;
  bool _isVerifying = false;
  bool _hasError = false;
  bool _isRequestingOtp = false;
  String? _resetToken;
  String? _maskedMobile;
  String? _maskedEmail;
  String? _verificationType;

  String get phoneNumber => _phoneNumber;
  String get countryCode => _countryCode;

  /// Returns formatted phone for display (e.g. "+966 XXX XXX 1234").
  /// Prefers the server-provided masked value when available.
  String get formattedPhoneForDisplay {
    final fromServer = _maskedMobile?.trim();
    if (fromServer != null && fromServer.isNotEmpty) {
      return fromServer;
    }
    return maskedPhoneForDisplay(_countryCode, _phoneNumber);
  }

  String? get maskedEmail => _maskedEmail;
  String? get verificationType => _verificationType;

  /// True when the API indicates that an OTP was also dispatched to the
  /// user's email (2FA enabled). The presence of [maskedEmail] is the
  /// source of truth.
  bool get isEmailOtpRequired => (_maskedEmail ?? '').trim().isNotEmpty;

  String get phoneOtp => _phoneOtp;
  String get emailOtp => _emailOtp;
  int get countdownSeconds => _countdownSeconds;
  bool get isResendCooldown => _countdownSeconds > 0;
  bool get isVerifying => _isVerifying;
  bool get hasError => _hasError;
  bool get isRequestingOtp => _isRequestingOtp;
  bool get isPhoneOtpComplete => _phoneOtp.length == otpLength;
  bool get isEmailOtpComplete => _emailOtp.length == otpLength;
  bool get isComplete =>
      isPhoneOtpComplete && (!isEmailOtpRequired || isEmailOtpComplete);
  bool get canEnterDigits => !_isVerifying;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;
  String? get resetToken => _resetToken;

  /// Sets phone OTP from full string (e.g. from single TextField). Keeps
  /// only digits.
  void setPhoneOtpFromString(String value) {
    final truncated = _sanitize(value);
    if (_phoneOtp == truncated) return;
    _phoneOtp = truncated;
    _hasError = false;
    notifyListeners();
  }

  /// Sets email OTP from full string. Keeps only digits.
  void setEmailOtpFromString(String value) {
    final truncated = _sanitize(value);
    if (_emailOtp == truncated) return;
    _emailOtp = truncated;
    _hasError = false;
    notifyListeners();
  }

  String _sanitize(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length > otpLength ? digits.substring(0, otpLength) : digits;
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
      _applyOtpResponse(response);
      return response.message;
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  Future<String?> resendOtp() async {
    if (!canResend || _isRequestingOtp) return null;
    _isRequestingOtp = true;
    _phoneOtp = '';
    _emailOtp = '';
    notifyListeners();

    try {
      final response = await ForgotPasscodeService.resendOtp(
        _phoneNumber,
        _countryCode,
      );
      _applyOtpResponse(response);
      return response.message;
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  void _applyOtpResponse(ForgotPasscodeOtpResponse response) {
    _maskedMobile = response.maskedMobile ?? _maskedMobile;
    _maskedEmail = response.maskedEmail;
    _verificationType = response.verificationType ?? _verificationType;
    _countdownSeconds = response.otpExpirySeconds > 0
        ? response.otpExpirySeconds
        : _initialCountdown;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      _onCountdownTick,
    );
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
        _phoneOtp,
        emailOtp: isEmailOtpRequired ? _emailOtp : null,
      );
      _resetToken = response.resetToken;
      _hasError = false;
      return true;
    } catch (_) {
      _hasError = true;
      _phoneOtp = '';
      _emailOtp = '';
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
