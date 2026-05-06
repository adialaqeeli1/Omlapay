import 'package:flutter/material.dart';
import '../../../../core/models/wallet_model/wallet_model.dart';
import '../../../../providers/wallets_provider.dart';

class ReciveCoinProvider extends ChangeNotifier {
  ReciveCoinProvider({required WalletsProvider walletsProvider})
    : _walletsProvider = walletsProvider {
    _walletsProvider.addListener(_onWalletsUpdated);
    // Refresh wallets every time the receive screen opens.
    Future.microtask(() => _walletsProvider.refreshWallets());
  }

  final WalletsProvider _walletsProvider;
  bool _addressCopiedVisible = false;

  // Delegate to global WalletsProvider
  List<WalletNetworkModel> get wallets => _walletsProvider.wallets;
  bool get isLoading => _walletsProvider.isLoading;
  String? get errorMessage => _walletsProvider.errorMessage;
  bool get kycRequired => _walletsProvider.kycRequired;
  bool get addressCopiedVisible => _addressCopiedVisible;

  /// Triggers a global wallet refresh (e.g. pull-to-refresh).
  Future<void> refreshWallets() => _walletsProvider.refreshWallets();

  void _onWalletsUpdated() {
    notifyListeners();
  }

  void copyAddress(String address) {
    _addressCopiedVisible = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      _addressCopiedVisible = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _walletsProvider.removeListener(_onWalletsUpdated);
    super.dispose();
  }
}
