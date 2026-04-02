import '../../../core/constants/endpoints.dart';
import '../../../core/l10n/app_localizations_from_storage.dart';
import '../../../core/models/change_phone/change_phone_models.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/app_exception.dart';

/// Authenticated APIs for changing the user's phone number.
class ChangePhoneService {
  static Future<ChangePhoneRequestData> requestChange({
    required String countryCode,
    required String newMobileNumber,
  }) async {
    final response = await ApiHelper.post(Endpoints.changePhoneRequest, {
      'country_code': countryCode.trim(),
      'new_mobile_number': newMobileNumber.trim(),
    });
    final data = response['data'];
    final invalidMsg =
        appLocalizationsFromStoredLocale().invalidServerResponse;
    if (data is! Map<String, dynamic>) {
      throw AppException(
        invalidMsg,
        messageKey: 'requestFailed',
      );
    }
    try {
      return ChangePhoneRequestData.fromJson(data);
    } catch (_) {
      throw AppException(
        invalidMsg,
        messageKey: 'requestFailed',
      );
    }
  }

  static Future<ChangePhoneVerifyData> verifyChange({
    required String countryCode,
    required String newMobileNumber,
    required String otp,
  }) async {
    final response = await ApiHelper.post(Endpoints.changePhoneVerify, {
      'country_code': countryCode.trim(),
      'new_mobile_number': newMobileNumber.trim(),
      'otp': otp.trim(),
    });
    final data = response['data'];
    final invalidMsg =
        appLocalizationsFromStoredLocale().invalidServerResponse;
    if (data is! Map<String, dynamic>) {
      throw AppException(
        invalidMsg,
        messageKey: 'requestFailed',
      );
    }
    try {
      return ChangePhoneVerifyData.fromJson(data);
    } catch (_) {
      throw AppException(
        invalidMsg,
        messageKey: 'requestFailed',
      );
    }
  }
}
