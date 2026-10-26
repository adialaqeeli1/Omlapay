import 'package:flutter/material.dart';

import '../../../core/models/transaction_model/transaction_model.dart';
import '../../../core/utils/app_exception.dart';
import '../../dashboard/history/services/history_service.dart';

class TransactionDetailsProvider extends ChangeNotifier {
  TransactionDetailsProvider({
    required this.transactionId,
    TransactionModel? seed,
    HistoryService? service,
  }) : _service = service ?? HistoryService(),
       _transaction = seed {
    fetchDetails();
  }

  final String transactionId;
  final HistoryService _service;

  TransactionModel? _transaction;
  bool _isLoading = false;
  String? _errorKey;
  bool _disposed = false;

  TransactionModel? get transaction => _transaction;
  bool get isLoading => _isLoading;
  String? get errorKey => _errorKey;
  bool get hasData => _transaction != null;

  Future<void> fetchDetails() async {
    _isLoading = true;
    _errorKey = null;
    notifyListeners();

    try {
      final tx = await _service.fetchTransactionDetail(transactionId);
      if (_disposed) return;
      _transaction = tx;
    } on AppException catch (e) {
      if (_disposed) return;
      _errorKey = e.messageKey ?? 'requestFailed';
    } catch (_) {
      if (_disposed) return;
      _errorKey = 'requestFailed';
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refresh() async {
    await fetchDetails();
  }

  void saveAs() {
    debugPrint("Saving transaction: ${_transaction?.id}");
    // Future: handle save/share.
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
