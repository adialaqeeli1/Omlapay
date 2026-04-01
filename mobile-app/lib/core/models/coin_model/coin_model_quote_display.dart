import 'package:flutter/widgets.dart';

import '../../extentions/context_extensions.dart';
import 'coin_model.dart';

extension CoinModelQuoteDisplay on CoinModel {
  static bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  /// Ticker-style label (e.g. BTC): English uses [symbol] for display; Arabic uses [coinSymbolAr] when set.
  /// Icons and asset URLs continue to use [symbol] only.
  String localizedCoinTicker(BuildContext context) {
    if (_isArabic(context) &&
        coinSymbolAr != null &&
        coinSymbolAr!.trim().isNotEmpty) {
      return coinSymbolAr!.trim();
    }
    return symbol;
  }

  /// Primary title (e.g. subtitle under ticker): English uses [name].
  /// Arabic prefers [coinNameAr] when set, else [coinSymbolAr] (legacy API), else [name].
  String localizedCoinPrimaryName(BuildContext context) {
    if (_isArabic(context)) {
      if (coinNameAr != null && coinNameAr!.trim().isNotEmpty) {
        return coinNameAr!.trim();
      }
      if (coinSymbolAr != null && coinSymbolAr!.trim().isNotEmpty) {
        return coinSymbolAr!.trim();
      }
    }
    return name;
  }

  /// Fiat/quote label shown next to coin prices. The app supports English and Arabic only:
  /// - **Arabic** (`languageCode == 'ar'`): prefers API [quoteSymbolAr] (`symbol_ar`), then l10n,
  ///   then Latin [quoteSymbol].
  /// - **English** (and any non-Arabic locale): uses [quoteSymbol] only — never [quoteSymbolAr].
  String quoteCurrencyLabel(BuildContext context, String selectedCurrencyCode) {
    final l10n = context.l10n;
    final code = selectedCurrencyCode.toLowerCase();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      if (quoteSymbolAr != null && quoteSymbolAr!.trim().isNotEmpty) {
        return quoteSymbolAr!.trim();
      }
      if (l10n != null) {
        return l10n.currencyName(code);
      }
      if (quoteSymbol != null && quoteSymbol!.trim().isNotEmpty) {
        return quoteSymbol!.trim();
      }
      return selectedCurrencyCode.toUpperCase();
    }

    // English / non-Arabic: never show API Arabic symbol next to prices.
    if (quoteSymbol != null && quoteSymbol!.trim().isNotEmpty) {
      return quoteSymbol!.trim();
    }
    return l10n?.currencyName(code) ?? selectedCurrencyCode.toUpperCase();
  }
}
