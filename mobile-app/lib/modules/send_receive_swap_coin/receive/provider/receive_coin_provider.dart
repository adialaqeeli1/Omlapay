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

  // Delegate to global WalletsProvider
  List<WalletNetworkModel> get wallets => _walletsProvider.wallets;
  bool get isLoading => _walletsProvider.isLoading;
  String? get errorMessage => _walletsProvider.errorMessage;
  bool get kycRequired => _walletsProvider.kycRequired;

  /// Triggers a global wallet refresh (e.g. pull-to-refresh).
  Future<void> refreshWallets() => _walletsProvider.refreshWallets();

  void _onWalletsUpdated() {
    notifyListeners();
  }

  @override
  void dispose() {
    _walletsProvider.removeListener(_onWalletsUpdated);
    super.dispose();
  }
}
