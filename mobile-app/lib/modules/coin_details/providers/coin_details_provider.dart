import 'package:flutter/material.dart';

class CoinDetailsProvider extends ChangeNotifier {
  final double _currentPrice = 0.0;
  final double _priceChange = 0.0;
  final double _priceChangePercent = 0.0;

  double get currentPrice => _currentPrice;
  double get priceChange => _priceChange;
  double get priceChangePercent => _priceChangePercent;
}
