import 'package:freezed_annotation/freezed_annotation.dart';

import 'transaction_swap_asset.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
abstract class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    required String id,
    @JsonKey(name: 'coin_symbol') required String assetSymbol,
    @JsonKey(name: 'coinName') String? assetName,
    @JsonKey(name: 'coinName_ar') String? assetNameAr,
    String? assetIconUrl,
    required String amount,
    String? amountDisplay,
    String? amountUsd,
    @JsonKey(name: 'amountSAR') String? amountSar,
    String? network,
    required DateTime createdAt,
    String? txHash,
    @JsonKey(name: 'blockchain_link') String? blockchainLink,
    required String status,
    String? direction,
    String? type,
    @JsonKey(name: 'networkIconUrl') String? networkIconUrl,
    String? fee,
    String? errorMessage,
    String? errorMessageAr,
    String? senderAddress,
    String? receiverAddress,
    String? counterpartyPhone,
    @JsonKey(name: 'txType') String? transactionType,
    String? pairLabel,
    TransactionSwapAsset? fromAsset,
    TransactionSwapAsset? toAsset,
    String? exchangeRate,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  bool get isReceived {
    final d = direction?.toUpperCase();
    if (d == 'IN' || d == 'RECEIVED') return true;
    if (d == 'OUT' || d == 'SENT') return false;
    return amount.startsWith('+');
  }

  bool get isSent {
    final d = direction?.toUpperCase();
    if (d == 'OUT' || d == 'SENT') return true;
    if (d == 'IN' || d == 'RECEIVED') return false;
    return amount.startsWith('-');
  }

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isFailed => status.toUpperCase() == 'FAILED';

  String? get txType => transactionType?.toUpperCase();
  bool get isSwap => txType == 'SWAP';
}
