import 'dart:async';

/// Mock service for forgot passcode / send OTP API.
/// Simulates network delay; replace with real API when backend is ready.
class ForgotPasscodeService {
  ForgotPasscodeService._();

  static const Duration _mockDelay = Duration(milliseconds: 200);

  /// Requests OTP for the given phone number. Mock implementation.
  static Future<void> requestOtp(String phoneNumber, String countryCode) async {
    await Future<void>.delayed(_mockDelay);
    // Mock: no real API call; success is implicit
  }

  /// Verifies OTP. Mock implementation - accepts any 6-digit OTP.
  static Future<bool> verifyOtp(
    String phoneNumber,
    String countryCode,
    String otp,
  ) async {
    await Future<void>.delayed(_mockDelay);
    return otp.length == 6;
  }
}
