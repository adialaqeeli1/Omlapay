import 'package:flutter/foundation.dart';

import '../../../../../core/services/about_service.dart';

class AboutProvider extends ChangeNotifier {
  AboutProvider({required this.language}) {
    fetchAbout();
  }

  final String language;

  String? _description;
  bool _isLoading = false;
  bool _disposed = false;

  String? get description => _description;
  bool get isLoading => _isLoading;

  Future<void> fetchAbout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await AboutService.fetchAboutDescription(language: language);
      if (_disposed) return;
      _description = data;
    } catch (_) {
      // Silent fallback — the view renders the local l10n copy when
      // [description] is null, so transport/server errors don't need surfacing.
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
