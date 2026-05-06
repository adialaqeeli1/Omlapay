import 'package:flutter/widgets.dart';

import 'coin_model.dart';

extension CoinModelQuoteDisplay on CoinModel {
  /// Ticker-style label (e.g. BTC). Always English, regardless of locale.
  String localizedCoinTicker(BuildContext context) => symbol;

  /// Primary title (e.g. subtitle under ticker). Always English, regardless of locale.
  String localizedCoinPrimaryName(BuildContext context) {
    if (symbol == 'USDT' && name.trim().isEmpty) {
      return symbol;
    }
    return name;
  }

  /// Fiat/quote label shown next to coin prices. Always English (USD/SAR), regardless of locale.
  String quoteCurrencyLabel(BuildContext context, String selectedCurrencyCode) {
    if (quoteSymbol != null && quoteSymbol!.trim().isNotEmpty) {
      return quoteSymbol!.trim();
    }
    return selectedCurrencyCode.toUpperCase();
  }
}
