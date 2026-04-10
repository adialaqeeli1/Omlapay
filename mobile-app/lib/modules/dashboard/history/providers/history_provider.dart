import 'dart:developer' as developer;
import 'package:flutter/material.dart';

import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../providers/coins_prices_provider.dart';

class HistoryProvider extends ChangeNotifier {
  final CoinsPricesProvider _coinsPrices;

  String?
  _selectedCoinFilter; // null = All, or coin symbol like 'USDT', 'BTC', etc.
  String? _selectedStatusFilter; // null = All, or 'COMPLETED', 'PENDING', 'FAILED'
  DateTime? _dateStart;
  DateTime? _dateEnd;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? get selectedCoinFilter => _selectedCoinFilter;
  String? get selectedStatusFilter => _selectedStatusFilter;
  DateTime? get dateStart => _dateStart;
  DateTime? get dateEnd => _dateEnd;
  List<TransactionModel> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TransactionModel> get _filteredTransactions {
    var result = _transactions;

    if (_selectedCoinFilter != null && _selectedCoinFilter!.trim().isNotEmpty) {
      result = result
          .where(
            (tx) =>
                tx.assetSymbol.toUpperCase() ==
                _selectedCoinFilter!.toUpperCase(),
          )
          .toList();
    }

    if (_selectedStatusFilter != null) {
      result = result
          .where(
            (tx) =>
                tx.status.toUpperCase() ==
                _selectedStatusFilter!.toUpperCase(),
          )
          .toList();
    }

    if (_dateStart != null) {
      final startOfDay = DateTime(
        _dateStart!.year,
        _dateStart!.month,
        _dateStart!.day,
      );
      result =
          result.where((tx) => !tx.createdAt.isBefore(startOfDay)).toList();
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
      result = result.where((tx) => !tx.createdAt.isAfter(endOfDay)).toList();
    }

    return result;
  }

  HistoryProvider(this._coinsPrices) {
    developer.log('HistoryProvider: Initializing with dummy data');
    _coinsPrices.addListener(_onStreamedCoinsUpdated);
  }

  void _onStreamedCoinsUpdated() {
    final before = _selectedCoinFilter;
    _reconcileCoinFilterWithStream();
    if (before != _selectedCoinFilter) {
      notifyListeners();
    }
  }

  /// Clear coin filter if that symbol is no longer in the SSE coin list.
  void _reconcileCoinFilterWithStream() {
    final symbols = _coinsPrices.coins
        .map((c) => c.symbol.toUpperCase())
        .toSet();
    final sel = _selectedCoinFilter?.trim().toUpperCase();
    if (sel != null &&
        sel.isNotEmpty &&
        symbols.isNotEmpty &&
        !symbols.contains(sel)) {
      _selectedCoinFilter = null;
    }
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

  // TODO: Implement refresh when API is ready
  Future<void> refresh() async {
    developer.log('HistoryProvider: Refreshing transactions');
  }

  void setCoinFilter(String? coinSymbol) {
    developer.log('HistoryProvider: Setting coin filter to: $coinSymbol');
    _selectedCoinFilter = coinSymbol;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    developer.log('HistoryProvider: Setting status filter to: $status');
    _selectedStatusFilter = status;
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
    _selectedStatusFilter = null;
    _dateStart = null;
    _dateEnd = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _coinsPrices.removeListener(_onStreamedCoinsUpdated);
    super.dispose();
  }
}
