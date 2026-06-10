import 'package:intl/intl.dart';

import '../constants/constants.dart';

extension NumberExtensions on num {
  /// Formats this number for amount display: fixed [decimals] decimal places
  /// and standard thousands grouping
  /// (e.g. 0.0100, 10,000.0100, 100,000.0000, 1,234,567.8900).
  ///
  /// The value is *truncated* (floored toward zero) to [decimals] places, not
  /// rounded — so the display never overstates the real amount. For example
  /// `0.0248841` shows as `0.0248`, not `0.0249`. This matters for crypto
  /// balances where a rounded-up display could exceed what the user actually
  /// holds.
  ///
  /// Defaults to [AppConstants.coinAmountDecimals]. Pass
  /// [AppConstants.fiatValueDecimals] for fiat (USD/SAR) values.
  String toFormattedAmount({int decimals = AppConstants.coinAmountDecimals}) {
    final pattern = decimals > 0 ? '#,##0.${'0' * decimals}' : '#,##0';
    return NumberFormat(pattern, 'en_US').format(_truncateToDecimals(decimals));
  }

  /// Formats this number for an editable amount input: fixed [decimals]
  /// decimal places, *truncated* (floored toward zero) like
  /// [toFormattedAmount], but **without** thousands grouping so the result
  /// stays cleanly parseable when written into a text field controller.
  ///
  /// For example `0.00248923` becomes `0.0024`, never `0.0025`.
  String toInputAmount({int decimals = AppConstants.coinAmountDecimals}) {
    return _truncateToDecimals(
      decimals,
    ).toStringAsFixed(decimals < 0 ? 0 : decimals);
  }

  /// Truncates (toward zero) to [decimals] places without rounding.
  ///
  /// Works on the string form at extra precision first so floating-point
  /// representation error near a boundary (e.g. `0.0249` stored as
  /// `0.024899999…`) is absorbed before the cut, then truncates exactly.
  double _truncateToDecimals(int decimals) {
    if (decimals < 0) return toDouble();
    final str = toStringAsFixed(decimals + 8);
    final dot = str.indexOf('.');
    if (dot == -1) return toDouble();
    final end = decimals == 0 ? dot : dot + 1 + decimals;
    return double.parse(str.substring(0, end));
  }
}
