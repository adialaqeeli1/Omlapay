import 'package:flutter/material.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../providers/auth_provider.dart';

class ReceiveCoinsHistoryProvider extends ChangeNotifier {
  ReceiveCoinsHistoryProvider(this.authProvider) {
    authProvider.addListener(_onAuthChanged);
    _loadData();
  }

  final AuthProvider authProvider;

  List<TransactionModel> _allTransactions = [];
  bool _isLoading = false;
  bool _disposed = false;
  bool get isLoading => _isLoading;

  bool get isVerified => authProvider.state.user?.isVerified ?? false;
  bool get showVerificationWarning => !isVerified;

  void _onAuthChanged() {
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

    // Simulate loading data
    await Future.delayed(const Duration(seconds: 2));
    if (_disposed) return;

    _allTransactions = MockData.getTransactions();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  List<String> get uniqueCoinSymbols {
    final allSymbols = MockData.coins.map((e) => e.symbol).toList();
    return ['All', ...allSymbols];
  }

  List<TransactionModel> getTransactionsForCoin(String coinSymbol) {
    if (coinSymbol == 'All') {
      return _allTransactions..sort((a, b) => b.date.compareTo(a.date));
    }
    return _allTransactions
        .where((element) => element.coinSymbol == coinSymbol)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
