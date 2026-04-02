import 'package:flutter/material.dart';
import '../../../../core/models/wallet_model/wallet_model.dart';
import '../services/receive_wallets_service.dart';

class ReciveCoinProvider extends ChangeNotifier {
  ReciveCoinProvider({ReceiveWalletsService? receiveWalletsService})
    : _receiveWalletsService = receiveWalletsService ?? ReceiveWalletsService() {
    _loadWallets();
  }

  final ReceiveWalletsService _receiveWalletsService;
  List<WalletNetworkModel> _wallets = [];
  bool _isLoading = false;
  bool _addressCopiedVisible = false;
  String? _errorMessage;
  bool _kycRequired = false;

  // Getters
  List<WalletNetworkModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  bool get addressCopiedVisible => _addressCopiedVisible;
  String? get errorMessage => _errorMessage;
  bool get kycRequired => _kycRequired;

  Future<void> _loadWallets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _receiveWalletsService.fetchWallets();
      _wallets = result.networks;
      _kycRequired = result.kycRequired;
    } catch (error) {
      _wallets = [];
      _errorMessage = error.toString();
      _kycRequired = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void copyAddress(String address) {
    // In a real app, you would use Clipboard.setData
    // For now, we'll just show the copied message
    _addressCopiedVisible = true;
    notifyListeners();

    // Clear message after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _addressCopiedVisible = false;
      notifyListeners();
    });
  }
}
