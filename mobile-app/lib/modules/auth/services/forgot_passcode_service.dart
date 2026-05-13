import '../../../core/constants/endpoints.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/api_message_helper.dart';

class ForgotPasscodeOtpResponse {
  const ForgotPasscodeOtpResponse({
    required this.message,
    required this.otpExpirySeconds,
    this.maskedMobile,
    this.maskedEmail,
    this.verificationType,
  });

  final String message;
  final int otpExpirySeconds;
  final String? maskedMobile;
  final String? maskedEmail;

  /// Server-provided hint of which channels received the OTP. Known values
  /// observed from backend: `mobile` (phone-only) or `both` (phone + email
  /// when 2FA is enabled). The presence of [maskedEmail] is the source of
  /// truth — this field is informational.
  final String? verificationType;

  bool get requiresEmailOtp => (maskedEmail ?? '').trim().isNotEmpty;
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

  /// Resends the OTP for the forgot-passcode flow.
  ///
  /// [channel] selects which code(s) the backend should re-issue:
  /// - `mobile` — only the SMS/WhatsApp OTP
  /// - `email`  — only the email OTP (requires 2FA enabled)
  /// - `both`   — both (default; only meaningful when 2FA is enabled)
  static Future<ForgotPasscodeOtpResponse> resendOtp(
    String phoneNumber,
    String countryCode, {
    String channel = 'both',
  }) async {
    final response = await ApiHelper.post(Endpoints.forgotPasscodeResendOtp, {
      "country_code": countryCode,
      "mobile_number": phoneNumber,
      "channel": channel,
    });
    return _parseOtpResponse(response);
  }

  /// [requireResetToken] is true for the forgot-password reset flow (needs
  /// [reset_token] to call [resetPasscode]). For settings → change passcode,
  /// the same verify endpoint may return success without a token; use false.
  ///
  /// Pass [emailOtp] when 2FA is enabled (initial response returned a
  /// `masked_email`). The backend then validates both codes together.
  static Future<bool> verifyOtp(
    String phoneNumber,
    String countryCode,
    String otp, {
    bool requireResetToken = true,
    String? emailOtp,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.forgotPasscodeVerifyOtp,
      _buildVerifyBody(
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        mobileOtp: otp,
        emailOtp: emailOtp,
      ),
    );

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
    String otp, {
    String? emailOtp,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.forgotPasscodeVerifyOtp,
      _buildVerifyBody(
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        mobileOtp: otp,
        emailOtp: emailOtp,
      ),
    );
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

  static Map<String, dynamic> _buildVerifyBody({
    required String countryCode,
    required String phoneNumber,
    required String mobileOtp,
    String? emailOtp,
  }) {
    final body = <String, dynamic>{
      'country_code': countryCode,
      'mobile_number': phoneNumber,
      'mobile_otp': mobileOtp,
    };
    final trimmedEmailOtp = emailOtp?.trim() ?? '';
    if (trimmedEmailOtp.isNotEmpty) {
      body['email_otp'] = trimmedEmailOtp;
    }
    return body;
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
      maskedEmail: dataMap?['masked_email']?.toString(),
      verificationType: dataMap?['verification_type']?.toString(),
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
