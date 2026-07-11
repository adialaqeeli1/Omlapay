import 'package:flutter/foundation.dart';

import '../../../core/services/legal_service.dart';
import '../../../core/utils/app_exception.dart';

class PrivacyPolicyProvider extends ChangeNotifier {
  PrivacyPolicyProvider({required this.language}) {
    fetchPolicy();
  }

  final String language;

  String? _content;
  bool _isLoading = false;
  String? _errorKey;
  String? _errorMessage;
  bool _disposed = false;

  String? get content => _content;
  bool get isLoading => _isLoading;
  String? get errorKey => _errorKey;
  String? get errorMessage => _errorMessage;
  bool get hasContent => _content != null;
  bool get hasError => _errorKey != null || _errorMessage != null;

  Future<void> fetchPolicy() async {
    _isLoading = true;
    _errorKey = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await LegalService.fetchPrivacyPolicy(language: language);
      if (_disposed) return;
      _content = data;
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

  Future<void> retry() => fetchPolicy();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
