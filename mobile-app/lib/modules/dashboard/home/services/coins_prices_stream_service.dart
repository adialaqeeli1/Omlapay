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
    final client = _AuthHttpClient(token);

    final url =
        '${Endpoints.baseUrl}${Endpoints.coinsPricesStream}?currency=$normalizedCurrency';
    _log('Connecting to SSE stream', url);

    final channel = SseChannel.connect(Uri.parse(url), client: client);

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

    try {
      await for (final event in channel.stream) {
        final data = event.data;
        if (data == null || data.isEmpty) {
          _log('Received empty event', 'event=${event.event} id=${event.id}');
          continue;
        }

        if (kDebugMode) {
          final preview =
              data.length > 200 ? '${data.substring(0, 200)}...' : data;
          debugPrint(
            '$_logTag: Event received | event=${event.event} id=${event.id} '
            'dataLength=${data.length} preview=$preview',
          );
        }

        try {
          final json = jsonDecode(data);
          if (json is! Map<String, dynamic>) {
            _log('Event data is not a JSON object', 'type=${json.runtimeType}');
            continue;
          }

          final coins = _extractCoinsFromPayload(json);
          if (coins != null && coins.isNotEmpty) {
            _log('Parsed ${coins.length} coins', coins.map((c) => c.symbol).join(', '));
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
    dynamic data = json['data'];
    if (data is! Map<String, dynamic>) {
      data = json;
    }

    final coins = data['coins'];
    if (coins is! List) return null;

    final result = <CoinModel>[];
    for (final item in coins.whereType<Map<String, dynamic>>()) {
      if (!_coinsService.isCoinActive(item)) continue;
      try {
        result.add(_coinsService.toCoinModel(item));
      } catch (_) {
        // Skip invalid entries
      }
    }
    return result.isEmpty ? null : result;
  }
}

/// [http.BaseClient] that adds Authorization and Accept headers for SSE requests.
class _AuthHttpClient extends http.BaseClient {
  _AuthHttpClient(this._token) : _inner = http.Client();

  final String? _token;
  final http.Client _inner;

  @override
  void close() => _inner.close();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';
    final token = _token;
    if (token != null) {
      request.headers['Authorization'] = token;
    }
    if (kDebugMode) {
      final headers = Map<String, String>.from(request.headers);
      if (headers.containsKey('Authorization')) {
        headers['Authorization'] = '[present]';
      }
      debugPrint(
        '$_logTag: Sending request | method=${request.method} url=${request.url} '
        'headers=$headers',
      );
    }
    return _inner.send(request);
  }
}
