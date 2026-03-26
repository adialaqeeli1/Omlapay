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

  static Future<Map<String, dynamic>> login({
    required String countryCode,
    required String mobileNumber,
    required String passcode,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.login,
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
}
