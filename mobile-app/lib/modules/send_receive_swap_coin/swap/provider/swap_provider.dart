import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/app_localizations_from_storage.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/models/swap_quote_model/swap_quote_model.dart';
import '../../../../core/models/swap_quote_stream_model/swap_quote_stream_event.dart';
import '../../../../core/models/swap_quote_stream_model/swap_quote_stream_model.dart';
import '../../../../core/services/swap_quote_stream_service.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/coins_prices_provider.dart';
import '../../../../providers/global_provider.dart';
import '../../../../providers/wallets_provider.dart';
import '../services/swap_service.dart';

class SwapProvider extends ChangeNotifier {
  SwapProvider(
    this.authProvider,
    this._coinsPricesProvider,
    this.walletsProvider,
    this._globalProvider,
    this._quoteStreamService, {
    String? initialFromCoinSymbol,
  }) {
    final trimmed = initialFromCoinSymbol?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      _initialFromSymbol = trimmed.toUpperCase();
    }
    authProvider.addListener(notifyListeners);
    _coinsPricesProvider.addListener(_onStreamedCoinsUpdated);
    _globalProvider.addListener(_onInputsChanged);
    _syncCoinsFromPrices();
    fromAmountController.addListener(_onInputsChanged);
  }

  /// Pre-selected `from` coin symbol applied on the first successful sync
  /// from [CoinsPricesProvider]. Cleared after it has been applied so later
  /// SSE updates respect the user's manual selection.
  String? _initialFromSymbol;

  final AuthProvider authProvider;
  final CoinsPricesProvider _coinsPricesProvider;
  final WalletsProvider walletsProvider;
  final GlobalProvider _globalProvider;
  final SwapQuoteStreamService _quoteStreamService;

  static const Duration _debounceDuration = Duration(milliseconds: 400);

  List<CoinModel> _coins = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  CoinModel? _fromCoin;
  CoinModel? _toCoin;

  final TextEditingController fromAmountController = TextEditingController();
  final TextEditingController toAmountController = TextEditingController();

  String? _localError;
  SwapQuoteModel? _swapQuote;

  Timer? _debounceTimer;
  StreamSubscription<SwapQuoteStreamEvent>? _quoteSubscription;

  SwapQuoteStreamModel? _liveQuote;
  SwapQuoteStreamFailure? _streamFailure;
  String? _transportError;
  bool _isStreamLoading = false;

  List<CoinModel> get coins => _coins;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  CoinModel? get fromCoin => _fromCoin;
  CoinModel? get toCoin => _toCoin;
  SwapQuoteModel? get swapQuote => _swapQuote;

  SwapQuoteStreamModel? get liveQuote => _liveQuote;
  bool get isStreamLoading => _isStreamLoading;

  /// Unified error surface for the UI: server stream error > local validation
  /// > transport error.
  String? get error {
    final failure = _streamFailure;
    if (failure != null) return _resolveFailureMessage(failure);
    if (_localError != null) return _localError;
    return _transportError;
  }

  bool get isVerified => authProvider.state.user?.isVerified ?? false;
  bool get showVerificationWarning => !isVerified;

  /// Minimum amount the user is allowed to swap from [fromCoin], parsed as a
  /// double. Returns 0 when the backend hasn't shipped a `swapMinAmount` for
  /// the selected coin so the UI can hide the bound-driven hint/row.
  double get fromCoinSwapMinAmount =>
      double.tryParse(_fromCoin?.swapMinAmount ?? '') ?? 0;

  /// Maximum amount the user is allowed to swap from [fromCoin], parsed as
  /// a double. Returns 0 when the backend hasn't shipped a `swapMaxAmount`.
  double get fromCoinSwapMaxAmount =>
      double.tryParse(_fromCoin?.swapMaxAmount ?? '') ?? 0;

  /// Live fees — empty string when no quote yet.
  String get totalFeeFromCoinAmount =>
      _liveQuote?.fees?.total?.fromCoinAmount ?? '';
  String get omlapayFeeFromCoinAmount =>
      _liveQuote?.fees?.omlapay?.fromCoinAmount ?? '';
  String get binanceFeeFromCoinAmount =>
      _liveQuote?.fees?.binance?.fromCoinAmount ?? '';

  /// Display value for the "1 fromCoin ≈ X toCoin" row. Prefers `inverseRate`
  /// (matches the label direction). Falls back to `1/exchangeRate`. Empty
  /// string when no quote yet or the value is non-parseable.
  String get displayExchangeRate {
    final quote = _liveQuote;
    if (quote == null) return '';
    final inverse = quote.inverseRate;
    if (inverse.isNotEmpty && double.tryParse(inverse) != null) return inverse;
    final direct = double.tryParse(quote.exchangeRate);
    if (direct == null || direct == 0) return '';
    return (1 / direct).toStringAsFixed(8);
  }

  bool get canSwap =>
      _streamFailure == null &&
      _localError == null &&
      _liveQuote != null &&
      fromAmountController.text.isNotEmpty &&
      isVerified;

  Future<void> completeVerification() async {
    await authProvider.verifyUser();
    notifyListeners();
  }

  void _onStreamedCoinsUpdated() {
    _syncCoinsFromPrices();
  }

  void _syncCoinsFromPrices() {
    final incoming = _coinsPricesProvider.coins;
    _isLoading = _coinsPricesProvider.isLoading && incoming.isEmpty;
    _coins = List<CoinModel>.from(incoming);

    if (_coins.isEmpty) {
      _fromCoin = null;
      _toCoin = null;
      // _validateLocal();
      notifyListeners();
      return;
    }

    final previousFromSymbol = _fromCoin?.symbol;
    final previousToSymbol = _toCoin?.symbol;

    final pendingInitial = _initialFromSymbol;
    CoinModel? initialFromMatch;
    if (pendingInitial != null) {
      initialFromMatch = _coins
          .where((c) => c.symbol.toUpperCase() == pendingInitial)
          .firstOrNull;
    }

    if (initialFromMatch != null) {
      _fromCoin = initialFromMatch;
      // Pick the first coin that isn't the pre-selected one as the `to` coin.
      _toCoin = _coins.firstWhere(
        (c) => c.symbol.toUpperCase() != pendingInitial,
        orElse: () => _coins.first,
      );
      _initialFromSymbol = null;
    } else {
      if (_fromCoin != null) {
        _fromCoin =
            _coins.where((c) => c.symbol == _fromCoin!.symbol).firstOrNull ??
            _coins.first;
      } else {
        _fromCoin = _coins.first;
      }

      if (_toCoin != null) {
        _toCoin =
            _coins.where((c) => c.symbol == _toCoin!.symbol).firstOrNull ??
            (_coins.length > 1 ? _coins[1] : _coins.first);
      } else {
        _toCoin = _coins.length > 1 ? _coins[1] : _coins.first;
      }
    }

    // _validateLocal();
    final selectionChanged =
        previousFromSymbol != _fromCoin?.symbol ||
        previousToSymbol != _toCoin?.symbol;
    if (selectionChanged) {
      _onInputsChanged();
    }
    notifyListeners();
  }

  void setFromCoin(CoinModel coin) {
    if (_toCoin != null && _toCoin!.symbol == coin.symbol) {
      _toCoin = _fromCoin;
    }
    _fromCoin = coin;
    // _validateLocal();
    _onInputsChanged();
    notifyListeners();
  }

  void setToCoin(CoinModel coin) {
    if (_fromCoin != null && _fromCoin!.symbol == coin.symbol) {
      _fromCoin = _toCoin;
    }
    _toCoin = coin;
    _onInputsChanged();
    notifyListeners();
  }

  void swapCoins() {
    final temp = _fromCoin;
    _fromCoin = _toCoin;
    _toCoin = temp;
    // _validateLocal();
    _onInputsChanged();
    notifyListeners();
  }

  void setMaxAmount() {
    final coin = _fromCoin;
    if (coin == null) return;
    final swapMax = double.tryParse(coin.swapMaxAmount ?? '');
    if (swapMax != null && swapMax > 0) {
      fromAmountController.text = swapMax.toStringAsFixed(
        AppConstants.maxAmountDecimals,
      );
    } else {
      fromAmountController.text = coin.amount;
    }
    // _validateLocal();
  }

  // void _validateLocal() {
  //   final l10n = appLocalizationsFromStoredLocale();
  //   _localError = null;
  //   final text = fromAmountController.text;
  //   if (text.isEmpty) return;

  //   final amount = double.tryParse(text);
  //   if (amount == null) {
  //     _localError = l10n.sendValidationInvalidAmount;
  //     return;
  //   }
  //   if (_fromCoin != null) {
  //     final balanceStr = walletsProvider
  //         .balanceForCoin(_fromCoin!.symbol)
  //         .replaceAll(',', '');
  //     final balance = double.tryParse(balanceStr) ?? 0.0;
  //     if (amount > balance) {
  //       _localError = l10n.sendValidationInsufficientBalance;
  //     }
  //   }
  // }

  /// Single entry point for any input change (amount, coin, currency).
  /// Validates locally, cancels any in-flight stream, and schedules a
  /// debounced reconnect when inputs are complete.
  void _onInputsChanged() {
    // _validateLocal();

    final amountText = fromAmountController.text.trim();
    final parsed = double.tryParse(amountText);
    final inputsValid =
        _fromCoin != null &&
        _toCoin != null &&
        _fromCoin!.symbol != _toCoin!.symbol &&
        amountText.isNotEmpty &&
        parsed != null &&
        parsed > 0;

    _debounceTimer?.cancel();

    if (!inputsValid) {
      _quoteSubscription?.cancel();
      _quoteSubscription = null;
      _liveQuote = null;
      _streamFailure = null;
      _transportError = null;
      _isStreamLoading = false;
      if (toAmountController.text.isNotEmpty) {
        toAmountController.text = '';
      }
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(_debounceDuration, _connectStream);
    notifyListeners();
  }

  Future<void> _connectStream() async {
    await _quoteSubscription?.cancel();
    _quoteSubscription = null;

    final fromCoin = _fromCoin;
    final toCoin = _toCoin;
    final amountText = fromAmountController.text.trim();
    if (fromCoin == null || toCoin == null || amountText.isEmpty) return;

    _streamFailure = null;
    _transportError = null;
    _liveQuote = null;
    if (toAmountController.text.isNotEmpty) {
      toAmountController.text = '';
    }
    _isStreamLoading = true;
    notifyListeners();

    _quoteSubscription = _quoteStreamService
        .streamSwapQuote(
          fromCoin: fromCoin.symbol,
          toCoin: toCoin.symbol,
          amount: amountText,
          currency: _globalProvider.selectedCurrency,
        )
        .listen(_onStreamEvent, onError: _onStreamError, cancelOnError: false);
  }

  void _onStreamEvent(SwapQuoteStreamEvent event) {
    _isStreamLoading = false;
    switch (event) {
      case SwapQuoteStreamSuccess(:final quote):
        _liveQuote = quote;
        _streamFailure = null;
        _transportError = null;
        final receive = double.tryParse(quote.youReceive);
        final formatted = receive == null
            ? ''
            : receive.toStringAsFixed(AppConstants.coinAmountDecimals);
        if (toAmountController.text != formatted) {
          toAmountController.text = formatted;
        }
      case SwapQuoteStreamFailure():
        _streamFailure = event;
      // Preserve the last good `_liveQuote` and `toAmountController` so the
      // UI doesn't layout-shift when the server alternates ok/error at the
      // balance boundary. The error text is shown on top via `error`.
    }
    notifyListeners();
  }

  void _onStreamError(Object error, [StackTrace? stackTrace]) {
    final l10n = appLocalizationsFromStoredLocale();
    _isStreamLoading = false;
    _transportError = l10n.requestFailed;
    // Preserve last good quote to avoid layout shift; see _onStreamEvent.
    notifyListeners();
  }

  String _resolveFailureMessage(SwapQuoteStreamFailure failure) {
    final l10n = appLocalizationsFromStoredLocale();
    final isArabic = _isArabicLocale(l10n);

    switch (failure.code) {
      case 'INSUFFICIENT_BALANCE':
        return l10n.swapErrorInsufficientBalance;
      default:
        if (isArabic && failure.messageAr.isNotEmpty) return failure.messageAr;
        if (failure.messageEn.isNotEmpty) return failure.messageEn;
        return l10n.requestFailed;
    }
  }

  bool _isArabicLocale(AppLocalizations l10n) {
    return l10n.localeName.toLowerCase().startsWith('ar');
  }

  /// Calls the swap quote API. Rethrows exceptions so the UI layer
  /// can display appropriate error snackbars.
  Future<void> getSwapQuote() async {
    if (_isSubmitting) return;
    if (_fromCoin == null || _toCoin == null) return;

    _isSubmitting = true;
    notifyListeners();

    try {
      _swapQuote = await SwapService.fetchSwapQuote(
        fromCoin: _fromCoin!.symbol,
        toCoin: _toCoin!.symbol,
        amount: fromAmountController.text.trim(),
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Executes the swap via the backend. Returns `true` on success.
  /// Rethrows exceptions so the UI can surface localized error messages.
  Future<bool> executeSwap() async {
    if (_isSubmitting) return false;
    if (_fromCoin == null || _toCoin == null) return false;
    if (fromAmountController.text.trim().isEmpty) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      await SwapService.executeSwap(
        fromCoin: _fromCoin!.symbol,
        toCoin: _toCoin!.symbol,
        amount: fromAmountController.text.trim(),
      );
      unawaited(walletsProvider.refreshWallets());
      return true;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _quoteSubscription?.cancel();
    _coinsPricesProvider.removeListener(_onStreamedCoinsUpdated);
    _globalProvider.removeListener(_onInputsChanged);
    authProvider.removeListener(notifyListeners);
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }
}
