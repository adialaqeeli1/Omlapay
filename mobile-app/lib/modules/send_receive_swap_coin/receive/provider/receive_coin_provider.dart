import 'package:flutter/material.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';

class ReceiveCoinProvider extends ChangeNotifier {
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ReceiveCoinProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate loading data
    await Future.delayed(const Duration(seconds: 2));
    _allTransactions = MockData.getTransactions();

    _isLoading = false;
    notifyListeners();
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
