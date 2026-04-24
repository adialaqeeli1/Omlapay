import 'package:flutter/foundation.dart';

import '../../../../../core/services/legal_service.dart';
import '../../../../../core/utils/app_exception.dart';

class TermsConditionsProvider extends ChangeNotifier {
  TermsConditionsProvider({required this.language}) {
    fetchTerms();
  }

  final String language;

  String? _content;
  bool _isLoading = false;
  String? _errorKey;
  bool _disposed = false;

  String? get content => _content;
  bool get isLoading => _isLoading;
  String? get errorKey => _errorKey;
  bool get hasContent => _content != null;

  Future<void> fetchTerms() async {
    _isLoading = true;
    _errorKey = null;
    notifyListeners();

    try {
      final data = await LegalService.fetchTermsOfService(language: language);
      if (_disposed) return;
      _content = data;
    } on AppException catch (e) {
      if (_disposed) return;
      _errorKey = e.messageKey ?? 'requestFailed';
    } catch (_) {
      if (_disposed) return;
      _errorKey = 'requestFailed';
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> retry() => fetchTerms();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
