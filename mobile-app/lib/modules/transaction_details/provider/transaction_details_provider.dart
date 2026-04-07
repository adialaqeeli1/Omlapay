import 'package:flutter/material.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';

class TransactionDetailsProvider extends ChangeNotifier {
  final TransactionModel transaction;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TransactionDetailsProvider({required this.transaction});

  void saveAs() {
    debugPrint("Saving transaction: ${transaction.id}");
    // Add logic to save transaction details (e.g., share or save to files)
  }
}
