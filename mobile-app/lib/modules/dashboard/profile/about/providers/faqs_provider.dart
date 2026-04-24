import 'package:flutter/foundation.dart';

import '../../../../../core/models/faq_model/faq_model.dart';
import '../../../../../core/services/faq_service.dart';
import '../../../../../core/utils/app_exception.dart';

class FaqsProvider extends ChangeNotifier {
  FaqsProvider({required this.language}) {
    fetchFaqs();
  }

  final String language;

  List<FaqModel> _faqs = const [];
  bool _isLoading = false;
  String? _errorKey;
  String? _errorMessage;
  bool _disposed = false;

  List<FaqModel> get faqs => _faqs;
  bool get isLoading => _isLoading;
  String? get errorKey => _errorKey;
  String? get errorMessage => _errorMessage;
  bool get hasContent => _faqs.isNotEmpty;
  bool get hasError => _errorKey != null || _errorMessage != null;

  Future<void> fetchFaqs() async {
    _isLoading = true;
    _errorKey = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await FaqService.fetchFaqs(language: language);
      if (_disposed) return;
      _faqs = data;
    } on AppException catch (e) {
      if (_disposed) return;
      _errorKey = e.messageKey ?? 'requestFailed';
      _errorMessage = e.message.trim().isEmpty ? null : e.message;
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

  Future<void> retry() => fetchFaqs();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
