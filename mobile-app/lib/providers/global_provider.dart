import 'package:flutter/foundation.dart';

class GlobalProvider extends ChangeNotifier {
  String _selectedCurrency = 'USD';

  String get selectedCurrency => _selectedCurrency;

  bool _isBalanceVisible = false;
  bool get isBalanceVisible => _isBalanceVisible;

  bool _isBalanceLoading = false;
  bool get isBalanceLoading => _isBalanceLoading;

  void updateCurrency(String currency) {
    if (_selectedCurrency != currency) {
      _selectedCurrency = currency;
      notifyListeners();
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
