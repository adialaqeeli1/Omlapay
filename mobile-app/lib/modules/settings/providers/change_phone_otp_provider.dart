import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/app_exception.dart';
import '../services/change_phone_service.dart';

/// OTP step for [change-phone/step4-request-new-phone] +
/// [change-phone/step5-verify-new-phone] (new number).
class ChangePhoneOtpProvider extends ChangeNotifier {
  ChangePhoneOtpProvider({
    required this.changePhoneToken,
    required this.countryCode,
    required this.newMobileNumber,
    required this.maskedMobile,
    int? initialOtpExpirySeconds,
  }) : _pendingInitialExpiry = initialOtpExpirySeconds;

  static const int otpLength = 6;

  /// Token used by step 5. Refreshed when the user resends an OTP via step 4.
  String changePhoneToken;
  final String countryCode;
  final String newMobileNumber;
  final String maskedMobile;

  int? _pendingInitialExpiry;

  String _otp = '';
  int _countdownSeconds = 0;
  Timer? _timer;
  bool _isRequestingOtp = false;
  bool _isVerifying = false;
  bool _hasError = false;
  String? _verifyErrorKey;

  String get otp => _otp;
  int get countdownSeconds => _countdownSeconds;
  bool get canResend => _countdownSeconds <= 0 && !_isRequestingOtp;
  bool get hasError => _hasError;
  String? get verifyErrorKey => _verifyErrorKey;
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
      final result = await ChangePhoneService.step4RequestNewPhone(
        changePhoneToken: changePhoneToken,
        countryCode: countryCode,
        newMobileNumber: newMobileNumber,
      );
      final refreshedToken = result.changePhoneToken;
      if (refreshedToken != null && refreshedToken.isNotEmpty) {
        changePhoneToken = refreshedToken;
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

  Future<bool> verifyOtp() async {
    if (!isComplete || _isVerifying) return false;
    _isVerifying = true;
    _hasError = false;
    _verifyErrorKey = null;
    notifyListeners();
    try {
      await ChangePhoneService.step5VerifyNewPhone(
        changePhoneToken: changePhoneToken,
        otp: _otp,
      );
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
