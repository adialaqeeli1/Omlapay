import '../../../../core/constants/endpoints.dart';
import '../../../../core/services/api_helper.dart';
import '../../../../core/utils/app_exception.dart';

/// API calls for the swap flow: quote fetching.
class SwapService {
  SwapService._();

  /// Fetches a swap quote for converting between two coins.
  ///
  /// Currently the API always returns an error, so we only handle
  /// the error path. Success handling will be added later.
  ///
  /// Throws [AppException] when the backend rejects the request or
  /// the response payload is missing the `data` object.
  static Future<void> fetchSwapQuote({
    required String fromCoin,
    required String toCoin,
    required String amount,
  }) async {
    final response = await ApiHelper.get(
      Endpoints.swapQuote,
      queryParameters: <String, dynamic>{
        'fromCoin': fromCoin,
        'toCoin': toCoin,
        'amount': amount,
      },
    );

    final data = response['data'];
    if (data is! Map<String, dynamic> || data.isEmpty) {
      throw AppException(
        'Invalid swap quote response',
        messageKey: 'requestFailed',
      );
    }

    // TODO: Parse and return swap quote model when success data is available.
  }
}
