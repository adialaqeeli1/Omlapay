import 'package:flutter/foundation.dart';
import '../core/constants/endpoints.dart';
import '../core/services/api_helper.dart';

class GlobalProvider extends ChangeNotifier {
  String _selectedCurrency = 'USD';

  String get selectedCurrency => _selectedCurrency;

  bool _isBalanceVisible = false;
  bool get isBalanceVisible => _isBalanceVisible;

  bool _hasFetchedCurrency = false;
  bool _isAuthenticated = false;

  void onAuthChanged(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    if (isAuthenticated) {
      if (!_hasFetchedCurrency) {
        _fetchCurrencySetup();
      }
    } else {
      if (_hasFetchedCurrency || _selectedCurrency != 'USD') {
        _hasFetchedCurrency = false;
        _selectedCurrency = 'USD';
        notifyListeners();
      }
    }
  }

  Future<void> _fetchCurrencySetup() async {
    _hasFetchedCurrency = true;

    try {
      final response = await ApiHelper.get(Endpoints.userSettingsCurrency);
      final currency = response['data']?['currency'] as String?;
      if (currency != null &&
          _selectedCurrency.toLowerCase() != currency.toLowerCase()) {
        _selectedCurrency = currency.toUpperCase();
        notifyListeners();
      }
    } catch (e) {
      // API failed, fallback to current selected currency (default is USD)
    }
  }

  /// Toggles between the two supported fiat currencies (USD <-> SAR).
  Future<void> toggleCurrency() {
    final next = _selectedCurrency.toUpperCase() == 'USD' ? 'SAR' : 'USD';
    return updateCurrency(next);
  }

  Future<void> updateCurrency(String currency) async {
    if (_selectedCurrency.toLowerCase() == currency.toLowerCase()) return;

    _selectedCurrency = currency.toUpperCase();
    notifyListeners();

    if (!_isAuthenticated) return;

    try {
      final response = await ApiHelper.put(Endpoints.userSettingsCurrency, {
        'currency': currency.toLowerCase(),
      });
      final newCurrency = response['data']?['currency'] as String?;
      if (newCurrency != null &&
          newCurrency.toUpperCase() != _selectedCurrency) {
        _selectedCurrency = newCurrency.toUpperCase();
        notifyListeners();
      }
    } catch (e) {
      // API failed; keep the optimistic local update so the UI stays responsive.
    }
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }
}
