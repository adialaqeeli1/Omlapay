import '../../../core/constants/endpoints.dart';
import '../../../core/l10n/app_localizations_from_storage.dart';
import '../../../core/models/change_email/change_email_models.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/app_exception.dart';

/// Authenticated APIs for the 5-step change-email flow.
class ChangeEmailService {
  /// Step 1: Send OTPs to the user's current phone and email.
  static Future<ChangeEmailStep1Data> step1Request() async {
    final response = await ApiHelper.post(
      Endpoints.changeEmailStep1Request,
      {},
    );
    return _parseData(response, ChangeEmailStep1Data.fromJson);
  }

  /// Step 2: Verify the phone OTP. Returns a [change_email_token].
  /// The API contract still includes an `email_otp` field; we mirror the same
  /// value so the request validates while the user only sees a single field.
  static Future<ChangeEmailTokenData> step2VerifyPhone({
    required String otp,
  }) async {
    final trimmed = otp.trim();
    final response = await ApiHelper.post(
      Endpoints.changeEmailStep2VerifyPhone,
      {
        'otp': trimmed,
        'email_otp': trimmed,
      },
    );
    return _parseData(response, ChangeEmailTokenData.fromJson);
  }

  /// Step 3: Verify the user's account passcode. Returns a fresh
  /// [change_email_token] used by step 4.
  static Future<ChangeEmailTokenData> step3VerifyPasscode({
    required String changeEmailToken,
    required String passcode,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.changeEmailStep3VerifyPasscode,
      {
        'change_email_token': changeEmailToken,
        'passcode': passcode,
      },
    );
    return _parseData(response, ChangeEmailTokenData.fromJson);
  }

  /// Step 4: Submit the new email address. Sends an OTP to the new email and
  /// returns a fresh [change_email_token] used by step 5.
  static Future<ChangeEmailRequestNewEmailData> step4RequestNewEmail({
    required String changeEmailToken,
    required String newEmail,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.changeEmailStep4RequestNewEmail,
      {
        'change_email_token': changeEmailToken,
        'new_email': newEmail.trim(),
      },
    );
    return _parseData(response, ChangeEmailRequestNewEmailData.fromJson);
  }

  /// Step 5: Verify the OTP sent to the new email. Completes the email change.
  static Future<ChangeEmailVerifyNewEmailData> step5VerifyNewEmail({
    required String changeEmailToken,
    required String otp,
  }) async {
    final response = await ApiHelper.post(
      Endpoints.changeEmailStep5VerifyNewEmail,
      {
        'change_email_token': changeEmailToken,
        'otp': otp.trim(),
      },
    );
    return _parseData(response, ChangeEmailVerifyNewEmailData.fromJson);
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
