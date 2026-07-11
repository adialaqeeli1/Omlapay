import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../services/change_email_service.dart';

/// OTP provider for change-email step 1 / step 2 — verifies the user via the
/// OTP sent to their registered phone number.
class ChangeEmailPhoneOtpProvider extends ChangeNotifier {
  ChangeEmailPhoneOtpProvider();

  static const int otpLength = 6;

  String _otp = '';
  String _maskedPhone = '';
  bool _hasError = false;

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

  /// Calls step1-request to send an OTP to the user's current phone.
  Future<void> requestOtp() async {
    if (_isRequestingOtp) return;
    _isRequestingOtp = true;
    notifyListeners();
    try {
      final result = await ChangeEmailService.step1Request();
      _maskedPhone = result.maskedPhone ?? '';
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

  /// Calls step2-verify-phone with the phone OTP.
  /// Returns true on success and stores [changeEmailToken].
  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    notifyListeners();
    try {
      final result = await ChangeEmailService.step2VerifyPhone(otp: _otp);
      _changeEmailToken = result.changeEmailToken;
      return true;
    } on AppException {
      _hasError = true;
      _otp = '';
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

/// OTP provider for change-email step4/step5 (verify the new email).
class ChangeEmailNewEmailOtpProvider extends ChangeNotifier {
  ChangeEmailNewEmailOtpProvider({
    required this.changeEmailToken,
    required this.newEmail,
    int? initialOtpExpirySeconds,
  }) : _pendingInitialExpiry = initialOtpExpirySeconds;

  static const int otpLength = 6;

  /// Token used by step 5. Refreshed when the user resends an OTP via step 4.
  String changeEmailToken;
  final String newEmail;

  int? _pendingInitialExpiry;

  String _otp = '';
  int _countdownSeconds = 0;
  Timer? _timer;
  bool _isRequestingOtp = false;
  bool _isVerifying = false;
  bool _hasError = false;
  String? _verifiedEmail;

  String get otp => _otp;
  int get countdownSeconds => _countdownSeconds;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;
  bool get hasError => _hasError;
  bool get isComplete => _otp.length == otpLength;
  String? get verifiedEmail => _verifiedEmail;

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

  /// Calls step4-request-new-email to send an OTP to the new email and
  /// refresh the change-email token.
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
      final result = await ChangeEmailService.step4RequestNewEmail(
        changeEmailToken: changeEmailToken,
        newEmail: newEmail,
      );
      final refreshedToken = result.changeEmailToken;
      if (refreshedToken != null && refreshedToken.isNotEmpty) {
        changeEmailToken = refreshedToken;
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

  /// Calls step5-verify-new-email. Returns true on success and stores the
  /// confirmed email (when the API returns one) for downstream use.
  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    notifyListeners();
    try {
      final result = await ChangeEmailService.step5VerifyNewEmail(
        changeEmailToken: changeEmailToken,
        otp: _otp,
      );
      _verifiedEmail = result.email;
      return true;
    } on AppException {
      _hasError = true;
      _otp = '';
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
