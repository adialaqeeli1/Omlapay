import 'package:flutter/foundation.dart';

class CoinDetailsProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _balance = '0.00';
  String get balance => _balance;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Initialize with the balance passed from the coin model.
  /// Later this will be replaced by an API call for coin-wise balance.
  void initWithBalance(String balance) {
    _balance = balance;
    notifyListeners();
  }

  /// TODO: Replace with actual API call once endpoint is provided.
  Future<void> fetchCoinBalance(String coinSymbol) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // API call will go here
      // final response = await ApiHelper.get('...');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
