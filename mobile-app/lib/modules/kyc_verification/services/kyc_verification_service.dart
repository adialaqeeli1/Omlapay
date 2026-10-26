import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/endpoints.dart';
import '../../../core/services/api_helper.dart';
import '../models/kyc_rejection_details_response.dart';
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

  static Future<KycRejectionDetailsResponse> fetchRejectionDetails() async {
    final response = await ApiHelper.get(Endpoints.kycRejectionDetails);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return KycRejectionDetailsResponse.fromJson(data);
    }
    return const KycRejectionDetailsResponse();
  }

  /// Resubmits KYC after a rejection as `multipart/form-data`. Text fields are
  /// always sent. Image files (`idFront`, `idBack`, `selfie`) are only
  /// attached when the caller supplies a non-null `XFile` — the backend treats
  /// omitted image parts as "keep the previously uploaded image".
  static Future<Map<String, dynamic>> resubmitKyc({
    required String firstName,
    required String lastName,
    required String dob,
    required String residentialCountry,
    required String documentCountry,
    required String city,
    required String address,
    XFile? idFront,
    XFile? idBack,
    XFile? selfie,
  }) async {
    final data = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob,
      'residentialCountry': residentialCountry,
      'country': documentCountry,
      'city': city,
      'address': address,
      if (idFront != null)
        'idFront': await MultipartFile.fromFile(
          idFront.path,
          filename: p.basename(idFront.path),
        ),
      if (idBack != null)
        'idBack': await MultipartFile.fromFile(
          idBack.path,
          filename: p.basename(idBack.path),
        ),
      if (selfie != null)
        'selfie': await MultipartFile.fromFile(
          selfie.path,
          filename: p.basename(selfie.path),
        ),
    };
    return ApiHelper.multipartPost(Endpoints.kycResubmit, data: data);
  }
}
