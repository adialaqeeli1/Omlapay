import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../services/change_email_service.dart';

/// OTP provider for change-email step1/step2 (verify current phone).
///
/// When [twoFactorEnabled] is true, the provider also tracks an email OTP
/// that the API sends alongside the phone OTP.
class ChangeEmailPhoneOtpProvider extends ChangeNotifier {
  ChangeEmailPhoneOtpProvider({
    required this.twoFactorEnabled,
    this.fallbackMaskedEmail,
  });

  static const int otpLength = 6;

  final bool twoFactorEnabled;

  /// Fallback masked email from UserModel, used when the API doesn't return one.
  final String? fallbackMaskedEmail;

  // Phone OTP state
  String _otp = '';
  String _maskedPhone = '';
  bool _hasError = false;

  // Email OTP state (only used when 2FA is enabled)
  String _emailOtp = '';
  bool _emailHasError = false;
  String? _maskedEmail;

  // Shared state
  int _countdownSeconds = 0;
  Timer? _timer;
  bool _isRequestingOtp = false;
  bool _isVerifying = false;
  String? _changeEmailToken;

  String get otp => _otp;
  String get maskedPhone => _maskedPhone;
  int get countdownSeconds => _countdownSeconds;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;
  bool get isRequestingOtp => _isRequestingOtp;
  bool get isVerifying => _isVerifying;
  bool get hasError => _hasError;
  String? get changeEmailToken => _changeEmailToken;

  String get emailOtp => _emailOtp;
  bool get emailHasError => _emailHasError;
  String get maskedEmail => _maskedEmail ?? fallbackMaskedEmail ?? '';

  bool get isPhoneOtpComplete => _otp.length == otpLength;
  bool get isEmailOtpComplete => _emailOtp.length == otpLength;

  bool get isComplete =>
      isPhoneOtpComplete && (!twoFactorEnabled || isEmailOtpComplete);

  void setOtp(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final truncated =
        digits.length > otpLength ? digits.substring(0, otpLength) : digits;
    if (_otp == truncated) return;
    _otp = truncated;
    _hasError = false;
    notifyListeners();
  }

  void setEmailOtp(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final truncated =
        digits.length > otpLength ? digits.substring(0, otpLength) : digits;
    if (_emailOtp == truncated) return;
    _emailOtp = truncated;
    _emailHasError = false;
    notifyListeners();
  }

  void _startCountdown(int seconds) {
    final safe = seconds <= 0 ? 60 : seconds;
    _timer?.cancel();
    _countdownSeconds = safe;
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  /// Calls step1-request to send OTP to the user's current phone.
  /// When 2FA is enabled, the API also sends an OTP to the user's email.
  Future<void> requestOtp() async {
    if (_isRequestingOtp) return;
    _isRequestingOtp = true;
    notifyListeners();
    try {
      final result = await ChangeEmailService.step1Request();
      _maskedPhone = result.maskedPhone;
      if (result.maskedEmail != null) {
        _maskedEmail = result.maskedEmail;
      }
      _startCountdown(result.otpExpirySeconds);
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    if (!canResend) return;
    await requestOtp();
  }

  /// Calls step2-verify. Returns true on success and stores [changeEmailToken].
  /// When 2FA is enabled, also sends the [emailOtp].
  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    _emailHasError = false;
    notifyListeners();
    try {
      final result = await ChangeEmailService.step2Verify(
        otp: _otp,
        emailOtp: twoFactorEnabled ? _emailOtp : null,
      );
      _changeEmailToken = result.changeEmailToken;
      return true;
    } on AppException {
      _hasError = true;
      _emailHasError = twoFactorEnabled;
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

/// OTP provider for change-email step3/step4 (verify new email).
class ChangeEmailNewEmailOtpProvider extends ChangeNotifier {
  ChangeEmailNewEmailOtpProvider({
    required this.changeEmailToken,
    required this.newEmail,
    int? initialOtpExpirySeconds,
  }) : _pendingInitialExpiry = initialOtpExpirySeconds;

  static const int otpLength = 6;

  String changeEmailToken;
  final String newEmail;

  int? _pendingInitialExpiry;

  String _otp = '';
  int _countdownSeconds = 0;
  Timer? _timer;
  bool _isRequestingOtp = false;
  bool _isVerifying = false;
  bool _hasError = false;

  String get otp => _otp;
  int get countdownSeconds => _countdownSeconds;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;
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

  void _startCountdown(int seconds) {
    final safe = seconds <= 0 ? 60 : seconds;
    _timer?.cancel();
    _countdownSeconds = safe;
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  /// Calls step3-request to send OTP to the new email address.
  Future<void> requestOtp() async {
    if (_isRequestingOtp) return;
    _isRequestingOtp = true;
    notifyListeners();
    try {
      if (_pendingInitialExpiry != null) {
        final seconds = _pendingInitialExpiry!;
        _pendingInitialExpiry = null;
        _startCountdown(seconds);
        return;
      }
      final result = await ChangeEmailService.step3Request(
        changeEmailToken: changeEmailToken,
        newEmail: newEmail,
      );
      changeEmailToken = result.changeEmailToken;
      _startCountdown(result.otpExpirySeconds);
    } finally {
      _isRequestingOtp = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    if (!canResend) return;
    await requestOtp();
  }

  /// Calls step4-verify. Returns true on success and updates [changeEmailToken].
  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    notifyListeners();
    try {
      final result = await ChangeEmailService.step4Verify(
        changeEmailToken: changeEmailToken,
        otp: _otp,
      );
      changeEmailToken = result.changeEmailToken;
      return true;
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
