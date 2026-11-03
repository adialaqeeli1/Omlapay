import 'package:flutter/material.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/coins_prices_provider.dart';
import '../services/receive_history_service.dart';

class ReceiveCoinsHistoryProvider extends ChangeNotifier {
  ReceiveCoinsHistoryProvider(
    this.authProvider,
    this._coinsPrices, {
    ReceiveHistoryService? service,
  }) : _service = service ?? ReceiveHistoryService() {
    authProvider.addListener(_onAuthChanged);
    _coinsPrices.addListener(_onCoinsUpdated);
    fetchTransactions();
  }

  final AuthProvider authProvider;
  final CoinsPricesProvider _coinsPrices;
  final ReceiveHistoryService _service;

  final List<TransactionModel> _allTransactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _nextCursor;
  String? _errorKey;
  String? _currentAsset;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorKey => _errorKey;
  String? get currentAsset => _currentAsset;

  bool get isVerified => authProvider.state.user?.isVerified ?? false;
  bool get showVerificationWarning => !isVerified;

  List<TransactionModel> get transactions {
    return [..._allTransactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _onAuthChanged() {
    if (_disposed) return;
    notifyListeners();
  }

  void _onCoinsUpdated() {
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> completeVerification() async {
    await authProvider.verifyUser();
    if (_disposed) return;
    notifyListeners();
  }

  /// Sets the active coin filter from the tab bar. `'All'` clears the filter.
  /// Re-fetches from the API when the filter actually changes.
  void setCoinFilter(String coinSymbol) {
    final newAsset = coinSymbol == 'All' ? null : coinSymbol;
    if (newAsset == _currentAsset) return;
    _currentAsset = newAsset;
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final requestAsset = _currentAsset;
    _isLoading = true;
    _errorKey = null;
    _allTransactions.clear();
    _nextCursor = null;
    _hasMore = false;
    notifyListeners();

    try {
      final result = await _service.fetchHistory(asset: requestAsset);
      if (_disposed || requestAsset != _currentAsset) return;
      _allTransactions.addAll(result.transactions);
      _nextCursor = result.nextCursor;
      _hasMore = result.hasMore;
    } on AppException catch (e) {
      if (_disposed || requestAsset != _currentAsset) return;
      _errorKey = e.messageKey ?? 'requestFailed';
    } catch (_) {
      if (_disposed || requestAsset != _currentAsset) return;
      _errorKey = 'requestFailed';
    } finally {
      if (!_disposed && requestAsset == _currentAsset) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _isLoading || !_hasMore || _nextCursor == null) {
      return;
    }

    final requestAsset = _currentAsset;
    final requestCursor = _nextCursor;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _service.fetchHistory(
        after: requestCursor,
        asset: requestAsset,
      );
      if (_disposed || requestAsset != _currentAsset) return;
      _allTransactions.addAll(result.transactions);
      _nextCursor = result.nextCursor;
      _hasMore = result.hasMore;
    } on AppException catch (e) {
      if (_disposed || requestAsset != _currentAsset) return;
      _errorKey = e.messageKey ?? 'requestFailed';
    } catch (_) {
      if (_disposed || requestAsset != _currentAsset) return;
      _errorKey = 'requestFailed';
    } finally {
      if (!_disposed && requestAsset == _currentAsset) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    authProvider.removeListener(_onAuthChanged);
    _coinsPrices.removeListener(_onCoinsUpdated);
    super.dispose();
  }

  List<String> get uniqueCoinSymbols {
    final seen = <String>{};
    final allSymbols = <String>[];
    for (final c in _coinsPrices.coins) {
      if (seen.add(c.symbol.toUpperCase())) {
        allSymbols.add(c.symbol);
      }
    }
    return ['All', ...allSymbols];
  }
}
