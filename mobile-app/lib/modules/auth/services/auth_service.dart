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

}
