import 'swap_quote_stream_model.dart';

/// Event yielded by `SwapQuoteStreamService`. Either a parsed live quote
/// or a server-side error payload.
sealed class SwapQuoteStreamEvent {
  const SwapQuoteStreamEvent();
}

class SwapQuoteStreamSuccess extends SwapQuoteStreamEvent {
  const SwapQuoteStreamSuccess(this.quote);
  final SwapQuoteStreamModel quote;
}

/// Server error event. `messageEn` / `messageAr` carry the server-provided
/// localized text (Arabic arrives as either `messageAr` or `message_ar`).
class SwapQuoteStreamFailure extends SwapQuoteStreamEvent {
  const SwapQuoteStreamFailure({
    required this.code,
    required this.messageEn,
    required this.messageAr,
  });

  final String code;
  final String messageEn;
  final String messageAr;
}
