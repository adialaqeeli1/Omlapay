import 'package:flutter/material.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/coins_prices_provider.dart';

class ReceiveCoinsHistoryProvider extends ChangeNotifier {
  ReceiveCoinsHistoryProvider(this.authProvider, this._coinsPrices) {
    authProvider.addListener(_onAuthChanged);
    _coinsPrices.addListener(_onCoinsUpdated);
    _loadData();
  }

  final AuthProvider authProvider;
  final CoinsPricesProvider _coinsPrices;

  final List<TransactionModel> _allTransactions = [];
  bool _isLoading = false;
  bool _disposed = false;
  bool get isLoading => _isLoading;

  bool get isVerified => authProvider.state.user?.isVerified ?? false;
  bool get showVerificationWarning => !isVerified;

  void _onAuthChanged() {
    if (_disposed) return;
    notifyListeners();
  }

  void _onCoinsUpdated() {
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> completeVerification() async {
    await authProvider.verifyUser();
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    if (_disposed) return;

    //Todo: Handle API for transactions
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    authProvider.removeListener(_onAuthChanged);
    _coinsPrices.removeListener(_onCoinsUpdated);
    super.dispose();
  }

  List<String> get uniqueCoinSymbols {
    final seen = <String>{};
    final allSymbols = <String>[];
    for (final c in _coinsPrices.coins) {
      if (seen.add(c.symbol.toUpperCase())) {
        allSymbols.add(c.symbol);
      }
    }
    return ['All', ...allSymbols];
  }

  List<TransactionModel> getTransactionsForCoin(String coinSymbol) {
    if (coinSymbol == 'All') {
      return _allTransactions
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return _allTransactions
        .where((element) => element.assetSymbol == coinSymbol)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
