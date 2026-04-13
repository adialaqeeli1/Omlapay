import '../../../core/constants/endpoints.dart';
import '../../../core/l10n/app_localizations_from_storage.dart';
import '../../../core/models/change_phone/change_phone_models.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/app_exception.dart';

/// Authenticated APIs for the 4-step change-phone flow.
class ChangePhoneService {
  /// Step 1: Send OTP to the user's current registered phone number.
  static Future<ChangePhoneRequestData> step1Request() async {
    final response = await ApiHelper.post(
      Endpoints.changePhoneStep1Request,
      {},
    );
    return _parseData(response, ChangePhoneRequestData.fromJson);
  }

  /// Step 2: Verify current phone OTP. Returns a [change_phone_token].
  /// When 2FA is enabled, [emailOtp] must also be provided.
  static Future<ChangePhoneStep2Data> step2Verify({
    required String otp,
    String? emailOtp,
  }) async {
    final body = <String, dynamic>{'otp': otp.trim()};
    if (emailOtp != null && emailOtp.trim().isNotEmpty) {
      body['email_otp'] = emailOtp.trim();
    }
    final response = await ApiHelper.post(
      Endpoints.changePhoneStep2Verify,
      body,
    );
    return _parseData(response, ChangePhoneStep2Data.fromJson);
  }

  /// Step 3: Submit the new phone number. Sends OTP to the new number.
  static Future<ChangePhoneRequestData> step3Request({
    required String changePhoneToken,
    required String countryCode,
    required String newMobileNumber,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.changePhoneStep3Request,
      {
        'change_phone_token': changePhoneToken,
        'country_code': countryCode.trim(),
        'new_mobile_number': newMobileNumber.trim(),
      },
    );
    return _parseData(response, ChangePhoneRequestData.fromJson);
  }

  /// Step 4: Verify OTP sent to the new phone number.
  static Future<ChangePhoneVerifyData> step4Verify({
    required String changePhoneToken,
    required String otp,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.changePhoneStep4Verify,
      {
        'change_phone_token': changePhoneToken,
        'otp': otp.trim(),
      },
    );
    return _parseData(response, ChangePhoneVerifyData.fromJson);
  }

  static T _parseData<T>(
    Map<String, dynamic> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = response['data'];
    final invalidMsg =
        appLocalizationsFromStoredLocale().invalidServerResponse;
    if (data is! Map<String, dynamic>) {
      throw AppException(invalidMsg, messageKey: 'requestFailed');
    }
    try {
      return fromJson(data);
    } catch (_) {
      throw AppException(invalidMsg, messageKey: 'requestFailed');
    }
  }
}
