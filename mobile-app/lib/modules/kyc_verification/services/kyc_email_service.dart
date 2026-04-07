import '../../../core/utils/app_exception.dart';

class KycEmailService {
  KycEmailService._();

  static const String _validOtp = '123456';

  static Future<void> sendOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: always succeeds
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (otp == _validOtp) {
      return true;
    }
    throw AppException('Invalid OTP code');
  }
}
