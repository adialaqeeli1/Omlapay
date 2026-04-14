import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/send_confirm_model/send_confirm_response_model.dart';
import '../../../../core/models/send_initiate_model/send_initiate_response_model.dart';
import '../../../../core/models/send_initiate_model/send_resend_otp_response_model.dart';
import '../../../../core/models/send_quote_model/send_quote_model.dart';
import '../../../../core/services/api_helper.dart';
import '../../../../core/utils/app_exception.dart';

/// API calls for the send flow: recipient validation, quoting, and
/// OTP-protected transfer submission.
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

  /// Initiates a send transfer. The backend sends an OTP to the user's
  /// registered phone number and returns a `sendToken` used by [confirmSend].
  ///
  /// The record exposes the backend-localized top-level `message` so callers
  /// can show it as a success toast via [SnackbarHelper.showSuccess].
  static Future<({SendInitiateResponseModel data, String? message})>
      initiateSend({
    required String coin,
    required String recipient,
    required double amount,
    required String network,
  }) async {
    final response = await ApiHelper.post(Endpoints.sendInitiate, {
      'coin': coin,
      'recipient': recipient,
      'amount': amount,
      'network': network,
    });

    final data = response['data'];
    if (data is! Map<String, dynamic> || data.isEmpty) {
      throw AppException(
        'Invalid initiate response',
        messageKey: 'requestFailed',
      );
    }

    try {
      return (
        data: SendInitiateResponseModel.fromJson(data),
        message: _extractMessage(response),
      );
    } catch (_) {
      throw AppException(
        'Invalid initiate response',
        messageKey: 'requestFailed',
      );
    }
  }

  /// Requests a fresh OTP for an in-progress send flow identified by
  /// [sendToken]. Returns the new token, remaining resend attempts, and the
  /// backend-localized success message.
  static Future<({SendResendOtpResponseModel data, String? message})> resendOtp(
      {required String sendToken}) async {
    final response = await ApiHelper.post(Endpoints.sendResendOtp, {
      'sendToken': sendToken,
    });

    final data = response['data'];
    if (data is! Map<String, dynamic> || data.isEmpty) {
      throw AppException(
        'Invalid resend-otp response',
        messageKey: 'requestFailed',
      );
    }

    try {
      return (
        data: SendResendOtpResponseModel.fromJson(data),
        message: _extractMessage(response),
      );
    } catch (_) {
      throw AppException(
        'Invalid resend-otp response',
        messageKey: 'requestFailed',
      );
    }
  }

  /// Confirms a pending send by submitting the OTP received on the user's
  /// phone. On success the record contains the queued transaction details
  /// plus the backend-localized success message for a toast.
  static Future<({SendConfirmResponseModel data, String? message})>
      confirmSend({
    required String sendToken,
    required String otp,
  }) async {
    final response = await ApiHelper.post(Endpoints.sendConfirm, {
      'sendToken': sendToken,
      'otp': otp,
    });

    final data = response['data'];
    if (data is! Map<String, dynamic> || data.isEmpty) {
      throw AppException(
        'Invalid confirm response',
        messageKey: 'requestFailed',
      );
    }

    try {
      return (
        data: SendConfirmResponseModel.fromJson(data),
        message: _extractMessage(response),
      );
    } catch (_) {
      throw AppException(
        'Invalid confirm response',
        messageKey: 'requestFailed',
      );
    }
  }

  /// Pulls the backend-localized message from a normalized response payload.
  /// [ApiHelper] already picks the locale-appropriate string during parsing.
  static String? _extractMessage(Map<String, dynamic> response) {
    final raw = response['message'] ?? response['localized_message'];
    if (raw is String && raw.trim().isNotEmpty) return raw;
    return null;
  }
}
