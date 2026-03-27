import '../constants/endpoints.dart';
import '../utils/app_exception.dart';
import 'api_helper.dart';

/// Fetches legal document content from the public API.
class LegalService {
  LegalService._();

  /// Supported API language codes for legal endpoints.
  static const Set<String> _supportedLanguages = {'en', 'ar'};

  /// Returns markdown content for the privacy policy for [language] (e.g. `en`, `ar`).
  static Future<String> fetchPrivacyPolicy({required String language}) async {
    final code = _normalizeLanguage(language);
    final response = await ApiHelper.get(
      Endpoints.legalPrivacy,
      queryParameters: <String, dynamic>{'language': code},
    );

    final status = response['status'];
    if (status != 'success') {
      throw AppException(
        'Unexpected response from server',
        messageKey: 'requestFailed',
      );
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException(
        'Invalid privacy policy response',
        messageKey: 'requestFailed',
      );
    }

    final content = data['content'];
    if (content is! String || content.trim().isEmpty) {
      throw AppException(
        'Privacy policy content is empty',
        messageKey: 'requestFailed',
      );
    }

    return content;
  }

  /// Returns markdown content for the terms of service for [language] (e.g. `en`, `ar`).
  static Future<String> fetchTermsOfService({required String language}) async {
    final code = _normalizeLanguage(language);
    final response = await ApiHelper.get(
      Endpoints.legalTerms,
      queryParameters: <String, dynamic>{'language': code},
    );

    final status = response['status'];
    if (status != 'success') {
      throw AppException(
        'Unexpected response from server',
        messageKey: 'requestFailed',
      );
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException(
        'Invalid terms of service response',
        messageKey: 'requestFailed',
      );
    }

    final content = data['content'];
    if (content is! String || content.trim().isEmpty) {
      throw AppException(
        'Terms of service content is empty',
        messageKey: 'requestFailed',
      );
    }

    return content;
  }

  static String _normalizeLanguage(String language) {
    final lower = language.trim().toLowerCase();
    final short = lower.split(RegExp('[-_]')).first;
    if (_supportedLanguages.contains(short)) {
      return short;
    }
    return 'en';
  }
}
