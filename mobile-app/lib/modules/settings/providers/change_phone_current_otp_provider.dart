import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../services/change_phone_service.dart';

/// OTP provider for step 1 (request) and step 2 (verify) of the change-phone
/// flow — verifying the user via an OTP sent to their registered email.
class ChangePhoneCurrentOtpProvider extends ChangeNotifier {
  ChangePhoneCurrentOtpProvider({
    required this.maskedEmail,
    int? initialOtpExpirySeconds,
  }) : _pendingInitialExpiry = initialOtpExpirySeconds;

  static const int otpLength = 6;

  final String maskedEmail;

  int? _pendingInitialExpiry;

  String _otp = '';
  bool _hasError = false;
  String? _verifyErrorKey;

  int _countdownSeconds = 0;
  Timer? _timer;
  bool _isRequestingOtp = false;
  bool _isVerifying = false;
  String? _changePhoneToken;
  String? _resolvedMaskedEmail;

  String get otp => _otp;
  int get countdownSeconds => _countdownSeconds;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;
  bool get hasError => _hasError;
  String? get verifyErrorKey => _verifyErrorKey;
  String? get changePhoneToken => _changePhoneToken;

  /// Latest masked email returned by the API, falling back to the value
  /// passed in via constructor.
  String get displayMaskedEmail => _resolvedMaskedEmail ?? maskedEmail;

  bool get isComplete => _otp.length == otpLength;

  void setOtp(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final truncated =
        digits.length > otpLength ? digits.substring(0, otpLength) : digits;
    if (_otp == truncated) return;
    _otp = truncated;
    _hasError = false;
    _verifyErrorKey = null;
    notifyListeners();
  }

  void _startCountdown(int seconds) {
    final safe = seconds <= 0 ? 60 : seconds;
    _timer?.cancel();
    _countdownSeconds = safe;
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

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
      final result = await ChangePhoneService.step1Request();
      if (result.maskedEmail != null && result.maskedEmail!.isNotEmpty) {
        _resolvedMaskedEmail = result.maskedEmail;
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

  /// Verifies the email OTP. On success stores the [changePhoneToken] needed
  /// for subsequent steps.
  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    _verifyErrorKey = null;
    notifyListeners();
    try {
      final result = await ChangePhoneService.step2VerifyEmail(emailOtp: _otp);
      _changePhoneToken = result.changePhoneToken;
      return true;
    } on AppException catch (e) {
      _hasError = true;
      _verifyErrorKey = e.messageKey ?? 'requestFailed';
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
