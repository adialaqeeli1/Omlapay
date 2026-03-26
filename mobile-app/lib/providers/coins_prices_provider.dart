import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../core/models/coin_model/coin_model.dart';
import '../modules/dashboard/home/services/coins_prices_stream_service.dart';
import 'global_provider.dart';

/// App-wide real-time coin prices from the SSE stream (`/v1/coins/prices/stream`).
/// Listen with [coins] / [coinForSymbol] anywhere below [MaterialApp].
class CoinsPricesProvider extends ChangeNotifier {
  CoinsPricesProvider(this._globalProvider, this._pricesStreamService) {
    _activeCurrency = _globalProvider.selectedCurrency;
    _globalProvider.addListener(_onCurrencyUpdated);
    _isLoading = true;
    _connectPricesStream();
  }

  final GlobalProvider _globalProvider;
  final CoinsPricesStreamService _pricesStreamService;

  List<CoinModel> _coins = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _activeCurrency;
  bool _isDisposed = false;
  StreamSubscription<List<CoinModel>>? _pricesSubscription;

  /// Latest coin rows from the stream (same data as home asset cards).
  List<CoinModel> get coins => _coins;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  /// Resolved price row for a symbol, or `null` if not in the last payload.
  CoinModel? coinForSymbol(String symbol) {
    final key = symbol.trim().toUpperCase();
    if (key.isEmpty) return null;
    for (final c in _coins) {
      if (c.symbol.toUpperCase() == key) return c;
    }
    return null;
  }

  void _onCurrencyUpdated() {
    final selectedCurrency = _globalProvider.selectedCurrency;
    if (selectedCurrency == _activeCurrency) return;

    _activeCurrency = selectedCurrency;
    _coins = [];
    _isLoading = true;
    _notifySafely();
    _connectPricesStream();
  }

  Future<void> _connectPricesStream() async {
    await _pricesSubscription?.cancel();
    _pricesSubscription = null;
    final currency = _activeCurrency ?? 'USD';
    if (_isDisposed) return;

    _pricesSubscription = _pricesStreamService
        .streamCoinPrices(currency)
        .listen(_onPricesUpdate, onError: _onStreamError, cancelOnError: false);
  }

  void _onPricesUpdate(List<CoinModel> coins) {
    if (_isDisposed) return;
    final hasChanged = !listEquals(_coins, coins);
    if (!hasChanged && !_isLoading) return;

    _coins = coins;
    if (_isLoading) {
      _isLoading = false;
    }
    if (_errorMessage != null) {
      _errorMessage = null;
    }
    _notifySafely();
  }

  void _onStreamError(Object error, [StackTrace? stackTrace]) {
    if (_isDisposed) return;
    _isLoading = false;
    final nextError = error.toString();
    if (_errorMessage != nextError) {
      _errorMessage = nextError;
      _notifySafely();
    }
  }

  void _notifySafely() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pricesSubscription?.cancel();
    _pricesSubscription = null;
    _globalProvider.removeListener(_onCurrencyUpdated);
    super.dispose();
  }
}
