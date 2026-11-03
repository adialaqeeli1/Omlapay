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

  /// Formats a (typically tiny) fee amount for display: truncates to
  /// [maxDecimals] places — which drops floating-point representation
  /// artifacts like `0.00000300000000000005` → `0.000003` — then strips
  /// trailing zeros so the value reads cleanly. No thousands grouping.
  ///
  /// Uses a high default precision so small crypto fees aren't flattened the
  /// way [toFormattedAmount]'s 4-decimal display would.
  String toTrimmedAmount({int maxDecimals = 12}) {
    var s = _truncateToDecimals(
      maxDecimals,
    ).toStringAsFixed(maxDecimals < 0 ? 0 : maxDecimals);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  /// Formats this number as a *minimum* threshold for hints and validation
  /// messages: fixed [decimals] decimal places with thousands grouping, but
  /// rounded **up** (ceiling) instead of truncated.
  ///
  /// A minimum must round up — flooring would understate it. For example a real
  /// minimum of `0.00291` floored to `0.0029` is misleading: entering the shown
  /// `0.0029` is still below the true minimum and would be rejected. Ceiling it
  /// to `0.0030` keeps the displayed minimum genuinely acceptable.
  ///
  /// Defaults to [AppConstants.minAmountDecimals].
  String toFormattedMinAmount({int decimals = AppConstants.minAmountDecimals}) {
    final pattern = decimals > 0 ? '#,##0.${'0' * decimals}' : '#,##0';
    return NumberFormat(pattern, 'en_US').format(_ceilToDecimals(decimals));
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

  /// Rounds up (ceiling) to [decimals] places.
  ///
  /// Truncates first, then bumps by one unit in the last place when any nonzero
  /// remainder was dropped. The remainder is checked at buffered precision (see
  /// [_truncateToDecimals]) so float representation noise at an exact boundary
  /// (e.g. `0.0029` stored as `0.002899999…`) isn't mistaken for a remainder
  /// and rounded up spuriously.
  double _ceilToDecimals(int decimals) {
    if (decimals < 0) return toDouble();
    final truncated = _truncateToDecimals(decimals);
    final precise = double.parse(toStringAsFixed(decimals + 8));
    if (precise <= truncated) return truncated;
    var unit = 1.0;
    for (var i = 0; i < decimals; i++) {
      unit /= 10;
    }
    return truncated + unit;
  }
}
