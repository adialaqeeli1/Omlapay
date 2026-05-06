import '../../../core/constants/endpoints.dart';
import '../../../core/l10n/app_localizations_from_storage.dart';
import '../../../core/models/change_phone/change_phone_models.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/app_exception.dart';

/// Authenticated APIs for the 5-step change-phone flow.
class ChangePhoneService {
  /// Step 1: Send OTP to the user's registered email address.
  static Future<ChangePhoneRequestData> step1Request() async {
    final response = await ApiHelper.post(
      Endpoints.changePhoneStep1Request,
      {},
    );
    return _parseData(response, ChangePhoneRequestData.fromJson);
  }

  /// Step 2: Verify the email OTP. Returns a [change_phone_token].
  static Future<ChangePhoneStep2Data> step2VerifyEmail({
    required String emailOtp,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.changePhoneStep2VerifyEmail,
      {'email_otp': emailOtp.trim()},
    );
    return _parseData(response, ChangePhoneStep2Data.fromJson);
  }

  /// Step 3: Verify the user's account passcode. Returns a fresh
  /// [change_phone_token] used by step 4.
  static Future<ChangePhoneStep2Data> step3VerifyPasscode({
    required String changePhoneToken,
    required String passcode,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.changePhoneStep3VerifyPasscode,
      {'change_phone_token': changePhoneToken, 'passcode': passcode},
    );
    return _parseData(response, ChangePhoneStep2Data.fromJson);
  }

  /// Step 4: Submit the new phone number. Sends an OTP to the new number and
  /// returns a fresh [change_phone_token] used by step 5.
  static Future<ChangePhoneRequestData> step4RequestNewPhone({
    required String changePhoneToken,
    required String countryCode,
    required String newMobileNumber,
  }) async {
    final response =
        await ApiHelper.post(Endpoints.changePhoneStep4RequestNewPhone, {
          'change_phone_token': changePhoneToken,
          'country_code': countryCode.trim(),
          'new_mobile_number': newMobileNumber.trim(),
        });
    return _parseData(response, ChangePhoneRequestData.fromJson);
  }

  /// Step 5: Verify the OTP sent to the new phone number.
  static Future<ChangePhoneVerifyData> step5VerifyNewPhone({
    required String changePhoneToken,
    required String otp,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.changePhoneStep5VerifyNewPhone,
      {'change_phone_token': changePhoneToken, 'otp': otp.trim()},
    );
    return _parseData(response, ChangePhoneVerifyData.fromJson);
  }

  static T _parseData<T>(
    Map<String, dynamic> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = response['data'];
    final invalidMsg = appLocalizationsFromStoredLocale().invalidServerResponse;
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
