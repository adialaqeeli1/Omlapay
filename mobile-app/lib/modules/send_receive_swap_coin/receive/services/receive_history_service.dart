import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../core/services/api_helper.dart';
import '../../../../core/utils/app_exception.dart';

class ReceiveHistoryResult {
  const ReceiveHistoryResult({
    required this.transactions,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<TransactionModel> transactions;
  final String? nextCursor;
  final bool hasMore;
}

class ReceiveHistoryService {
  Future<ReceiveHistoryResult> fetchHistory({
    int limit = 20,
    String? after,
    String? asset,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (after != null && after.isNotEmpty) {
      queryParams['after'] = after;
    }
    if (asset != null && asset.isNotEmpty) {
      queryParams['asset'] = asset;
    }

    final response = await ApiHelper.get(
      Endpoints.receiveHistory,
      queryParameters: queryParams,
    );

    final dynamic data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException(
        'Invalid receive history response',
        messageKey: 'requestFailed',
      );
    }

    final dynamic txPayload = data['transactions'];
    if (txPayload is! List) {
      throw AppException(
        'Invalid transactions list',
        messageKey: 'requestFailed',
      );
    }

    final transactions = txPayload
        .whereType<Map<String, dynamic>>()
        .map((raw) => TransactionModel.fromJson(_normalize(raw)))
        .toList(growable: false);

    final pagination = data['pagination'];
    String? nextCursor;
    bool hasMore = false;
    if (pagination is Map<String, dynamic>) {
      final rawCursor = pagination['nextCursor'];
      nextCursor = rawCursor is String && rawCursor.isNotEmpty
          ? rawCursor
          : null;
      hasMore = pagination['hasMore'] == true;
    }

    return ReceiveHistoryResult(
      transactions: transactions,
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
  }

  /// The receive history API returns `assetSymbol` / `assetName` / `assetName_ar`
  /// while `TransactionModel` is wired to `coin_symbol` / `coinName` / `coinName_ar`
  /// for the home API. Normalize here so the shared model parses both shapes.
  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    return {
      ...raw,
      'coin_symbol': raw['coin_symbol'] ?? raw['assetSymbol'],
      'coinName': raw['coinName'] ?? raw['assetName'],
      'coinName_ar': raw['coinName_ar'] ?? raw['assetName_ar'],
    };
  }
}
