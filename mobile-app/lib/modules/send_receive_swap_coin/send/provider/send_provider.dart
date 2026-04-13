import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations_from_storage.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/models/contact_model/contact_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/coins_prices_provider.dart';
class SendProvider extends ChangeNotifier {
  SendProvider(this.authProvider, this._coinsPricesProvider) {
    networkController = TextEditingController();

    authProvider.addListener(notifyListeners);
    _coinsPricesProvider.addListener(_onStreamedCoinsUpdated);
    _syncCoinsFromPrices();
    amountController.addListener(_validate);
    recipientController.addListener(() {
      if (_selectedContact != null &&
          recipientController.text != _selectedContact!.phoneNumber) {
        // Selection is mainly via sheet; manual entry can diverge from stored contact.
      }
      notifyListeners();
    });
  }

  final AuthProvider authProvider;
  final CoinsPricesProvider _coinsPricesProvider;

  List<CoinModel> _coins = [];
  bool _isLoading = false;

  CoinModel? _selectedCoin;
  ContactModel? _selectedContact;

  /// After the user picks a coin in the sheet, we keep that symbol across SSE updates.
  bool _userPickedCoin = false;
  String? _userPickedSymbol;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController recipientController = TextEditingController();
  late final TextEditingController networkController;

  String? _error;

  // Getters
  List<CoinModel> get coins => _coins;
  bool get isLoading => _isLoading;
  CoinModel? get selectedCoin => _selectedCoin;
  ContactModel? get selectedContact => _selectedContact;
  String? get error => _error;
  bool get isVerified => authProvider.state.user?.isVerified ?? false;
  String get network => networkController.text;

  // Logic for showing warning:
  // Show if the user has NOT completed verification
  bool get showVerificationWarning => !isVerified;

  // Logic for enabling Send button:
  // 1. Amount is valid
  // 2. Contact is selected
  // 3. No errors
  // 4. User is verified
  bool get canSend =>
      _error == null &&
      amountController.text.isNotEmpty &&
      _selectedContact != null &&
      isVerified;

  void _onStreamedCoinsUpdated() {
    _syncCoinsFromPrices();
  }

  /// Mirrors [CoinsPricesProvider.coins] (SSE) into the send flow list.
  void _syncCoinsFromPrices() {
    final incoming = _coinsPricesProvider.coins;
    _isLoading = _coinsPricesProvider.isLoading && incoming.isEmpty;
    _coins = List<CoinModel>.from(incoming);

    if (_coins.isEmpty) {
      _selectedCoin = null;
      _validate();
      return;
    }

    if (!_userPickedCoin) {
      _selectedCoin = _coins.first;
    } else {
      final key = (_userPickedSymbol ?? _selectedCoin?.symbol ?? '')
          .trim()
          .toUpperCase();
      CoinModel? match;
      if (key.isNotEmpty) {
        for (final c in _coins) {
          if (c.symbol.toUpperCase() == key) {
            match = c;
            break;
          }
        }
      }
      _selectedCoin = match ?? _coins.first;
    }

    _updateNetwork();
    _validate();
  }

  void _updateNetwork() {
    networkController.text = _selectedCoin?.network ?? '';
  }

  void setSelectedCoin(CoinModel coin) {
    _userPickedCoin = true;
    _userPickedSymbol = coin.symbol;
    _selectedCoin = coin;
    _updateNetwork();
    _validate();
  }

  void setSelectedContact(ContactModel contact) {
    _selectedContact = contact;
    recipientController.text = contact.phoneNumber;
    notifyListeners();
  }

  Future<void> completeVerification() async {
    await authProvider.verifyUser();
    notifyListeners();
  }

  void setMaxAmount() {
    if (_selectedCoin != null) {
      amountController.text = _selectedCoin!.amount.replaceAll(',', '');
      _validate();
    }
  }

  void _validate() {
    final l10n = appLocalizationsFromStoredLocale();
    _error = null;
    final text = amountController.text;
    if (text.isEmpty) {
      notifyListeners();
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null) {
      _error = l10n.sendValidationInvalidAmount;
    } else if (_selectedCoin != null) {
      final balanceStr = _selectedCoin!.amount.replaceAll(',', '');
      final balance = double.tryParse(balanceStr) ?? 0.0;

      if (amount > balance) {
        _error = l10n.sendValidationInsufficientBalance;
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _coinsPricesProvider.removeListener(_onStreamedCoinsUpdated);
    authProvider.removeListener(notifyListeners);
    amountController.dispose();
    recipientController.dispose();
    networkController.dispose();
    super.dispose();
  }
}
