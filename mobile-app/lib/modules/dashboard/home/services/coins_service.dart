import 'package:intl/intl.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/services/api_helper.dart';
import '../../../../core/utils/app_exception.dart';

class CoinsService {
  static final RegExp _currencyRegex = RegExp(r'^[a-z]{3}$');
  static const Duration _syncCooldown = Duration(seconds: 10);

  Set<String> _activeSymbols = <String>{};
  DateTime? _lastSyncAt;

  Future<List<CoinModel>> fetchCoins({
    required String currency,
    bool forceSync = false,
  }) async {
    final normalizedCurrency = currency.trim().toLowerCase();
    if (!_currencyRegex.hasMatch(normalizedCurrency)) {
      throw AppException(
        'Invalid currency selected',
        messageKey: 'requestFailed',
      );
    }

    await _syncCoinsIfNeeded(forceSync: forceSync);

    final response = await ApiHelper.get(
      '${Endpoints.coins}?currency=$normalizedCurrency',
    );

    final dynamic data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException(
        'Invalid coins response',
        messageKey: 'requestFailed',
      );
    }

    final dynamic coins = data['coins'];
    if (coins is! List) {
      throw AppException(
        'Invalid coins list',
        messageKey: 'requestFailed',
      );
    }

    return coins
        .whereType<Map<String, dynamic>>()
        .where(_isCoinActive)
        .map(_toCoinModel)
        .toList(growable: false);
  }

  Future<void> _syncCoinsIfNeeded({required bool forceSync}) async {
    final now = DateTime.now();
    final shouldSync =
        forceSync ||
        _activeSymbols.isEmpty ||
        _lastSyncAt == null ||
        now.difference(_lastSyncAt!) >= _syncCooldown;
    if (!shouldSync) return;

    try {
      final response = await ApiHelper.post(Endpoints.coinsSync, {});
      final dynamic data = response['data'];
      if (data is! Map<String, dynamic>) {
        _lastSyncAt = now;
        return;
      }

      final symbols = <String>{};
      _collectActiveSymbols(data['created'], symbols);
      _collectActiveSymbols(data['updated'], symbols);

      if (symbols.isNotEmpty) {
        _activeSymbols = symbols;
      }
      _lastSyncAt = now;
    } catch (_) {
      // Keep current cache on sync failure.
    }
  }

  void _collectActiveSymbols(dynamic payload, Set<String> sink) {
    if (payload is! List) return;
    for (final entry in payload.whereType<Map<String, dynamic>>()) {
      final isActive = entry['isActive'] == true;
      final symbol = (entry['symbol'] as String? ?? '').trim().toUpperCase();
      if (isActive && symbol.isNotEmpty) {
        sink.add(symbol);
      }
    }
  }

  bool _isCoinActive(Map<String, dynamic> coin) {
    final symbol = (coin['symbol'] as String? ?? '').trim().toUpperCase();
    if (symbol.isEmpty) return false;

    final fromCoinPayload = coin['isActive'];
    if (fromCoinPayload is bool) return fromCoinPayload;
    if (_activeSymbols.isEmpty) return true;
    return _activeSymbols.contains(symbol);
  }

  CoinModel _toCoinModel(Map<String, dynamic> coin) {
    final symbol = (coin['symbol'] as String? ?? '').trim().toUpperCase();
    final name = (coin['name'] as String? ?? '').trim();
    final rawDecimals = coin['decimals'];
    final int chainDecimals = switch (rawDecimals) {
      final int value => value,
      final num value => value.toInt(),
      final String value => int.tryParse(value) ?? 2,
      _ => 2,
    };
    final dynamic rawPrice = coin['price'];
    final num? parsedPrice = switch (rawPrice) {
      final num value => value,
      final String value => num.tryParse(value),
      _ => null,
    };
    final displayPrice = parsedPrice == null
        ? '--'
        : _formatPrice(parsedPrice, chainDecimals: chainDecimals);

    return CoinModel(
      name: name.isEmpty ? symbol : name,
      symbol: symbol.isEmpty ? 'N/A' : symbol,
      amount: '--',
      valueInUsd: displayPrice,
    );
  }

  String _formatPrice(num price, {required int chainDecimals}) {
    final safeChainDecimals = chainDecimals.clamp(0, 8);
    int decimalDigits;

    if (price == 0) {
      decimalDigits = 0;
    } else if (price >= 1) {
      decimalDigits = safeChainDecimals >= 2 ? 2 : safeChainDecimals;
    } else {
      final candidate = safeChainDecimals == 0 ? 6 : safeChainDecimals;
      decimalDigits = candidate.clamp(2, 8);
    }

    final pattern = decimalDigits == 0
        ? '#,##0'
        : '#,##0.${'0' * decimalDigits}';
    final formatter = NumberFormat(pattern, 'en_US');
    final formatted = formatter.format(price.toDouble());
    if (decimalDigits == 0) return formatted;

    return formatted
        .replaceFirst(RegExp(r'([.,]\d*?[1-9])0+$'), r'$1')
        .replaceFirst(RegExp(r'[.,]0+$'), '');
  }
}
