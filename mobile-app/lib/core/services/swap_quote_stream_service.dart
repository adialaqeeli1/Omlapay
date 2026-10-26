import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sse_channel/sse_channel.dart';

import '../constants/constants.dart';
import '../constants/endpoints.dart';
import '../models/swap_quote_stream_model/swap_quote_stream_event.dart';
import '../models/swap_quote_stream_model/swap_quote_stream_model.dart';
import 'storage_helper.dart';

const String _logTag = 'SwapQuoteStream';

/// Service that connects to the swap quote SSE stream and yields
/// [SwapQuoteStreamEvent]s. Uses the same "base URL without params + custom
/// http client injects params" pattern as [CoinsPricesStreamService] so
/// `SseChannel`'s internal `?sseClientId=...` append stays valid.
class SwapQuoteStreamService {
  SwapQuoteStreamService();

  void _log(String message, [Object? detail]) {
    if (kDebugMode) {
      debugPrint('$_logTag: $message${detail != null ? ' | $detail' : ''}');
    }
  }

  /// Opens a stream of quote events for the given swap inputs. The caller
  /// must cancel the subscription to close the connection.
  Stream<SwapQuoteStreamEvent> streamSwapQuote({
    required String fromCoin,
    required String toCoin,
    required String amount,
    required String currency,
  }) async* {
    final token = StorageService.getString(AppConstants.tokenKey);
    final client = _AuthedSwapQuoteHttpClient(
      token: token,
      fromCoin: fromCoin,
      toCoin: toCoin,
      amount: amount,
      currency: currency.trim().toLowerCase(),
    );

    final baseUrl = '${Endpoints.baseUrl}${Endpoints.swapQuoteStream}';
    _log(
      'Connecting',
      'from=$fromCoin to=$toCoin amount=$amount currency=$currency',
    );

    final channel = SseChannel.connect(Uri.parse(baseUrl), client: client);

    try {
      await channel.ready;
      _log('Connection established');
    } catch (e, stackTrace) {
      _log('Connection failed', e);
      if (kDebugMode) {
        debugPrint('$_logTag: Stack trace: $stackTrace');
      }
      client.close();
      rethrow;
    }

    try {
      await for (final event in channel.stream) {
        final data = event.data;
        if (data == null || data.isEmpty) continue;

        final parsed = _parseEvent(data);
        if (parsed != null) yield parsed;
      }
      _log('Stream ended normally');
    } finally {
      channel.close();
      client.close();
    }
  }

  SwapQuoteStreamEvent? _parseEvent(String data) {
    try {
      final json = jsonDecode(data);
      if (json is! Map<String, dynamic>) return null;

      final status = json['status'];
      if (status == 'ok') {
        return SwapQuoteStreamSuccess(SwapQuoteStreamModel.fromJson(json));
      }
      if (status == 'error') {
        final code = (json['code'] as String?) ?? '';
        final messageEn = (json['message'] as String?) ?? '';
        final messageAr =
            (json['messageAr'] as String?) ??
            (json['message_ar'] as String?) ??
            '';
        return SwapQuoteStreamFailure(
          code: code,
          messageEn: messageEn,
          messageAr: messageAr,
        );
      }
      _log('Unknown status', status);
      return null;
    } catch (e) {
      _log('Failed to parse event', e);
      return null;
    }
  }
}

/// HTTP client that:
/// 1. Adds Authorization and SSE headers.
/// 2. Appends `fromCoin`, `toCoin`, `amount`, `currency` to the outgoing URL
///    *after* `SseChannel` has already added its own `?sseClientId=...`.
class _AuthedSwapQuoteHttpClient extends http.BaseClient {
  _AuthedSwapQuoteHttpClient({
    required String? token,
    required String fromCoin,
    required String toCoin,
    required String amount,
    required String currency,
  }) : _token = token,
       _fromCoin = fromCoin,
       _toCoin = toCoin,
       _amount = amount,
       _currency = currency,
       _inner = http.Client();

  final String? _token;
  final String _fromCoin;
  final String _toCoin;
  final String _amount;
  final String _currency;
  final http.Client _inner;

  @override
  void close() => _inner.close();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final originalUri = request.url;
    final updatedParams = Map<String, String>.from(originalUri.queryParameters)
      ..['fromCoin'] = _fromCoin
      ..['toCoin'] = _toCoin
      ..['amount'] = _amount
      ..['currency'] = _currency;
    final correctedUri = originalUri.replace(queryParameters: updatedParams);

    final correctedRequest = http.Request(request.method, correctedUri)
      ..headers.addAll(request.headers);
    correctedRequest.headers['Accept'] = 'text/event-stream';
    correctedRequest.headers['Cache-Control'] = 'no-cache';
    final token = _token;
    if (token != null) {
      correctedRequest.headers['Authorization'] = 'Bearer $token';
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
