import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../core/services/api_helper.dart';
import '../../../../core/utils/app_exception.dart';

class HistoryResult {
  const HistoryResult({
    required this.transactions,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<TransactionModel> transactions;
  final String? nextCursor;
  final bool hasMore;
}

class HistoryService {
  Future<HistoryResult> fetchHistory({
    int limit = 50,
    String? after,
    String? asset,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'asset': (asset == null || asset.trim().isEmpty) ? 'ALL' : asset,
      'type': (type == null || type.trim().isEmpty) ? 'ALL' : type,
    };
    if (after != null && after.isNotEmpty) {
      queryParams['after'] = after;
    }
    if (startDate != null) {
      queryParams['startDate'] = _formatYmd(startDate);
    }
    if (endDate != null) {
      queryParams['endDate'] = _formatYmd(endDate);
    }

    final response = await ApiHelper.get(
      Endpoints.history,
      queryParameters: queryParams,
    );

    final dynamic data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException(
        'Invalid history response',
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

    return HistoryResult(
      transactions: transactions,
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
  }

  Future<TransactionModel> fetchTransactionDetail(String id) async {
    if (id.isEmpty) {
      throw AppException(
        'Missing transaction id',
        messageKey: 'requestFailed',
      );
    }

    final response = await ApiHelper.get(Endpoints.historyDetail(id));
    final dynamic data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException(
        'Invalid transaction detail response',
        messageKey: 'requestFailed',
      );
    }

    return TransactionModel.fromJson(_normalize(data));
  }

  /// Formats a [DateTime] as `YYYY-MM-DD` in UTC for the history API's
  /// `startDate` / `endDate` query params.
  String _formatYmd(DateTime date) {
    final utc = date.toUtc();
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// The history API returns `assetSymbol` / `assetName` / `assetName_ar`
  /// while `TransactionModel` is wired to `coin_symbol` / `coinName` /
  /// `coinName_ar` for the home API. Normalize so the shared model parses
  /// both shapes. For the detail endpoint, also fold `amountDisplay` into
  /// `amount` so the model's display-formatted amount stays consistent
  /// between list and detail responses.
  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    final normalized = <String, dynamic>{
      ...raw,
      'coin_symbol': raw['coin_symbol'] ?? raw['assetSymbol'],
      'coinName': raw['coinName'] ?? raw['assetName'],
      'coinName_ar': raw['coinName_ar'] ?? raw['assetName_ar'],
    };
    final amountDisplay = raw['amountDisplay'];
    if (amountDisplay is String && amountDisplay.isNotEmpty) {
      normalized['amount'] = amountDisplay;
    }
    return normalized;
  }
}
