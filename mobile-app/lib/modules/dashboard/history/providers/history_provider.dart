import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';

class HistoryProvider extends ChangeNotifier {
  String?
  _selectedCoinFilter; // null = All, or coin symbol like 'USDT', 'BTC', etc.
  TransactionType? _selectedTransactionTypeFilter; // null = All
  DateTime? _dateStart;
  DateTime? _dateEnd;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? get selectedCoinFilter => _selectedCoinFilter;
  TransactionType? get selectedTransactionTypeFilter =>
      _selectedTransactionTypeFilter;
  DateTime? get dateStart => _dateStart;
  DateTime? get dateEnd => _dateEnd;
  List<TransactionModel> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TransactionModel> get _filteredTransactions {
    var result = _transactions;

    if (_selectedCoinFilter != null && _selectedCoinFilter != 'All') {
      result = result
          .where(
            (tx) =>
                tx.coinSymbol.toUpperCase() ==
                _selectedCoinFilter!.toUpperCase(),
          )
          .toList();
    }

    if (_selectedTransactionTypeFilter != null) {
      result = result
          .where((tx) => tx.type == _selectedTransactionTypeFilter)
          .toList();
    }

    if (_dateStart != null) {
      final startOfDay = DateTime(
        _dateStart!.year,
        _dateStart!.month,
        _dateStart!.day,
      );
      result = result.where((tx) => !tx.date.isBefore(startOfDay)).toList();
    }

    if (_dateEnd != null) {
      final endOfDay = DateTime(
        _dateEnd!.year,
        _dateEnd!.month,
        _dateEnd!.day,
        23,
        59,
        59,
        999,
      );
      result = result.where((tx) => !tx.date.isAfter(endOfDay)).toList();
    }

    return result;
  }

  HistoryProvider() {
    developer.log('HistoryProvider: Initializing with dummy data');
    _loadDummyData();
  }

  // TODO: Replace with actual API call when backend is ready
  // Future<void> loadTransactions() async {
  //   try {
  //     _isLoading = true;
  //     _errorMessage = null;
  //     notifyListeners();
  //
  //     final response = await apiService.getTransactions();
  //     _transactions = response.map((json) => TransactionModel.fromJson(json)).toList();
  //     _isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  void _loadDummyData() {
    developer.log('HistoryProvider: Loading dummy transaction data');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        _transactions = await _generateDummyTransactions();
        _isLoading = false;
        developer.log(
          'HistoryProvider: Successfully loaded ${_transactions.length} dummy transactions',
        );
        notifyListeners();
      } catch (e) {
        developer.log(
          'HistoryProvider: Error loading dummy data: $e',
          error: e,
        );
        _errorMessage = 'Failed to load transactions';
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // TODO: Implement refresh when API is ready
  Future<void> refresh() async {
    developer.log('HistoryProvider: Refreshing transactions');
    _loadDummyData();
  }

  void setCoinFilter(String? coinSymbol) {
    developer.log('HistoryProvider: Setting coin filter to: $coinSymbol');
    _selectedCoinFilter = coinSymbol;
    notifyListeners();
  }

  void setTransactionTypeFilter(TransactionType? type) {
    developer.log('HistoryProvider: Setting transaction type filter to: $type');
    _selectedTransactionTypeFilter = type;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    developer.log('HistoryProvider: Setting date range: $start - $end');
    _dateStart = start;
    _dateEnd = end;
    notifyListeners();
  }

  void clearFilter() {
    developer.log('HistoryProvider: Clearing filter');
    _selectedCoinFilter = null;
    _selectedTransactionTypeFilter = null;
    _dateStart = null;
    _dateEnd = null;
    notifyListeners();
  }

  Future<List<TransactionModel>> _generateDummyTransactions() async {
    developer.log('HistoryProvider: Generating dummy transactions');

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.getTransactions();
    } catch (e) {
      developer.log(
        'HistoryProvider: Error generating dummy transactions: $e',
        error: e,
      );
      return [];
    }
  }
}
