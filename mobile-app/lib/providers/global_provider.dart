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

  Future<void> updateCurrency(String currency) async {
    if (_selectedCurrency == currency) return;

    if (!_isAuthenticated) {
      _selectedCurrency = currency.toUpperCase();
      notifyListeners();
      return;
    }

    try {
      final response = await ApiHelper.put(Endpoints.userSettingsCurrency, {
        'currency': currency.toLowerCase(),
      });
      final newCurrency = response['data']?['currency'] as String?;
      if (newCurrency != null) {
        _selectedCurrency = newCurrency.toUpperCase();
        notifyListeners();
      }
    } catch (e) {
      // API failed, do not update selected currency. It will remain the already selected one.
    }
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }
}
