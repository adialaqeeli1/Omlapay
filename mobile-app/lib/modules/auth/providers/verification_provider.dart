import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/extentions/string_extensions.dart';
import '../services/auth_service.dart';
import '../services/forgot_passcode_service.dart';

class VerificationProvider extends ChangeNotifier {
  VerificationProvider({
    required String phoneNumber,
    required String countryCode,
    bool isRegistration = false,
    String? maskedMobile,
    int initialCountdown = countdownStartSeconds,
  })  : _phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''),
        _countryCode = countryCode.trim(),
        _isRegistration = isRegistration,
        _maskedMobile = maskedMobile,
        _initialCountdown = initialCountdown {
          if (_isRegistration && _initialCountdown > 0) {
            _countdownSeconds = _initialCountdown;
            _startCountdown();
          }
        }

  static const int otpLength = 6;
  static const int countdownStartSeconds = 5;

  static bool _isApiSuccess(Map<String, dynamic> response) {
    final statusCode = response['statusCode'];
    if (statusCode is int && statusCode >= 200 && statusCode < 300) {
      return true;
    }
    return response['status']?.toString() == 'success';
  }

  final String _phoneNumber;
  final String _countryCode;
  final bool _isRegistration;
  final String? _maskedMobile;
  final int _initialCountdown;

  String _otp = '';
  int _countdownSeconds = 0;
  Timer? _countdownTimer;
  bool _isVerifying = false;
  bool _hasError = false;
  bool _isRequestingOtp = false;
  String? _registrationToken;

  String get phoneNumber => _phoneNumber;
  String get countryCode => _countryCode;
  String get otp => _otp;
  String? get registrationToken => _registrationToken;
  int get countdownSeconds => _countdownSeconds;
  bool get isResendCooldown => _countdownSeconds > 0;
  bool get isVerifying => _isVerifying;
  bool get hasError => _hasError;
  bool get isRequestingOtp => _isRequestingOtp;
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
    final truncated =
        digits.length > otpLength ? digits.substring(0, otpLength) : digits;
    if (_otp == truncated) return;
    _otp = truncated;
    _hasError = false;
    notifyListeners();
  }

  Future<String?> requestOtp() async {
    if (_isRequestingOtp) return null;
    
    if (_isRegistration && _countdownSeconds > 0) {
      return null;
    }

    _isRequestingOtp = true;
    notifyListeners();

    try {
      String? message;
      if (_isRegistration) {
        final response = await AuthService.resendRegistrationOtp(
          countryCode: _countryCode,
          mobileNumber: _phoneNumber,
        );
        message = response['message'] as String?;
        final data = response['data'];
        if (data is Map<String, dynamic> && data['otp_expiry_seconds'] != null) {
          _countdownSeconds = data['otp_expiry_seconds'] as int;
        } else {
          _countdownSeconds = _initialCountdown > 0 ? _initialCountdown : countdownStartSeconds;
        }
      } else {
        await ForgotPasscodeService.requestOtp(_phoneNumber, _countryCode);
        _countdownSeconds = _initialCountdown > 0 ? _initialCountdown : countdownStartSeconds;
      }
      _startCountdown();
      return message;
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), _onCountdownTick);
  }

  Future<String?> resendOtp() async {
    if (!canResend) return null;
    return await requestOtp();
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
      if (_isRegistration) {
        final response = await AuthService.verifyRegistrationOtp(
          countryCode: _countryCode,
          mobileNumber: _phoneNumber,
          otp: _otp,
        );
        final data = response['data'];
        if (_isApiSuccess(response) &&
            data is Map<String, dynamic> &&
            data['registration_token'] != null) {
          _registrationToken = data['registration_token'] as String;
          _hasError = false;
          return true;
        } else {
          _hasError = true;
          return false;
        }
      } else {
        final isValid = await ForgotPasscodeService.verifyOtp(
          _phoneNumber,
          _countryCode,
          _otp,
        );
        _hasError = !isValid;
        return isValid;
      }
    } catch (e) {
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
