import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';

part 'home_model.freezed.dart';
part 'home_model.g.dart';

@freezed
abstract class HomeModel with _$HomeModel {
  const factory HomeModel({
    String? profileImage,
    @Default('0.00') String totalBalance,
    @Default('0.00') String totalBalanceSar,
    @Default([]) List<TransactionModel> recentTransactions,
    @Default(0) int unreadNotifications,
  }) = _HomeModel;

  factory HomeModel.fromJson(Map<String, dynamic> json) =>
      _$HomeModelFromJson(json);
}
