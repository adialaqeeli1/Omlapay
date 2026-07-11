import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Canonical brand-tinted background color for [symbol] — used for the
/// circular bg behind a coin's logo throughout the app (transaction lists,
/// send / receive sheets, swap review, etc.).
///
/// [isDarkMode] is honored only for symbols whose brand color renders
/// poorly against the active scaffold. Today that's just ETH: pure white
/// pops on the dark scaffold but disappears into the light one, so we
/// substitute Ethereum brand blue (#627EEA) in light mode.
///
/// [fallback] is returned for symbols not in the canonical list. Defaults
/// to [AppColors.primaryColor] (matches the historical default in most
/// call sites — pass `Colors.grey` for the sites that used grey).
Color coinBrandColor(
  String symbol, {
  required bool isDarkMode,
  Color? fallback,
}) {
  switch (symbol.toUpperCase()) {
    case 'USDT':
      return AppColors.usdtColor;
    case 'BTC':
      return AppColors.bitcoinColor;
    case 'ETH':
      return isDarkMode ? AppColors.textWhite : const Color(0xFF627EEA);
    case 'SOL':
      return const Color(0xFF9945FF);
    default:
      return fallback ?? AppColors.primaryColor;
  }
}
