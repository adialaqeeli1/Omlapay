import '../constants/endpoints.dart';
import '../utils/app_exception.dart';
import 'api_helper.dart';

/// Fetches the About screen content from the public API.
class AboutService {
  AboutService._();

  static const Set<String> _supportedLanguages = {'en', 'ar'};

  /// Returns the about description text for [language] (e.g. `en`, `ar`).
  /// Throws [AppException] on transport/server errors or missing content.
  static Future<String> fetchAboutDescription({
    required String language,
  }) async {
    final code = _normalizeLanguage(language);
    final response = await ApiHelper.get(
      Endpoints.about,
      queryParameters: <String, dynamic>{'language': code},
    );

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException('Invalid about response', messageKey: 'requestFailed');
    }

    final description = data['description'];
    if (description is! String || description.trim().isEmpty) {
      throw AppException(
        'About description is empty',
        messageKey: 'requestFailed',
      );
    }

    return description;
  }

  static String _normalizeLanguage(String language) {
    final lower = language.trim().toLowerCase();
    final short = lower.split(RegExp('[-_]')).first;
    if (_supportedLanguages.contains(short)) return short;
    return 'en';
  }
}
