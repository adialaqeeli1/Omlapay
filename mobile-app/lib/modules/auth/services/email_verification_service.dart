import '../../../core/constants/endpoints.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/app_exception.dart';

class EmailVerificationService {
  EmailVerificationService._();

  /// Sends an OTP to the given [email] address.
  static Future<void> sendOtp(String email) async {
    await ApiHelper.post(Endpoints.emailRequest, {'email': email});
  }

  /// Verifies the [otp] for the previously requested email.
  /// Returns `true` on success. Throws [AppException] on failure.
  static Future<bool> verifyOtp(String otp) async {
    await ApiHelper.post(Endpoints.emailVerify, {'otp': otp});
    return true;
  }
}
