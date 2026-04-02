import '../../../core/constants/endpoints.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/api_message_helper.dart';

class ForgotPasscodeOtpResponse {
  const ForgotPasscodeOtpResponse({
    required this.message,
    required this.otpExpirySeconds,
    this.maskedMobile,
  });

  final String message;
  final int otpExpirySeconds;
  final String? maskedMobile;
}

class ForgotPasscodeVerifyResponse {
  const ForgotPasscodeVerifyResponse({
    required this.message,
    required this.resetToken,
  });

  final String message;
  final String resetToken;
}

class ForgotPasscodeService {
  ForgotPasscodeService._();

  static const int defaultOtpExpirySeconds = 60;

  static Future<ForgotPasscodeOtpResponse> requestOtp(
    String phoneNumber,
    String countryCode,
  ) async {
    final response = await ApiHelper.post(Endpoints.forgotPasscode, {
      "country_code": countryCode,
      "mobile_number": phoneNumber,
    });
    return _parseOtpResponse(response);
  }

  static Future<ForgotPasscodeOtpResponse> resendOtp(
    String phoneNumber,
    String countryCode,
  ) async {
    final response = await ApiHelper.post(Endpoints.forgotPasscodeResendOtp, {
      "country_code": countryCode,
      "mobile_number": phoneNumber,
    });
    return _parseOtpResponse(response);
  }

  /// [requireResetToken] is true for the forgot-password reset flow (needs
  /// [reset_token] to call [resetPasscode]). For settings → change passcode,
  /// the same verify endpoint may return success without a token; use false.
  static Future<bool> verifyOtp(
    String phoneNumber,
    String countryCode,
    String otp, {
    bool requireResetToken = true,
  }) async {
    final response = await ApiHelper.post(Endpoints.forgotPasscodeVerifyOtp, {
      "country_code": countryCode,
      "mobile_number": phoneNumber,
      "mobile_otp": otp,
    });

    final data = response['data'];
    final dataMap = data is Map<String, dynamic> ? data : null;
    final resetToken = dataMap?['reset_token']?.toString() ?? '';
    final status = dataMap?['status']?.toString() ?? '';
    if (!requireResetToken) {
      return status == 'success';
    }
    return status == 'success' && resetToken.isNotEmpty;
  }

  static Future<ForgotPasscodeVerifyResponse> verifyOtpAndGetResetToken(
    String phoneNumber,
    String countryCode,
    String otp,
  ) async {
    final response = await ApiHelper.post(Endpoints.forgotPasscodeVerifyOtp, {
      "country_code": countryCode,
      "mobile_number": phoneNumber,
      "mobile_otp": otp,
    });
    final data = response['data'];
    final dataMap = data is Map<String, dynamic> ? data : null;
    final resetToken = dataMap?['reset_token']?.toString() ?? '';
    final status = dataMap?['status']?.toString() ?? '';
    if (status != 'success' || resetToken.isEmpty) {
      throw Exception(
        _extractLocalizedMessage(
          response,
          fallback: 'OTP verification failed',
        ),
      );
    }
    return ForgotPasscodeVerifyResponse(
      message: _extractLocalizedMessage(
        response,
        fallback: 'OTP verification successful.',
      ),
      resetToken: resetToken,
    );
  }

  static Future<void> resetPasscode({
    required String resetToken,
    required String newPasscode,
    required String confirmPasscode,
  }) async {
    await ApiHelper.post(Endpoints.forgotPasscodeReset, {
      "reset_token": resetToken,
      "new_passcode": newPasscode,
      "confirm_passcode": confirmPasscode,
    });
  }

  static ForgotPasscodeOtpResponse _parseOtpResponse(
    Map<String, dynamic> response,
  ) {
    final data = response['data'];
    final dataMap = data is Map<String, dynamic> ? data : null;
    final rawExpiry = dataMap?['otp_expiry_seconds'];
    final otpExpirySeconds = rawExpiry is int
        ? rawExpiry
        : int.tryParse(rawExpiry?.toString() ?? '') ?? defaultOtpExpirySeconds;

    return ForgotPasscodeOtpResponse(
      message: _extractLocalizedMessage(
        response,
        fallback: '',
      ),
      otpExpirySeconds: otpExpirySeconds > 0
          ? otpExpirySeconds
          : defaultOtpExpirySeconds,
      maskedMobile: dataMap?['masked_mobile']?.toString(),
    );
  }

  static String _extractLocalizedMessage(
    Map<String, dynamic> response, {
    required String fallback,
  }) {
    final data = response['data'];
    final dataMap = data is Map<String, dynamic> ? data : null;

    if (dataMap != null) {
      final nestedMessage = ApiMessageHelper.localizedFromResponse(
        dataMap,
        fallback: '',
      );
      if (nestedMessage.trim().isNotEmpty) {
        return nestedMessage;
      }
    }

    return ApiMessageHelper.localizedFromResponse(response, fallback: fallback);
  }
}
