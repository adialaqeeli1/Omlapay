import 'package:flutter/foundation.dart';

import '../core/models/wallet_model/wallet_model.dart';
import '../modules/send_receive_swap_coin/receive/services/receive_wallets_service.dart';
import 'global_provider.dart';

/// Global provider that fetches and caches the user's wallet balances.
///
/// Fetches on creation (in parallel with SSE prices stream) and re-fetches
/// whenever the selected currency changes in [GlobalProvider].
class WalletsProvider extends ChangeNotifier {
  WalletsProvider(this._globalProvider, {ReceiveWalletsService? walletsService})
      : _walletsService = walletsService ?? ReceiveWalletsService() {
    _activeCurrency = _globalProvider.selectedCurrency;
    _globalProvider.addListener(_onCurrencyUpdated);
    _fetchWallets();
  }

  final GlobalProvider _globalProvider;
  final ReceiveWalletsService _walletsService;

  List<WalletNetworkModel> _wallets = [];
  bool _isLoading = false;
  bool _kycRequired = false;
  String? _errorMessage;
  String? _activeCurrency;
  bool _isDisposed = false;

  List<WalletNetworkModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  bool get kycRequired => _kycRequired;
  String? get errorMessage => _errorMessage;

  /// Returns the fiat balance for a coin symbol based on the selected currency.
  ///
  /// Searches across all networks. Returns `currentBalance` when USD is
  /// selected, `currentBalanceSar` when SAR is selected.
  String balanceForCoin(String symbol) {
    final key = symbol.trim().toUpperCase();
    if (key.isEmpty) return '0.00';

    for (final network in _wallets) {
      for (final coin in network.coins) {
        if (coin.symbol.toUpperCase() == key) {
          final balance = _globalProvider.selectedCurrency.toUpperCase() == 'SAR'
              ? coin.currentBalanceSar
              : coin.currentBalance;
          return balance.toStringAsFixed(2);
        }
      }
    }
    return '0.00';
  }

  /// Public method to re-fetch wallets (e.g. pull-to-refresh on receive screen).
  Future<void> refreshWallets() => _fetchWallets();

  Future<void> _fetchWallets() async {
    _isLoading = true;
    _errorMessage = null;
    _notifySafely();

    try {
      final result = await _walletsService.fetchWallets();
      if (_isDisposed) return;
      _wallets = result.networks;
      _kycRequired = result.kycRequired;
    } catch (error) {
      if (_isDisposed) return;
      _wallets = [];
      _errorMessage = error.toString();
      _kycRequired = false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _notifySafely();
      }
    }
  }

  void _onCurrencyUpdated() {
    final selectedCurrency = _globalProvider.selectedCurrency;
    if (selectedCurrency == _activeCurrency) return;

    _activeCurrency = selectedCurrency;
    _fetchWallets();
  }

  void _notifySafely() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _globalProvider.removeListener(_onCurrencyUpdated);
    super.dispose();
  }
}
