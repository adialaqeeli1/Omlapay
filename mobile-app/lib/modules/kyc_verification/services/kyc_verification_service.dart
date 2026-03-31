import '../../../core/constants/endpoints.dart';
import '../../../core/services/api_helper.dart';

class KycVerificationService {
  KycVerificationService._();

  static Future<Map<String, dynamic>> startKyc({
    required String firstName,
    required String lastName,
    required String residentialCountry,
    required String dob,
    required String country,
    required String city,
    required String address,
  }) async {
    return ApiHelper.post(Endpoints.kycStart, {
      'firstName': firstName,
      'lastName': lastName,
      'residentialCountry': residentialCountry,
      'dob': dob,
      'country': country,
      'city': city,
      'address': address,
    });
  }
}
