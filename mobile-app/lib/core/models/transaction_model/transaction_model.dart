import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

enum TransactionType { sent, received, swap }

enum TransactionStatus { pending, completed, failed }

@freezed
abstract class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String coinSymbol,
    required String coinName,
    required String amount,
    required String valueInCurrency,
    required TransactionType type,
    required TransactionStatus status,
    required DateTime date,
    required String? toAddress,
    required String? fromAddress,
    required String? transactionHash,
    required double? fee,
    String? note,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}
