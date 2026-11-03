import '../constants/endpoints.dart';
import '../utils/app_exception.dart';
import 'api_helper.dart';

/// Fetches legal document content from the public API.
class LegalService {
  LegalService._();

  /// Supported API language codes for legal endpoints.
  static const Set<String> _supportedLanguages = {'en', 'ar'};

  /// Returns markdown content for the privacy policy for [language] (e.g. `en`, `ar`).
  static Future<String> fetchPrivacyPolicy({required String language}) {
    return _fetchLegalContent(
      endpoint: Endpoints.legalPrivacy,
      language: language,
      emptyErrorMessage: 'Privacy policy content is empty',
      invalidErrorMessage: 'Invalid privacy policy response',
    );
  }

  /// Returns markdown content for the terms of service for [language] (e.g. `en`, `ar`).
  static Future<String> fetchTermsOfService({required String language}) {
    return _fetchLegalContent(
      endpoint: Endpoints.legalTerms,
      language: language,
      emptyErrorMessage: 'Terms of service content is empty',
      invalidErrorMessage: 'Invalid terms of service response',
    );
  }

  static Future<String> _fetchLegalContent({
    required String endpoint,
    required String language,
    required String emptyErrorMessage,
    required String invalidErrorMessage,
  }) async {
    final code = _normalizeLanguage(language);
    final response = await ApiHelper.get(
      endpoint,
      queryParameters: <String, dynamic>{'language': code},
    );

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException(invalidErrorMessage, messageKey: 'requestFailed');
    }

    final content = data['content'];
    if (content is! String || content.trim().isEmpty) {
      throw AppException(emptyErrorMessage, messageKey: 'requestFailed');
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
