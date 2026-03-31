import '../../../core/constants/endpoints.dart';
import '../../../core/l10n/app_localizations_from_storage.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/app_exception.dart';

/// Authenticated APIs for changing the user's email.
class ChangeEmailService {
  static const int _defaultOtpExpirySeconds = 60;

  /// Returns OTP countdown seconds from [data] when present.
  static Future<int> requestChange({required String newEmail}) async {
    final response = await ApiHelper.post(Endpoints.changeEmailRequest, {
      'new_email': newEmail.trim(),
    });
    final data = response['data'];
    final invalidMsg =
        appLocalizationsFromStoredLocale().invalidServerResponse;
    if (data is! Map<String, dynamic>) {
      throw AppException(invalidMsg, messageKey: 'requestFailed');
    }
    final rawExpiry = data['otp_expiry_seconds'];
    final expiry = rawExpiry is int
        ? rawExpiry
        : int.tryParse(rawExpiry?.toString() ?? '') ?? _defaultOtpExpirySeconds;
    return expiry > 0 ? expiry : _defaultOtpExpirySeconds;
  }

  static Future<void> verifyChange({
    required String newEmail,
    required String otp,
  }) async {
    await ApiHelper.post(Endpoints.changeEmailVerify, {
      'new_email': newEmail.trim(),
      'otp': otp.trim(),
    });
  }
}
