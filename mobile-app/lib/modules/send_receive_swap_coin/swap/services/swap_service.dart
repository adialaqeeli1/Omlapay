import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/swap_quote_model/swap_quote_model.dart';
import '../../../../core/services/api_helper.dart';
import '../../../../core/utils/app_exception.dart';

/// API calls for the swap flow: quote fetching and execution.
class SwapService {
  SwapService._();

  /// Fetches a swap quote for converting between two coins.
  ///
  /// Throws [AppException] when the backend rejects the request or
  /// the response payload is missing the `data` object.
  static Future<SwapQuoteModel> fetchSwapQuote({
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

    return SwapQuoteModel.fromJson(data);
  }

  /// Executes a swap between two coins. The numeric [amount] is sent as a
  /// JSON number to match the backend contract.
  static Future<void> executeSwap({
    required String fromCoin,
    required String toCoin,
    required String amount,
  }) async {
    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null) {
      throw AppException(
        'Invalid swap amount',
        messageKey: 'requestFailed',
      );
    }

    await ApiHelper.post(Endpoints.swapExecute, <String, dynamic>{
      'fromCoin': fromCoin,
      'toCoin': toCoin,
      'amount': parsedAmount,
    });
  }
}
