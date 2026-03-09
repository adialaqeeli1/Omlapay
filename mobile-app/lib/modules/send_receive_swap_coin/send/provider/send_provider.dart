import 'package:flutter/material.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/models/contact_model/contact_model.dart';
import '../../../../providers/auth_provider.dart';

class SendProvider extends ChangeNotifier {
  final AuthProvider authProvider;

  List<CoinModel> _coins = [];
  bool _isLoading = false;

  CoinModel? _selectedCoin;
  ContactModel? _selectedContact;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController networkController = TextEditingController(
    text: 'TRC20',
  );

  String? _error;
  final String _network = 'TRC20'; // Mock/Default network

  // Getters
  List<CoinModel> get coins => _coins;
  bool get isLoading => _isLoading;
  CoinModel? get selectedCoin => _selectedCoin;
  ContactModel? get selectedContact => _selectedContact;
  String? get error => _error;
  bool get isVerified => authProvider.state.user?.isVerified ?? false;
  String get network => _network;

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

  SendProvider(this.authProvider) {
    authProvider.addListener(notifyListeners);
    _loadData();
    amountController.addListener(_validate);
    recipientController.addListener(() {
      // If user types manually, we might clear selected contact or try to find one
      // For now, let's keep it simple: if text changes and doesn't match selected contact, clear specific contact
      if (_selectedContact != null &&
          recipientController.text != _selectedContact!.phoneNumber) {
        // _selectedContact = null; // Optional: depending on UX desired.
        // For this task, we assume selection mainly via sheet, or manual entry validates differently.
        // Let's rely on selection for the "Flow" requested.
      }
      notifyListeners();
    });
  }

  void _loadData() {
    // Load coins from MockData
    _coins = MockData.coins;
    if (_coins.isNotEmpty) {
      _selectedCoin = _coins.firstWhere(
        (c) => c.symbol == 'USDT',
        orElse: () => _coins[0],
      );
    }
    notifyListeners();
  }

  void setSelectedCoin(CoinModel coin) {
    _selectedCoin = coin;
    _validate();
    notifyListeners();
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
      amountController.text = _selectedCoin!.amount.replaceAll(
        ',',
        '',
      ); // Simple strip
      _validate();
    }
  }

  void _validate() {
    _error = null;
    final text = amountController.text;
    if (text.isEmpty) {
      notifyListeners();
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null) {
      _error = 'Invalid amount';
    } else if (_selectedCoin != null) {
      // Mock parsing amount string "200,023.20" -> 200023.20
      final balanceStr = _selectedCoin!.amount.replaceAll(',', '');
      final balance = double.tryParse(balanceStr) ?? 0.0;

      if (amount > balance) {
        _error = 'Insufficient balance';
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    authProvider.removeListener(notifyListeners);
    amountController.dispose();
    recipientController.dispose();
    super.dispose();
  }
}
