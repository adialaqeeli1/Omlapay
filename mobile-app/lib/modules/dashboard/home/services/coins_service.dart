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
      throw AppException('Invalid coins response', messageKey: 'requestFailed');
    }

    final dynamic coins = data['coins'];
    if (coins is! List) {
      throw AppException('Invalid coins list', messageKey: 'requestFailed');
    }

    final quoteCurrency = _currencyMapFromPayload(data);

    return coins
        .whereType<Map<String, dynamic>>()
        .where(_isCoinActive)
        .map((c) => _toCoinModel(c, currency: quoteCurrency))
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

  /// Exposed for [CoinsPricesStreamService] to parse SSE payloads.
  bool isCoinActive(Map<String, dynamic> coin) => _isCoinActive(coin);

  Map<String, dynamic>? _currencyMapFromPayload(Map<String, dynamic> data) {
    final c = data['currency'];
    return c is Map<String, dynamic> ? c : null;
  }

  String? _optionalTrimmed(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  CoinModel _toCoinModel(
    Map<String, dynamic> coin, {
    Map<String, dynamic>? currency,
  }) {
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
    final double parsedChange24h = _parseChange24h(coin);
    final displayPrice = parsedPrice == null
        ? '--'
        : _formatPrice(parsedPrice, chainDecimals: chainDecimals);

    final quoteSymbol =
        _optionalTrimmed(currency?['symbol']) ??
        _optionalTrimmed(coin['quote_symbol']);
    // Fiat quote Arabic label: only from nested `currency` (not coin `symbol_ar`).
    final quoteSymbolAr = _optionalTrimmed(currency?['symbol_ar']);
    // Coin-level Arabic ticker (`symbol_ar`); never used for fiat.
    final coinSymbolAr = _optionalTrimmed(coin['symbol_ar']);
    // Coin-level Arabic full name (`name_ar`); optional until API ships it.
    final coinNameAr = _optionalTrimmed(coin['name_ar']);

    return CoinModel(
      id: _optionalTrimmed(coin['id']),
      name: name,
      symbol: symbol.isEmpty ? 'N/A' : symbol,
      amount: '0.00',
      valueInUsd: displayPrice,
      change24h: parsedChange24h,
      decimals: chainDecimals,
      network: _optionalTrimmed(coin['network']),
      iconUrl: _optionalTrimmed(coin['iconUrl']),
      networkIconUrl: _optionalTrimmed(coin['networkIconUrl']),
      contractAddress: _optionalTrimmed(coin['contractAddress']),
      minWithdrawal: _optionalTrimmed(coin['minWithdrawal']),
      minDeposit: _optionalTrimmed(coin['minDeposit']),
      withdrawalFee: _optionalTrimmed(coin['withdrawalFee']),
      description: _optionalTrimmed(coin['description']),
      price: parsedPrice?.toDouble(),
      quoteSymbol: quoteSymbol,
      quoteSymbolAr: quoteSymbolAr,
      coinSymbolAr: coinSymbolAr,
      coinNameAr: coinNameAr,
    );
  }

  /// Exposed for [CoinsPricesStreamService] to map API payload to [CoinModel].
  CoinModel toCoinModel(
    Map<String, dynamic> coin, {
    Map<String, dynamic>? currency,
  }) => _toCoinModel(coin, currency: currency);

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

    return _trimTrailingZeros(formatted);
  }

  String _trimTrailingZeros(String value) {
    if (!value.contains('.')) return value;

    var result = value;
    while (result.endsWith('0')) {
      result = result.substring(0, result.length - 1);
    }
    if (result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  double _parseChange24h(Map<String, dynamic> coin) {
    final dynamic rawChange =
        coin['change24h'] ?? coin['change24H'] ?? coin['change_24h'];
    return switch (rawChange) {
      final num value => value.toDouble(),
      final String value => double.tryParse(value.trim()) ?? 0,
      _ => 0,
    };
  }
}
