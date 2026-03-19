import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../providers/global_provider.dart';
import '../services/coins_service.dart';

class HomeProvider extends ChangeNotifier {
  static const Duration _autoRefreshInterval = Duration(minutes: 2);

  HomeProvider(this._globalProvider, this._coinsService) {
    _activeCurrency = _globalProvider.selectedCurrency;
    _globalProvider.addListener(_onCurrencyUpdated);
    fetchCoins(currency: _activeCurrency ?? 'USD');
    _startAutoRefresh();
  }

  final GlobalProvider _globalProvider;
  final CoinsService _coinsService;

  List<CoinModel> _coins = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _activeCurrency;
  int _requestSequence = 0;
  bool _isDisposed = false;
  Timer? _refreshTimer;
  bool _isFetchInFlight = false;
  String? _queuedCurrency;
  bool _queuedShowLoader = false;

  List<CoinModel> get coins => _coins;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _onCurrencyUpdated() {
    final selectedCurrency = _globalProvider.selectedCurrency;
    if (selectedCurrency == _activeCurrency) return;

    _activeCurrency = selectedCurrency;
    fetchCoins(currency: selectedCurrency);
  }

  Future<void> fetchCoins({
    required String currency,
    bool showLoader = true,
  }) async {
    if (_isDisposed) return;
    if (_isFetchInFlight) {
      _queuedCurrency = currency;
      _queuedShowLoader = _queuedShowLoader || showLoader;
      return;
    }

    _isFetchInFlight = true;
    final requestId = ++_requestSequence;
    final hadError = _errorMessage != null;

    if (showLoader) {
      _isLoading = true;
      if (hadError) {
        _errorMessage = null;
      }
      _notifySafely();
    }

    try {
      final loadedCoins = await _coinsService.fetchCoins(
        currency: currency,
        forceSync: showLoader,
      );
      if (_isStaleRequest(requestId)) return;

      final hasChanged = !listEquals(_coins, loadedCoins);
      _coins = loadedCoins;
      if (hadError) {
        _errorMessage = null;
      }

      if (!showLoader && (hasChanged || hadError)) {
        _notifySafely();
      }
    } catch (error) {
      if (_isStaleRequest(requestId)) return;
      final nextError = error.toString();
      if (_errorMessage != nextError) {
        _errorMessage = nextError;
        _notifySafely();
      }
    } finally {
      _isFetchInFlight = false;
      if (!_isStaleRequest(requestId)) {
        if (showLoader) {
          _isLoading = false;
          _notifySafely();
        }
      }

      final queuedCurrency = _queuedCurrency;
      final queuedShowLoader = _queuedShowLoader;
      _queuedCurrency = null;
      _queuedShowLoader = false;

      if (queuedCurrency != null && !_isDisposed) {
        fetchCoins(currency: queuedCurrency, showLoader: queuedShowLoader);
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      final activeCurrency = _activeCurrency;
      if (activeCurrency == null || _isDisposed || _isLoading) {
        return;
      }
      fetchCoins(currency: activeCurrency, showLoader: false);
    });
  }

  bool _isStaleRequest(int requestId) =>
      _isDisposed || requestId != _requestSequence;

  void _notifySafely() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _refreshTimer?.cancel();
    _globalProvider.removeListener(_onCurrencyUpdated);
    super.dispose();
  }
}
