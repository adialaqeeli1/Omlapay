import 'package:intl/intl.dart';

import '../constants/constants.dart';

extension NumberExtensions on num {
  /// Formats this number for amount display: fixed [decimals] decimal places
  /// and standard thousands grouping
  /// (e.g. 0.0100, 10,000.0100, 100,000.0000, 1,234,567.8900).
  ///
  /// Defaults to [AppConstants.coinAmountDecimals]. Pass
  /// [AppConstants.fiatValueDecimals] for fiat (USD/SAR) values.
  String toFormattedAmount({int decimals = AppConstants.coinAmountDecimals}) {
    final pattern = decimals > 0 ? '#,##0.${'0' * decimals}' : '#,##0';
    return NumberFormat(pattern, 'en_US').format(this);
  }
}
