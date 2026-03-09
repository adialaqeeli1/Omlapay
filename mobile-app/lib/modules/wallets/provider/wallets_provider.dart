import 'package:flutter/material.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/wallet_model/wallet_model.dart';

class WalletsProvider extends ChangeNotifier {
  List<WalletModel> _wallets = [];
  bool _isLoading = false;
  String? _copiedMessage;

  // Getters
  List<WalletModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get copiedMessage => _copiedMessage;

  WalletsProvider() {
    _loadWallets();
  }

  void _loadWallets() {
    _isLoading = true;
    notifyListeners();

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _wallets = MockData.wallets;
      _isLoading = false;
      notifyListeners();
    });
  }

  void copyAddress(String address) {
    // In a real app, you would use Clipboard.setData
    // For now, we'll just show the copied message
    _copiedMessage = 'Copied';
    notifyListeners();

    // Clear message after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _copiedMessage = null;
      notifyListeners();
    });
  }
}
