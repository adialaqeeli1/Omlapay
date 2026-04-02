import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/constants.dart';
import '../constants/endpoints.dart';
import '../network/network_client.dart';
import '../utils/app_exception.dart';
import 'storage_helper.dart';

class ApiHelper {
  static String? get _token => StorageService.getString(AppConstants.tokenKey);
  static bool get _isArabicLocale =>
      StorageService.getString(AppConstants.localeKey) == 'ar';

  static NetworkClient _getClient() {
    return NetworkClient(
      baseUrl: Endpoints.baseUrl,
      token: _token != null ? NetworkToken(access: _token) : null,
    );
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final client = _getClient();
      final response = await client.get(
        url: endpoint,
        queryParameters: queryParameters,
      );
      return _handleNetworkResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } on SocketException {
      throw AppException('Network error', messageKey: 'networkError');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error: $e', messageKey: 'unknownError');
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final client = _getClient();
      final response = await client.post(url: endpoint, data: body);
      return _handleNetworkResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } on SocketException {
      throw AppException('Network error', messageKey: 'networkError');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error: $e', messageKey: 'unknownError');
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final client = _getClient();
      final response = await client.put(url: endpoint, data: body);
      return _handleNetworkResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } on SocketException {
      throw AppException('Network error', messageKey: 'networkError');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error: $e', messageKey: 'unknownError');
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final client = _getClient();
      final response = await client.delete(url: endpoint);
      return _handleNetworkResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } on SocketException {
      throw AppException('Network error', messageKey: 'networkError');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error: $e', messageKey: 'unknownError');
    }
  }

  static Map<String, dynamic> _handleNetworkResponse(
    NetworkDataRespone response,
  ) {
    if (response.isSuccess) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return _normalizeLocalizedMessages(data);
      }
      return {};
    } else {
      final error = response.error;
      String message = _extractApiMessage(error) ??
          'Request failed with status ${response.statusCode}';
      throw AppException(message, messageKey: 'requestFailed');
    }
  }

  static AppException _handleDioException(DioException error) {
    String message = 'Network error: ${error.message}';
    String messageKey = 'unknownError';

    if (error.response?.data != null) {
      final data = error.response?.data;
      final extractedMessage = _extractApiMessage(data);
      if (extractedMessage != null && extractedMessage.trim().isNotEmpty) {
        message = extractedMessage;
      }
      messageKey = 'requestFailed';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      message = 'Network connection error';
      messageKey = 'networkError';
    }

    return AppException(message, messageKey: messageKey);
  }

  static String? _extractApiMessage(dynamic data) {
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    if (data is! Map<String, dynamic>) {
      return null;
    }

    final String preferredMessageKey = _isArabicLocale ? 'message_ar' : 'message';
    final String fallbackMessageKey = _isArabicLocale ? 'message' : 'message_ar';

    final dynamic preferredMessage = data[preferredMessageKey];
    final String? normalizedPreferred = _normalizeApiMessage(preferredMessage);
    if (normalizedPreferred != null) {
      return normalizedPreferred;
    }

    final dynamic fallbackMessage = data[fallbackMessageKey];
    final String? normalizedFallback = _normalizeApiMessage(fallbackMessage);
    if (normalizedFallback != null) {
      return normalizedFallback;
    }

    return _normalizeApiMessage(data['error']);
  }

  static String? _normalizeApiMessage(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (value is List) {
      final String joined = value
          .map((e) => e?.toString().trim() ?? '')
          .where((element) => element.isNotEmpty)
          .join('\n');
      return joined.isEmpty ? null : joined;
    }

    final String asString = value.toString().trim();
    return asString.isEmpty ? null : asString;
  }

  /// Normalizes API `message`/`message_ar` keys for consistent localized usage.
  ///
  /// - Preserves original values in `message_en` / `message_ar` when available.
  /// - Exposes selected locale text in `localized_message`.
  /// - Rewrites `message` to the selected locale to keep legacy callers working.
  /// - Applies to top-level payload and common nested `data` map.
  static Map<String, dynamic> _normalizeLocalizedMessages(
    Map<String, dynamic> payload,
  ) {
    _normalizeMessageFieldsOnMap(payload);

    final nestedData = payload['data'];
    if (nestedData is Map<String, dynamic>) {
      _normalizeMessageFieldsOnMap(nestedData);
    }

    return payload;
  }

  static void _normalizeMessageFieldsOnMap(Map<String, dynamic> map) {
    final originalMessage = _normalizeApiMessage(map['message']);
    final originalMessageAr = _normalizeApiMessage(map['message_ar']);

    // Keep a stable English slot where available.
    if (originalMessage != null) {
      map['message_en'] = originalMessage;
    }
    if (originalMessageAr != null) {
      map['message_ar'] = originalMessageAr;
    }

    final preferred = _isArabicLocale ? originalMessageAr : originalMessage;
    final fallback = _isArabicLocale ? originalMessage : originalMessageAr;
    final localized = preferred ?? fallback;

    if (localized != null) {
      map['localized_message'] = localized;
      map['message'] = localized;
    }
  }
}
