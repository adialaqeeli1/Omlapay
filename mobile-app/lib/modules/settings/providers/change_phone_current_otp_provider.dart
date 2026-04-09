import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../services/change_phone_service.dart';

/// OTP provider for step 1 (request) and step 2 (verify) of the change-phone
/// flow — verifying the user's current registered phone number.
class ChangePhoneCurrentOtpProvider extends ChangeNotifier {
  ChangePhoneCurrentOtpProvider({
    required this.maskedMobile,
    int? initialOtpExpirySeconds,
  }) : _pendingInitialExpiry = initialOtpExpirySeconds;

  static const int otpLength = 6;

  final String maskedMobile;

  int? _pendingInitialExpiry;

  String _otp = '';
  int _countdownSeconds = 0;
  Timer? _timer;
  bool _isRequestingOtp = false;
  bool _isVerifying = false;
  bool _hasError = false;
  String? _verifyErrorKey;
  String? _changePhoneToken;

  String get otp => _otp;
  int get countdownSeconds => _countdownSeconds;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;
  bool get hasError => _hasError;
  String? get verifyErrorKey => _verifyErrorKey;
  bool get isComplete => _otp.length == otpLength;
  String? get changePhoneToken => _changePhoneToken;

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

  /// Verifies the OTP for the current phone. On success stores the
  /// [changePhoneToken] needed for subsequent steps.
  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    _verifyErrorKey = null;
    notifyListeners();
    try {
      final result = await ChangePhoneService.step2Verify(otp: _otp);
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
