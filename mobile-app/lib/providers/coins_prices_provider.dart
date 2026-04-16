import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../core/models/coin_model/coin_model.dart';
import '../core/services/coins_prices_stream_service.dart';
import '../core/services/coins_service.dart';
import 'global_provider.dart';

/// App-wide real-time coin prices from the SSE stream (`/v1/coins/prices/stream`).
/// Listen with [coins] / [coinForSymbol] anywhere below [MaterialApp].
class CoinsPricesProvider extends ChangeNotifier {
  CoinsPricesProvider(
    this._globalProvider,
    this._pricesStreamService,
    this._coinsService,
  ) {
    _activeCurrency = _globalProvider.selectedCurrency;
    _globalProvider.addListener(_onCurrencyUpdated);
  }

  final GlobalProvider _globalProvider;
  final CoinsPricesStreamService _pricesStreamService;
  final CoinsService _coinsService;

  List<CoinModel> _coins = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _activeCurrency;
  bool _isDisposed = false;
  bool _hasFetchedCoins = false;
  StreamSubscription<List<CoinModel>>? _pricesSubscription;

  /// Latest coin rows from the stream (same data as home asset cards).
  List<CoinModel> get coins => _coins;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void onAuthChanged(bool isAuthenticated) {
    if (isAuthenticated) {
      if (!_hasFetchedCoins) {
        _isLoading = true;
        _hasFetchedCoins = true;
        _fetchCoinsOnce();
        _connectPricesStream();
      }
    } else {
      _hasFetchedCoins = false;
      _pricesSubscription?.cancel();
      _pricesSubscription = null;
      _coins = [];
      _isLoading = false;
      _errorMessage = null;
      _notifySafely();
    }
  }

  /// Resolved price row for a symbol, or `null` if not in the last payload.
  CoinModel? coinForSymbol(String symbol) {
    final key = symbol.trim().toUpperCase();
    if (key.isEmpty) return null;
    for (final c in _coins) {
      if (c.symbol.toUpperCase() == key) return c;
    }
    return null;
  }

  /// One-time REST fetch to seed full coin metadata (network, id, iconUrl, etc.)
  /// that the SSE stream may not include.
  Future<void> _fetchCoinsOnce() async {
    try {
      final currency = _activeCurrency ?? 'USD';
      final coins = await _coinsService.fetchCoins(currency: currency);
      if (_isDisposed || coins.isEmpty) return;
      // Only seed if we haven't received SSE data yet, or merge with existing.
      if (_coins.isEmpty) {
        _coins = coins;
        _notifySafely();
      } else {
        _coins = _mergeWithExisting(_coins, metadataSource: coins);
        _notifySafely();
      }
    } catch (_) {
      // Non-critical — SSE stream will still provide price data.
    }
  }

  void _onCurrencyUpdated() {
    final selectedCurrency = _globalProvider.selectedCurrency;
    if (selectedCurrency == _activeCurrency) return;

    _activeCurrency = selectedCurrency;
    _coins = [];
    _isLoading = true;
    _notifySafely();
    _fetchCoinsOnce();
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

  void _onPricesUpdate(List<CoinModel> incoming) {
    if (_isDisposed) return;

    // Merge: preserve metadata fields (id, network, iconUrl, etc.) from
    // previously known coins when the SSE stream doesn't include them.
    final merged = _mergeWithExisting(incoming, metadataSource: _coins);

    final hasChanged = !listEquals(_coins, merged);
    if (!hasChanged && !_isLoading) return;

    _coins = merged;
    if (_isLoading) {
      _isLoading = false;
    }
    if (_errorMessage != null) {
      _errorMessage = null;
    }
    _notifySafely();
  }

  /// Carries forward metadata fields that the SSE stream may omit.
  List<CoinModel> _mergeWithExisting(
    List<CoinModel> incoming, {
    required List<CoinModel> metadataSource,
  }) {
    if (metadataSource.isEmpty) return incoming;

    final existingBySymbol = <String, CoinModel>{
      for (final c in metadataSource) c.symbol.toUpperCase(): c,
    };

    return incoming.map((coin) {
      final existing = existingBySymbol[coin.symbol.toUpperCase()];
      if (existing == null) return coin;

      return coin.copyWith(
        id: coin.id ?? existing.id,
        network: coin.network ?? existing.network,
        iconUrl: coin.iconUrl ?? existing.iconUrl,
        networkIconUrl: coin.networkIconUrl ?? existing.networkIconUrl,
        contractAddress: coin.contractAddress ?? existing.contractAddress,
        minWithdrawal: coin.minWithdrawal ?? existing.minWithdrawal,
        minDeposit: coin.minDeposit ?? existing.minDeposit,
        withdrawalFee: coin.withdrawalFee ?? existing.withdrawalFee,
        description: coin.description ?? existing.description,
        price: coin.price ?? existing.price,
        decimals: coin.decimals == 0 && existing.decimals != 0
            ? existing.decimals
            : coin.decimals,
      );
    }).toList(growable: false);
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
