import 'package:flutter/foundation.dart';
import '../core/constants/endpoints.dart';
import '../core/services/api_helper.dart';
class GlobalProvider extends ChangeNotifier {
  String _selectedCurrency = 'USD';

  String get selectedCurrency => _selectedCurrency;

  bool _isBalanceVisible = false;
  bool get isBalanceVisible => _isBalanceVisible;

  bool _isBalanceLoading = false;
  bool get isBalanceLoading => _isBalanceLoading;

  bool _hasFetchedCurrency = false;

  void onAuthChanged(bool isAuthenticated) {
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
      if (currency != null && _selectedCurrency.toLowerCase() != currency.toLowerCase()) {
        _selectedCurrency = currency.toUpperCase();
        notifyListeners();
      }
    } catch (e) {
      // API failed, fallback to current selected currency (default is USD)
    }
  }

  Future<void> updateCurrency(String currency) async {
    if (_selectedCurrency == currency) return;

    try {
      final response = await ApiHelper.put(
        Endpoints.userSettingsCurrency,
        {'currency': currency.toLowerCase()},
      );
      final newCurrency = response['data']?['currency'] as String?;
      if (newCurrency != null) {
        _selectedCurrency = newCurrency.toUpperCase();
        notifyListeners();
      }
    } catch (e) {
      // API failed, do not update selected currency. It will remain the already selected one.
    }
  }

  Future<void> toggleBalanceVisibility() async {
    if (!_isBalanceVisible) {
      // Showing balance: Simulate loading
      _isBalanceLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));

      _isBalanceVisible = true;
      _isBalanceLoading = false;
      notifyListeners();
    } else {
      // Hiding balance: Instant
      _isBalanceVisible = false;
      notifyListeners();
    }
  }
}
