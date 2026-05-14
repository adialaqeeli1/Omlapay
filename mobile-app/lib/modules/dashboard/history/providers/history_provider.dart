import 'dart:developer' as developer;
import 'package:flutter/material.dart';

import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../providers/coins_prices_provider.dart';
import '../services/history_service.dart';

/// Server-accepted values for the `type` query parameter on `/v1/history`.
class HistoryTxType {
  static const String all = 'ALL';
  static const String sent = 'SENT';
  static const String received = 'RECEIVE';
  static const String swap = 'SWAP';
}

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(
    this._coinsPrices, {
    HistoryService? service,
    String? initialCoinFilter,
    String? initialTypeFilter,
  }) : _service = service ?? HistoryService(),
       _selectedCoinFilter =
           (initialCoinFilter == null || initialCoinFilter.trim().isEmpty)
           ? null
           : initialCoinFilter.trim().toUpperCase(),
       _selectedTypeFilter = initialTypeFilter {
    _coinsPrices.addListener(_onStreamedCoinsUpdated);
    fetchTransactions();
  }

  final CoinsPricesProvider _coinsPrices;
  final HistoryService _service;

  /// Sentinel for the "All coins" tab — internal value only, never displayed.
  static const String allCoinsTab = 'All';

  String?
  _selectedCoinFilter; // null = All, or coin symbol like 'USDT', 'BTC', etc.
  String? _selectedTypeFilter; // null = All, or 'SENT', 'RECEIVE', 'SWAP'.
  DateTime? _dateStart;
  DateTime? _dateEnd;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _nextCursor;
  String? _errorMessage;
  bool _disposed = false;

  String? get selectedCoinFilter => _selectedCoinFilter;
  String? get selectedTypeFilter => _selectedTypeFilter;
  DateTime? get dateStart => _dateStart;
  DateTime? get dateEnd => _dateEnd;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  /// Tab list for the coin filter: the `'All'` sentinel followed by each
  /// distinct coin symbol from the SSE stream. `'All'` is an internal
  /// sentinel, not a display string — the view localizes the label and
  /// converts it back to `null` before calling [setCoinFilter].
  List<String> get uniqueCoinSymbols {
    final seen = <String>{};
    final allSymbols = <String>[];
    for (final c in _coinsPrices.coins) {
      if (seen.add(c.symbol.toUpperCase())) {
        allSymbols.add(c.symbol.toUpperCase());
      }
    }
    return [allCoinsTab, ...allSymbols];
  }

  void _onStreamedCoinsUpdated() {
    final before = _selectedCoinFilter;
    _reconcileCoinFilterWithStream();
    if (before != _selectedCoinFilter) {
      fetchTransactions();
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

  /// Snapshot of the filters used on the current/in-flight request — used to
  /// detect stale responses when filters change mid-fetch.
  ({String? asset, String? type, DateTime? start, DateTime? end})
  get _filterSnapshot => (
    asset: _selectedCoinFilter,
    type: _selectedTypeFilter,
    start: _dateStart,
    end: _dateEnd,
  );

  bool _snapshotMatches(
    ({String? asset, String? type, DateTime? start, DateTime? end}) snap,
  ) {
    return snap.asset == _selectedCoinFilter &&
        snap.type == _selectedTypeFilter &&
        snap.start == _dateStart &&
        snap.end == _dateEnd;
  }

  Future<void> fetchTransactions() async {
    final snap = _filterSnapshot;
    _isLoading = true;
    _errorMessage = null;
    _transactions = [];
    _nextCursor = null;
    _hasMore = false;
    notifyListeners();

    try {
      final result = await _service.fetchHistory(
        asset: snap.asset,
        type: snap.type,
        startDate: snap.start,
        endDate: snap.end,
      );
      if (_disposed || !_snapshotMatches(snap)) return;
      _transactions = result.transactions;
      _nextCursor = result.nextCursor;
      _hasMore = result.hasMore;
    } on AppException catch (e) {
      if (_disposed || !_snapshotMatches(snap)) return;
      _errorMessage = e.messageKey ?? 'requestFailed';
    } catch (_) {
      if (_disposed || !_snapshotMatches(snap)) return;
      _errorMessage = 'requestFailed';
    } finally {
      if (!_disposed && _snapshotMatches(snap)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _isLoading || !_hasMore || _nextCursor == null) {
      return;
    }

    final snap = _filterSnapshot;
    final requestCursor = _nextCursor;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _service.fetchHistory(
        after: requestCursor,
        asset: snap.asset,
        type: snap.type,
        startDate: snap.start,
        endDate: snap.end,
      );
      if (_disposed || !_snapshotMatches(snap)) return;
      _transactions = [..._transactions, ...result.transactions];
      _nextCursor = result.nextCursor;
      _hasMore = result.hasMore;
    } on AppException catch (e) {
      if (_disposed || !_snapshotMatches(snap)) return;
      _errorMessage = e.messageKey ?? 'requestFailed';
    } catch (_) {
      if (_disposed || !_snapshotMatches(snap)) return;
      _errorMessage = 'requestFailed';
    } finally {
      if (!_disposed && _snapshotMatches(snap)) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> refresh() async {
    await fetchTransactions();
  }

  void setCoinFilter(String? coinSymbol) {
    final normalized = (coinSymbol == null || coinSymbol.trim().isEmpty)
        ? null
        : coinSymbol;
    if (normalized == _selectedCoinFilter) return;
    developer.log('HistoryProvider: Setting coin filter to: $normalized');
    _selectedCoinFilter = normalized;
    fetchTransactions();
  }

  void setTypeFilter(String? type) {
    if (type == _selectedTypeFilter) return;
    developer.log('HistoryProvider: Setting type filter to: $type');
    _selectedTypeFilter = type;
    fetchTransactions();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    if (start == _dateStart && end == _dateEnd) return;
    developer.log('HistoryProvider: Setting date range: $start - $end');
    _dateStart = start;
    _dateEnd = end;
    fetchTransactions();
  }

  void clearFilter() {
    developer.log('HistoryProvider: Clearing filter');
    final changed = _selectedCoinFilter != null ||
        _selectedTypeFilter != null ||
        _dateStart != null ||
        _dateEnd != null;
    _selectedCoinFilter = null;
    _selectedTypeFilter = null;
    _dateStart = null;
    _dateEnd = null;
    if (changed) {
      fetchTransactions();
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _coinsPrices.removeListener(_onStreamedCoinsUpdated);
    super.dispose();
  }
}
