import 'package:flutter/material.dart';

import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../providers/auth_provider.dart';

class SwapProvider extends ChangeNotifier {
  final AuthProvider authProvider;

  List<CoinModel> _coins = [];
  bool _isLoading = false;

  CoinModel? _fromCoin;
  CoinModel? _toCoin;

  final TextEditingController fromAmountController = TextEditingController();
  final TextEditingController toAmountController = TextEditingController();

  String? _error;

  List<CoinModel> get coins => _coins;
  bool get isLoading => _isLoading;
  CoinModel? get fromCoin => _fromCoin;
  CoinModel? get toCoin => _toCoin;
  String? get error => _error;

  bool get isVerified => authProvider.state.user?.isVerified ?? false;

  bool get showVerificationWarning => !isVerified;

  /// Same rules as send: valid amount, no errors, and verified user.
  bool get canSwap =>
      _error == null &&
      fromAmountController.text.isNotEmpty &&
      isVerified;

  SwapProvider(this.authProvider) {
    authProvider.addListener(notifyListeners);
    _loadData();
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

  void _loadData() {
    // Load data from global MockData (simulating user profile)
    _coins = MockData.coins;

    if (_coins.isNotEmpty) {
      _fromCoin = _coins.firstWhere(
        (c) => c.symbol == 'USDT',
        orElse: () => _coins[0],
      );
      _toCoin = _coins.firstWhere(
        (c) => c.symbol == 'BTC',
        orElse: () => _coins.length > 1 ? _coins[1] : _coins[0],
      );
    }
    notifyListeners();
  }

  void setFromCoin(CoinModel coin) {
    if (_toCoin == coin) {
      _toCoin = _fromCoin;
    }
    _fromCoin = coin;
    _validate();
    _calculateToAmount();
    notifyListeners();
  }

  void setToCoin(CoinModel coin) {
    if (_fromCoin == coin) {
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
    _error = null;
    final text = fromAmountController.text;
    if (text.isEmpty) {
      notifyListeners();
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null) {
      _error = 'Invalid amount';
    } else if (_fromCoin != null) {
      final balance =
          double.tryParse(_fromCoin!.amount.replaceAll(',', '')) ?? 0.0;
      if (amount > balance) {
        _error = 'Insufficient balance';
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

  @override
  void dispose() {
    authProvider.removeListener(notifyListeners);
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }
}
