import '../constants/endpoints.dart';
import '../models/faq_model/faq_model.dart';
import '../utils/app_exception.dart';
import 'api_helper.dart';

/// Fetches FAQ content from the public API.
class FaqService {
  FaqService._();

  static const Set<String> _supportedLanguages = {'en', 'ar'};

  /// Returns the FAQ list for [language] (e.g. `en`, `ar`), sorted ascending
  /// by `displayOrder`.
  /// Throws [AppException] on transport/server errors, malformed payloads,
  /// or when the list is empty.
  static Future<List<FaqModel>> fetchFaqs({required String language}) async {
    final code = _normalizeLanguage(language);
    final response = await ApiHelper.get(
      Endpoints.legalFaqs,
      queryParameters: <String, dynamic>{'language': code},
    );

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException('Invalid FAQ response', messageKey: 'requestFailed');
    }

    final rawFaqs = data['faqs'];
    if (rawFaqs is! List) {
      throw AppException('Invalid FAQ list payload', messageKey: 'requestFailed');
    }

    final faqs = <FaqModel>[];
    for (final entry in rawFaqs) {
      if (entry is Map<String, dynamic>) {
        faqs.add(FaqModel.fromJson(entry));
      }
    }

    if (faqs.isEmpty) {
      throw AppException('FAQ list is empty', messageKey: 'requestFailed');
    }

    faqs.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return faqs;
  }

  static String _normalizeLanguage(String language) {
    final lower = language.trim().toLowerCase();
    final short = lower.split(RegExp('[-_]')).first;
    if (_supportedLanguages.contains(short)) return short;
    return 'en';
  }
}
