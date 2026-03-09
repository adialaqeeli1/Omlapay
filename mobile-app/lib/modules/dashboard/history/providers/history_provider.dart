import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';

class HistoryProvider extends ChangeNotifier {
  String? _selectedCoinFilter; // null = All, or coin symbol like 'USDT', 'BTC', etc.
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? get selectedCoinFilter => _selectedCoinFilter;
  List<TransactionModel> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TransactionModel> get _filteredTransactions {
    if (_selectedCoinFilter == null || _selectedCoinFilter == 'All') {
      developer.log('HistoryProvider: Returning all ${_transactions.length} transactions');
      return _transactions;
    }
    final filtered = _transactions
        .where((tx) => tx.coinSymbol.toUpperCase() == _selectedCoinFilter!.toUpperCase())
        .toList();
    developer.log('HistoryProvider: Filtered ${filtered.length} transactions for coin: $_selectedCoinFilter');
    return filtered;
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
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        _transactions = _generateDummyTransactions();
        _isLoading = false;
        developer.log('HistoryProvider: Successfully loaded ${_transactions.length} dummy transactions');
        notifyListeners();
      } catch (e) {
        developer.log('HistoryProvider: Error loading dummy data: $e', error: e);
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

  void clearFilter() {
    developer.log('HistoryProvider: Clearing filter');
    _selectedCoinFilter = null;
    notifyListeners();
  }

  List<TransactionModel> _generateDummyTransactions() {
    developer.log('HistoryProvider: Generating dummy transactions');
    final now = DateTime.now();
    try {
      return [
      TransactionModel(
        id: '1',
        coinSymbol: 'USDT',
        coinName: 'Tether USDT',
        amount: '100.50',
        valueInCurrency: '100.50',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(hours: 2)),
        toAddress: '0x1234...5678',
        fromAddress: '0xabcd...efgh',
        transactionHash: '0x9876543210abcdef',
        fee: 0.5,
        note: 'Payment received',
      ),
      TransactionModel(
        id: '2',
        coinSymbol: 'BTC',
        coinName: 'Bitcoin',
        amount: '0.005',
        valueInCurrency: '250.00',
        type: TransactionType.sent,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 1)),
        toAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        fromAddress: 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
        transactionHash: 'a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d',
        fee: 0.0001,
        note: 'Sent to friend',
      ),
      TransactionModel(
        id: '3',
        coinSymbol: 'ETH',
        coinName: 'Ethereum',
        amount: '0.5',
        valueInCurrency: '1250.00',
        type: TransactionType.swap,
        status: TransactionStatus.pending,
        date: now.subtract(const Duration(hours: 5)),
        toAddress: null,
        fromAddress: null,
        transactionHash: null,
        fee: 0.01,
        note: 'Swapped ETH to USDT',
      ),
      TransactionModel(
        id: '4',
        coinSymbol: 'USDT',
        coinName: 'Tether USDT',
        amount: '50.00',
        valueInCurrency: '50.00',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 2)),
        toAddress: '0x1234...5678',
        fromAddress: '0xijkl...mnop',
        transactionHash: '0xabcdef1234567890',
        fee: 0.3,
      ),
      TransactionModel(
        id: '5',
        coinSymbol: 'BTC',
        coinName: 'Bitcoin',
        amount: '0.001',
        valueInCurrency: '50.00',
        type: TransactionType.sent,
        status: TransactionStatus.failed,
        date: now.subtract(const Duration(days: 3)),
        toAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        fromAddress: 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
        transactionHash: null,
        fee: 0.00005,
        note: 'Transaction failed',
      ),
      TransactionModel(
        id: '6',
        coinSymbol: 'ETH',
        coinName: 'Ethereum',
        amount: '1.0',
        valueInCurrency: '2500.00',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 5)),
        toAddress: '0x1234...5678',
        fromAddress: '0xqrst...uvwx',
        transactionHash: '0x1234567890abcdef',
        fee: 0.02,
      ),
      TransactionModel(
        id: '7',
        coinSymbol: 'USDT',
        coinName: 'Tether USDT',
        amount: '170.00',
        valueInCurrency: '170.00',
        type: TransactionType.sent,
        status: TransactionStatus.failed,
        date: DateTime(2024, 7, 10, 12, 6, 20),
        toAddress: '0x1234...5678',
        fromAddress: '0xabcd...efgh',
        transactionHash: null,
        fee: 0.5,
      ),
      TransactionModel(
        id: '8',
        coinSymbol: 'BTC',
        coinName: 'Bitcoin',
        amount: '170.00',
        valueInCurrency: '8500000.00',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: DateTime(2024, 7, 10, 12, 6, 20),
        toAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        fromAddress: 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
        transactionHash: 'a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d',
        fee: 0.0001,
      ),
      TransactionModel(
        id: '9',
        coinSymbol: 'USDT',
        coinName: 'Tether USDT',
        amount: '50.00',
        valueInCurrency: '50.00',
        type: TransactionType.received,
        status: TransactionStatus.pending,
        date: DateTime(2024, 7, 15, 10, 30, 0),
        toAddress: '0x1234...5678',
        fromAddress: '0xijkl...mnop',
        transactionHash: null,
        fee: 0.3,
      ),
      TransactionModel(
        id: '10',
        coinSymbol: 'SOL',
        coinName: 'Solana',
        amount: '100.00',
        valueInCurrency: '15000.00',
        type: TransactionType.received,
        status: TransactionStatus.completed,
        date: DateTime(2024, 7, 20, 8, 15, 0),
        toAddress: '7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU',
        fromAddress: '9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM',
        transactionHash: '5VERv8NMvzbJMEkV8xnrLkEaWRtSz9CosKDYjCJjBRnbJLgp8uirBgmQpjKhoR4tjF3ZpBzrW2mrV4xY4EPr8i8pm',
        fee: 0.00025,
      ),
    ];
    } catch (e) {
      developer.log('HistoryProvider: Error generating dummy transactions: $e', error: e);
      return [];
    }
  }
}
