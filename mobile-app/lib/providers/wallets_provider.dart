import 'package:flutter/foundation.dart';

import '../core/extentions/number_extensions.dart';
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
  }

  final GlobalProvider _globalProvider;
  final ReceiveWalletsService _walletsService;

  List<WalletNetworkModel> _wallets = [];
  bool _isLoading = false;
  bool _kycRequired = false;
  String? _errorMessage;
  String? _activeCurrency;
  bool _isDisposed = false;
  bool _hasFetchedWallets = false;
  bool _isAuthenticated = false;

  List<WalletNetworkModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  bool get kycRequired => _kycRequired;
  String? get errorMessage => _errorMessage;

  void onAuthChanged(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    if (isAuthenticated) {
      if (!_hasFetchedWallets) {
        _fetchWallets();
      }
    } else {
      _hasFetchedWallets = false;
      _wallets = [];
      _kycRequired = false;
      _errorMessage = null;
      _notifySafely();
    }
  }

  /// Returns the fiat balance for a coin symbol based on the selected currency.
  ///
  /// Searches across all networks. Returns `currentBalance` when USD is
  /// selected, `currentBalanceSar` when SAR is selected.
  String balanceForCoin(String symbol) {
    final key = symbol.trim().toUpperCase();
    if (key.isEmpty) return '0.0000';

    for (final network in _wallets) {
      for (final coin in network.coins) {
        if (coin.symbol.toUpperCase() == key) {
          final balance = coin.balance;
          return balance.toFormattedAmount();
        }
      }
    }
    return '0.0000';
  }

  /// Returns the raw coin balance as a double for [symbol], or `0.0` when
  /// the symbol isn't held in any wallet. Useful for sorting/comparisons.
  double rawBalanceForCoin(String symbol) {
    final key = symbol.trim().toUpperCase();
    if (key.isEmpty) return 0.0;

    for (final network in _wallets) {
      for (final coin in network.coins) {
        if (coin.symbol.toUpperCase() == key) {
          return coin.balance;
        }
      }
    }
    return 0.0;
  }

  /// Returns the fiat balance for a coin symbol based on the selected currency.
  ///
  /// Searches across all networks. Returns `currentBalance` when USD is
  /// selected, `currentBalanceSar` when SAR is selected.
  String balanceForCoinConverted(String symbol) {
    final key = symbol.trim().toUpperCase();
    if (key.isEmpty) return '0.00';

    for (final network in _wallets) {
      for (final coin in network.coins) {
        if (coin.symbol.toUpperCase() == key) {
          final balance =
              _globalProvider.selectedCurrency.toUpperCase() == 'SAR'
              ? coin.currentBalanceSar
              : coin.currentBalance;
          return balance.toFormattedAmount(decimals: 2);
        }
      }
    }
    return '0.00';
  }

  /// Returns the current user's deposit address for [symbol] on [network].
  ///
  /// When [network] is provided, only coins on that network are considered;
  /// otherwise the first matching symbol across networks is returned. Returns
  /// `null` when no match is found or the address is unavailable.
  String? addressForCoin(String symbol, {String? network}) {
    final symbolKey = symbol.trim().toUpperCase();
    if (symbolKey.isEmpty) return null;
    final networkKey = network?.trim().toUpperCase();

    for (final net in _wallets) {
      if (networkKey != null &&
          networkKey.isNotEmpty &&
          net.network.toUpperCase() != networkKey) {
        continue;
      }
      for (final coin in net.coins) {
        if (coin.symbol.toUpperCase() == symbolKey) {
          return coin.address;
        }
      }
    }
    return null;
  }

  /// Public method to re-fetch wallets (e.g. pull-to-refresh on receive screen).
  Future<void> refreshWallets() => _fetchWallets();

  Future<void> _fetchWallets() async {
    _isLoading = true;
    _errorMessage = null;
    _hasFetchedWallets = true;
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
    if (!_isAuthenticated) return;
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
