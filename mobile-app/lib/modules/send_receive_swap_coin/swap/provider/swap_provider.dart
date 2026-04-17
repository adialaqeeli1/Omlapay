import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations_from_storage.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/models/swap_quote_model/swap_quote_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/coins_prices_provider.dart';
import '../../../../providers/wallets_provider.dart';
import '../services/swap_service.dart';

class SwapProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final CoinsPricesProvider _coinsPricesProvider;
  final WalletsProvider walletsProvider;

  List<CoinModel> _coins = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  CoinModel? _fromCoin;
  CoinModel? _toCoin;

  final TextEditingController fromAmountController = TextEditingController();
  final TextEditingController toAmountController = TextEditingController();

  String? _error;
  SwapQuoteModel? _swapQuote;

  List<CoinModel> get coins => _coins;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  CoinModel? get fromCoin => _fromCoin;
  CoinModel? get toCoin => _toCoin;
  String? get error => _error;
  SwapQuoteModel? get swapQuote => _swapQuote;

  bool get isVerified => authProvider.state.user?.isVerified ?? false;

  bool get showVerificationWarning => !isVerified;

  /// Same rules as send: valid amount, no errors, and verified user.
  bool get canSwap =>
      _error == null && fromAmountController.text.isNotEmpty && isVerified;

  SwapProvider(this.authProvider, this._coinsPricesProvider, this.walletsProvider) {
    authProvider.addListener(notifyListeners);
    _coinsPricesProvider.addListener(_onStreamedCoinsUpdated);
    _syncCoinsFromPrices();
    fromAmountController.addListener(() {
      _validate();
      _calculateToAmount();
    });
  }

  Future<void> completeVerification() async {
    await authProvider.verifyUser();
    notifyListeners();
  }

  // Mock exchange rate and fee
  double get _exchangeRate => 0.00032; // Mock: 1 USDT = 0.00032 BTC
  double get _swapFeePercentage => 0.0065; // Mock: 0.65% fee

  String _swapFee = '0';
  String get swapFee => _swapFee;

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
      _validate();
      notifyListeners();
      return;
    }

    // Preserve user's selection — only refresh price data for the selected coins.
    // Set defaults only on the first load when no coin is selected yet.
    if (_fromCoin != null) {
      _fromCoin = _coins.where((c) => c.symbol == _fromCoin!.symbol).firstOrNull ?? _coins.first;
    } else {
      _fromCoin = _coins.first;
    }

    if (_toCoin != null) {
      _toCoin = _coins.where((c) => c.symbol == _toCoin!.symbol).firstOrNull ??
          (_coins.length > 1 ? _coins[1] : _coins.first);
    } else {
      _toCoin = _coins.length > 1 ? _coins[1] : _coins.first;
    }

    _validate();
    _calculateToAmount();
    notifyListeners();
  }

  void setFromCoin(CoinModel coin) {
    if (_toCoin != null && _toCoin!.symbol == coin.symbol) {
      _toCoin = _fromCoin;
    }
    _fromCoin = coin;
    _validate();
    _calculateToAmount();
    notifyListeners();
  }

  void setToCoin(CoinModel coin) {
    if (_fromCoin != null && _fromCoin!.symbol == coin.symbol) {
      _fromCoin = _toCoin;
    }
    _toCoin = coin;
    _calculateToAmount();
    notifyListeners();
  }

  void swapCoins() {
    final temp = _fromCoin;
    _fromCoin = _toCoin;
    _toCoin = temp;
    _validate(); // Validate after swap as balance might change
    _calculateToAmount();
    notifyListeners();
  }

  void setMaxAmount() {
    if (_fromCoin != null) {
      // Assuming amount in CoinModel is the balance
      // Clean amount string (remove non-numeric if necessary, though model usually has clean string or double)
      // The CoinModel definition showed String amount.
      fromAmountController.text = _fromCoin!.amount;
      _validate();
    }
  }

  void _validate() {
    final l10n = appLocalizationsFromStoredLocale();
    _error = null;
    final text = fromAmountController.text;
    if (text.isEmpty) {
      notifyListeners();
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null) {
      _error = l10n.sendValidationInvalidAmount;
    } else if (_fromCoin != null) {
      final balanceStr = walletsProvider.balanceForCoin(_fromCoin!.symbol).replaceAll(',', '');
      final balance = double.tryParse(balanceStr) ?? 0.0;
      if (amount > balance) {
        _error = l10n.sendValidationInsufficientBalance;
      }
    }
    notifyListeners();
  }

  void _calculateToAmount() {
    final text = fromAmountController.text;
    if (text.isEmpty) {
      toAmountController.text = '';
      _swapFee = '0';
      notifyListeners();
      return;
    }

    final fromAmount = double.tryParse(text);
    if (fromAmount == null) {
      toAmountController.text = '';
      _swapFee = '0';
      return;
    }

    // Simulate Fee Calculation
    final fee = fromAmount * _swapFeePercentage;
    _swapFee = fee.toStringAsFixed(4);

    // Simulate Exchange Value
    // In real app, we would get rate from pair (fromCoin, toCoin)
    // Requirement: "update the to field with the values of from field based on the swap fees value"

    // Let's do simple: To = From * Rate. Fee displayed separate.
    final toAmount = fromAmount * _exchangeRate;

    // Update To Controller
    // Only update if value is different to avoid cursor jumps if user was typing (but it's read only so fine)
    final formattedTo = toAmount.toStringAsFixed(6);
    if (toAmountController.text != formattedTo) {
      toAmountController.text = formattedTo;
    }
    notifyListeners();
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

  @override
  void dispose() {
    _coinsPricesProvider.removeListener(_onStreamedCoinsUpdated);
    authProvider.removeListener(notifyListeners);
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }
}
