import 'package:flutter/material.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/coin_model/coin_model.dart';

class HomeProvider extends ChangeNotifier {
  List<CoinModel> _coins = [];
  bool _isLoading = false;

  List<CoinModel> get coins => _coins;
  bool get isLoading => _isLoading;

  HomeProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate loading data
    await Future.delayed(const Duration(seconds: 2));
    _coins = MockData.coins;

    _isLoading = false;
    notifyListeners();
  }
}
