import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sse_channel/sse_channel.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/services/storage_helper.dart';
import 'coins_service.dart';

const String _logTag = 'CoinsPricesStream';

/// Service that connects to the SSE prices stream and parses coin price updates.
/// Uses [sse_channel] for spec-aligned SSE handling with automatic reconnection.
/// The server URL is built **without** query parameters so that [SseChannel]'s
/// internal `?sseClientId=…` append works correctly; the `currency` parameter
/// is then added with `&`.
class CoinsPricesStreamService {
  CoinsPricesStreamService(this._coinsService);

  final CoinsService _coinsService;

  static final RegExp _currencyRegex = RegExp(r'^[a-z]{3}$');

  void _log(String message, [Object? detail]) {
    if (kDebugMode) {
      debugPrint('$_logTag: $message${detail != null ? ' | $detail' : ''}');
    }
  }

  /// Connects to the SSE stream and yields [CoinModel] lists on each price update.
  /// Caller must cancel the subscription on dispose.
  Stream<List<CoinModel>> streamCoinPrices(String currency) async* {
    final normalizedCurrency = currency.trim().toLowerCase();
    if (!_currencyRegex.hasMatch(normalizedCurrency)) {
      _log('Invalid currency, skipping stream', currency);
      return;
    }

    final token = StorageService.getString(AppConstants.tokenKey);
    final client = _CurrencyAwareHttpClient(
      token: token,
      currency: normalizedCurrency,
    );

    // Pass the base URL **without** query params so that SseChannel's
    // internal `?sseClientId=…` append uses the first `?` correctly.
    // Our custom HTTP client intercepts the request and appends
    // `&currency=<code>` after the `?sseClientId=…` that SseChannel adds.
    final baseUrl =
        '${Endpoints.baseUrl}${Endpoints.coinsPricesStream}';
    _log('Connecting to SSE stream', '$baseUrl (currency=$normalizedCurrency)');

    final channel = SseChannel.connect(Uri.parse(baseUrl), client: client);

    try {
      await channel.ready;
      _log('SSE connection established');
    } catch (e, stackTrace) {
      _log('SSE connection failed', e);
      if (kDebugMode) {
        debugPrint('$_logTag: Stack trace: $stackTrace');
      }
      client.close();
      rethrow;
    }

    bool firstDataLogged = false;
    try {
      await for (final event in channel.stream) {
        final data = event.data;
        if (data == null || data.isEmpty) {
          _log('Received empty event', 'event=${event.event} id=${event.id}');
          continue;
        }

        try {
          final json = jsonDecode(data);
          if (json is! Map<String, dynamic>) {
            _log('Event data is not a JSON object', 'type=${json.runtimeType}');
            continue;
          }

          final coins = _extractCoinsFromPayload(json);
          if (coins != null && coins.isNotEmpty) {
            if (!firstDataLogged && kDebugMode) {
              firstDataLogged = true;
              final preview =
                  data.length > 200 ? '${data.substring(0, 200)}...' : data;
              _log(
                'First event received | event=${event.event} id=${event.id} '
                'dataLength=${data.length} preview=$preview',
              );
              _log('Parsed ${coins.length} coins',
                  coins.map((c) => c.symbol).join(', '));
            }
            yield coins;
          } else {
            _log('No coins extracted from payload');
          }
        } catch (e) {
          _log('Failed to parse event data', e);
        }
      }
      _log('SSE stream ended normally');
    } finally {
      _log('Closing SSE channel and client');
      channel.close();
      client.close();
    }
  }

  List<CoinModel>? _extractCoinsFromPayload(Map<String, dynamic> json) {
    final dynamic raw = json['data'];
    final Map<String, dynamic> dataMap =
        raw is Map<String, dynamic> ? raw : json;
    final quoteCurrency = _currencyMapFromData(dataMap);

    final coins = dataMap['coins'];
    if (coins is! List) return null;

    final result = <CoinModel>[];
    for (final item in coins.whereType<Map<String, dynamic>>()) {
      if (!_coinsService.isCoinActive(item)) continue;
      try {
        result.add(_coinsService.toCoinModel(item, currency: quoteCurrency));
      } catch (_) {
        // Skip invalid entries
      }
    }
    return result.isEmpty ? null : result;
  }

  Map<String, dynamic>? _currencyMapFromData(Map<String, dynamic> data) {
    final c = data['currency'];
    return c is Map<String, dynamic> ? c : null;
  }
}

/// Custom [http.BaseClient] that:
/// 1. Adds Authorization and SSE headers.
/// 2. Appends `&currency=<code>` to the outgoing URL so that [SseChannel]'s
///    own `?sseClientId=…` stays valid and the server receives both params.
class _CurrencyAwareHttpClient extends http.BaseClient {
  _CurrencyAwareHttpClient({
    required String? token,
    required String currency,
  })  : _token = token,
        _currency = currency,
        _inner = http.Client();

  final String? _token;
  final String _currency;
  final http.Client _inner;

  @override
  void close() => _inner.close();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Append currency to the existing query parameters that SseChannel built.
    final originalUri = request.url;
    final updatedParams = Map<String, String>.from(originalUri.queryParameters)
      ..['currency'] = _currency;
    final correctedUri = originalUri.replace(queryParameters: updatedParams);

    // Build a new request with the corrected URL.
    final correctedRequest = http.Request(request.method, correctedUri)
      ..headers.addAll(request.headers);

    correctedRequest.headers['Accept'] = 'text/event-stream';
    correctedRequest.headers['Cache-Control'] = 'no-cache';
    final token = _token;
    if (token != null) {
      correctedRequest.headers['Authorization'] = token;
    }

    if (kDebugMode) {
      final headers = Map<String, String>.from(correctedRequest.headers);
      if (headers.containsKey('Authorization')) {
        headers['Authorization'] = '[present]';
      }
      debugPrint(
        '$_logTag: Sending request | method=${correctedRequest.method} '
        'url=${correctedRequest.url} headers=$headers',
      );
    }
    return _inner.send(correctedRequest);
  }
}
