import '../../../core/constants/endpoints.dart';
import '../../../core/services/api_helper.dart';
import '../models/kyc_status_response.dart';

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

  static Future<Map<String, dynamic>> startBinanceKyc() async {
    return ApiHelper.post(Endpoints.kycBinanceStart, {});
  }

  static Future<KycStatusResponse> fetchKycStatus() async {
    final response = await ApiHelper.get(Endpoints.kycStatus);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return KycStatusResponse.fromJson(data);
    }
    return const KycStatusResponse();
  }
}
