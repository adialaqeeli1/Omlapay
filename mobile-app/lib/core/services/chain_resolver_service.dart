import 'package:omlapay_mobile_app/core/utils/app_logger.dart';

import 'package:dio/dio.dart';

/// Resolves the blockchain network (chain) for a raw wallet address using
/// blockchain.com's public explorer search.
///
/// This is a best-effort hint used only for QR codes / pasted values that
/// carry a bare address with no embedded coin symbol. Knowing the chain lets
/// the app validate the address against the backend's coin-aware
/// `validate-address` endpoint (which requires a `coin`). The result may not be
/// 100% accurate and callers must treat a `null` return as "unknown".
///
/// Intentionally uses a standalone [Dio] instance with no app interceptors or
/// auth token — this is a third-party request and must not carry the user's
/// session credentials.
class ChainResolverService {
  ChainResolverService._();

  static const String _searchUrl =
      'https://www.blockchain.com/explorer/search';

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      responseType: ResponseType.json,
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  /// Caches successful resolutions (address → chain) so a value resolved while
  /// validating a scanned QR can be reused immediately afterwards (e.g. to
  /// auto-select the matching coin) without a second network round-trip.
  /// Failures are not cached, so a transient error still gets a retry. Capped
  /// to keep memory bounded; the oldest entry is evicted when full.
  static final Map<String, String> _cache = {};
  static const int _maxCacheEntries = 32;

  /// Returns the uppercase chain symbol (e.g. `SOL`, `ETH`, `BTC`) for
  /// [address], or `null` when it can't be determined or the lookup fails.
  ///
  /// Response shape (array; first matching `address` entry wins):
  /// ```json
  /// [{"chain": "SOL", "type": "address", "search": "RN9em..."}]
  /// ```
  static Future<String?> resolveChain(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return null;

    final cached = _cache[trimmed];
    if (cached != null) return cached;

    try {
      final response = await _dio.post(
        _searchUrl,
        data: {'search': trimmed},
      );

      final data = response.data;
      if (data is List) {
        for (final entry in data) {
          if (entry is Map &&
              entry['type']?.toString().toLowerCase() == 'address') {
            final chain = entry['chain']?.toString().trim();
            if (chain != null && chain.isNotEmpty) {
              final resolved = chain.toUpperCase();
              if (_cache.length >= _maxCacheEntries) {
                _cache.remove(_cache.keys.first);
              }
              _cache[trimmed] = resolved;
              return resolved;
            }
          }
        }
      }
      return null;
    } catch (e, stackTrace) {
      appLog(
        'chain resolve failed for "$trimmed": $e',
        name: 'ChainResolverService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
