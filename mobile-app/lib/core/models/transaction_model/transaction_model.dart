import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
abstract class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    required String id,
    required String assetSymbol,
    required String assetName,
    String? assetIconUrl,
    required String amount,
    String? network,
    required DateTime createdAt,
    String? txHash,
    required String status,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  bool get isReceived => amount.startsWith('+');
  bool get isSent => amount.startsWith('-');
  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isFailed => status.toUpperCase() == 'FAILED';
}
