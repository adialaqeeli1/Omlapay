import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../providers/global_provider.dart';
import '../services/coins_prices_stream_service.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider(this._globalProvider, this._pricesStreamService) {
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

  List<CoinModel> get coins => _coins;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _onCurrencyUpdated() {
    final selectedCurrency = _globalProvider.selectedCurrency;
    if (selectedCurrency == _activeCurrency) return;

    _activeCurrency = selectedCurrency;
    _isLoading = true;
    _notifySafely();
    _connectPricesStream();
  }

  void _connectPricesStream() {
    _pricesSubscription?.cancel();
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
