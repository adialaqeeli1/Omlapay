import '../../../core/constants/endpoints.dart';
import '../../../core/l10n/app_localizations_from_storage.dart';
import '../../../core/models/change_email/change_email_models.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/app_exception.dart';

/// Authenticated APIs for the 5-step change-email flow.
class ChangeEmailService {
  /// Step 1: Send OTP to the user's current registered phone number.
  static Future<ChangeEmailStep1Data> step1Request() async {
    final response = await ApiHelper.post(
      Endpoints.changeEmailStep1Request,
      {},
    );
    return _parseData(response, ChangeEmailStep1Data.fromJson);
  }

  /// Step 2: Verify current phone OTP. Returns a [change_email_token].
  static Future<ChangeEmailStep2Data> step2Verify({
    required String otp,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.changeEmailStep2Verify,
      {'otp': otp.trim()},
    );
    return _parseData(response, ChangeEmailStep2Data.fromJson);
  }

  /// Step 3: Submit the new email. Sends OTP to the new email address.
  static Future<ChangeEmailStep3Data> step3Request({
    required String changeEmailToken,
    required String newEmail,
  }) async {
    final response = await ApiHelper.post(Endpoints.changeEmailStep3Request, {
      'change_email_token': changeEmailToken,
      'new_email': newEmail.trim(),
    });
    return _parseData(response, ChangeEmailStep3Data.fromJson);
  }

  /// Step 4: Verify OTP sent to the new email address.
  static Future<ChangeEmailStep4Data> step4Verify({
    required String changeEmailToken,
    required String otp,
  }) async {
    final response = await ApiHelper.post(Endpoints.changeEmailStep4Verify, {
      'change_email_token': changeEmailToken,
      'otp': otp.trim(),
    });
    return _parseData(response, ChangeEmailStep4Data.fromJson);
  }

  /// Step 5: Confirm email change with passcode.
  static Future<ChangeEmailStep5Data> step5Confirm({
    required String changeEmailToken,
    required String passcode,
  }) async {
    final response = await ApiHelper.post(Endpoints.changeEmailStep5Confirm, {
      'change_email_token': changeEmailToken,
      'passcode': passcode,
    });
    return _parseData(response, ChangeEmailStep5Data.fromJson);
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
