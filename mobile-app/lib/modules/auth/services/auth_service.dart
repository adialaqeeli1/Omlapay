import '../../../core/services/api_helper.dart';
import '../../../core/constants/endpoints.dart';

class AuthService {
  static Future<Map<String, dynamic>> registerRequest({
    required String countryCode,
    required String mobileNumber,
    required bool termsAccepted,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.registerRequest,
      {
        "country_code": countryCode,
        "mobile_number": mobileNumber,
        "terms_accepted": termsAccepted,
      },
    );
    return response;
  }

  static Future<Map<String, dynamic>> resendRegistrationOtp({
    required String countryCode,
    required String mobileNumber,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.registerResendOtp,
      {
        "country_code": countryCode,
        "mobile_number": mobileNumber,
      },
    );
    return response;
  }

  static Future<Map<String, dynamic>> verifyRegistrationOtp({
    required String countryCode,
    required String mobileNumber,
    required String otp,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.registerVerifyOtp,
      {
        "country_code": countryCode,
        "mobile_number": mobileNumber,
        "otp": otp,
      },
    );
    return response;
  }

  static Future<Map<String, dynamic>> setRegistrationPasscode({
    required String registrationToken,
    required String passcode,
    required String confirmPasscode,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.registerSetPasscode,
      {
        "registration_token": registrationToken,
        "passcode": passcode,
        "confirm_passcode": confirmPasscode,
      },
    );
    return response;
  }

  static Future<Map<String, dynamic>> changePasscode({
    required String currentPasscode,
    required String newPasscode,
    required String confirmPasscode,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.changePasscode,
      {
        "current_passcode": currentPasscode,
        "new_passcode": newPasscode,
        "confirm_passcode": confirmPasscode,
      },
    );
    return response;
  }

  /// Final step of the OTP-based hard-login. The token is what
  /// `loginVerifyOtp` returned in `data.otpVerificationToken`.
  /// Backend: POST /v1/auth/login.
  static Future<Map<String, dynamic>> login({
    required String passcode,
    required String otpVerificationToken,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.login,
      {
        "passcode": passcode,
        "otpVerificationToken": otpVerificationToken,
      },
    );
    return response;
  }

  /// Step 1 of the OTP-based hard-login: trigger an SMS OTP for the given phone.
  /// Backend: POST /v1/auth/login/send-otp.
  static Future<Map<String, dynamic>> loginSendOtp({
    required String countryCode,
    required String mobileNumber,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.loginSendOtp,
      {
        "country_code": countryCode,
        "mobile_number": mobileNumber,
      },
    );
    return response;
  }

  /// Step 1 (resend) of the OTP-based hard-login: re-trigger the SMS OTP.
  /// Backend: POST /v1/auth/login/resend-otp.
  static Future<Map<String, dynamic>> loginResendOtp({
    required String countryCode,
    required String mobileNumber,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.loginResendOtp,
      {
        "country_code": countryCode,
        "mobile_number": mobileNumber,
      },
    );
    return response;
  }

  /// Step 2 of the OTP-based hard-login: verify the OTP. On success the
  /// response carries `data.otpVerificationToken` which is consumed by the
  /// final `login` call (in a later task).
  /// Backend: POST /v1/auth/login/verify-otp.
  static Future<Map<String, dynamic>> loginVerifyOtp({
    required String countryCode,
    required String mobileNumber,
    required String otp,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.loginVerifyOtp,
      {
        "country_code": countryCode,
        "mobile_number": mobileNumber,
        "otp": otp,
      },
    );
    return response;
  }

  /// Silent re-login with phone + passcode (no OTP). Backend returns the same
  /// shape as the OTP-based `login` (access_token, refresh_token, user).
  /// Backend: POST /v1/auth/login/passcode.
  static Future<Map<String, dynamic>> loginPasscode({
    required String countryCode,
    required String mobileNumber,
    required String passcode,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.loginPasscode,
      {
        "country_code": countryCode,
        "mobile_number": mobileNumber,
        "passcode": passcode,
      },
    );
    return response;
  }

  static Future<Map<String, dynamic>> softLogin({
    required String passcode,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.softLogin,
      {
        "passcode": passcode,
      },
    );
    return response;
  }

  static Future<Map<String, dynamic>> checkUser({
    required String countryCode,
    required String mobileNumber,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.checkUser,
      {
        "country_code": countryCode,
        "mobile_number": mobileNumber,
      },
    );
    return response;
  }

  static Future<Map<String, dynamic>> inviteUser({
    required String countryCode,
    required String mobileNumber,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.inviteUser,
      {
        "country_code": countryCode,
        "mobile_number": mobileNumber,
      },
    );
    return response;
  }

  static Future<Map<String, dynamic>> sessionStatus() async {
    final response = await ApiHelper.get(Endpoints.sessionStatus);
    return response;
  }

  /// Revokes the current session and unregisters the FCM device token from
  /// the backend. [deviceToken] should be the current FCM token; an empty
  /// string is sent if it is not available.
  static Future<Map<String, dynamic>> logout({String? deviceToken}) async {
    final response = await ApiHelper.post(
      Endpoints.authLogout,
      {'device_token': deviceToken ?? ''},
    );
    return response;
  }

  static Future<Map<String, dynamic>> fetchAccountDetails() async {
    return ApiHelper.get(Endpoints.accountDetails);
  }

  static Future<Map<String, dynamic>> enableTwoFactor() async {
    return ApiHelper.post(Endpoints.twoFactorEnable, {});
  }

  static Future<Map<String, dynamic>> disableTwoFactor() async {
    return ApiHelper.post(Endpoints.twoFactorDisable, {});
  }

  static Future<Map<String, dynamic>> requestAccountDeletion() async {
    return ApiHelper.post(Endpoints.requestAccountDeletion, {});
  }
}
