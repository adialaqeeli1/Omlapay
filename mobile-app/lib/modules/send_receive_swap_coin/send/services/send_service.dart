import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/send_quote_model/send_quote_model.dart';
import '../../../../core/services/api_helper.dart';
import '../../../../core/utils/app_exception.dart';

/// API calls for the send flow: recipient validation and fee/amount quoting.
class SendService {
  SendService._();

  /// Validates a recipient address/identifier for the given coin.
  ///
  /// Throws [AppException] when the backend rejects the request or the
  /// response payload is missing the `data` object.
  static Future<void> validateAddress({
    required String coin,
    required String address,
  }) async {
    final response = await ApiHelper.get(
      Endpoints.sendValidateAddress,
      queryParameters: <String, dynamic>{
        'address': address,
        'coin': coin,
      },
    );

    final data = response['data'];
    if (data is! Map<String, dynamic> || data.isEmpty) {
      throw AppException(
        'Address validation failed',
        messageKey: 'requestFailed',
      );
    }
  }

  /// Fetches an authoritative send quote (fee, amounts, recipient metadata).
  ///
  /// Throws [AppException] when the backend rejects the request or the
  /// response payload cannot be parsed as a [SendQuoteModel].
  static Future<SendQuoteModel> fetchQuote({
    required String coin,
    required String recipient,
    required String amount,
  }) async {
    final response = await ApiHelper.get(
      Endpoints.sendQuote,
      queryParameters: <String, dynamic>{
        'coin': coin,
        'recipient': recipient,
        'amount': amount,
      },
    );

    final data = response['data'];
    if (data is! Map<String, dynamic> || data.isEmpty) {
      throw AppException(
        'Invalid quote response',
        messageKey: 'requestFailed',
      );
    }

    try {
      return SendQuoteModel.fromJson(data);
    } catch (_) {
      throw AppException(
        'Invalid quote response',
        messageKey: 'requestFailed',
      );
    }
  }
}
