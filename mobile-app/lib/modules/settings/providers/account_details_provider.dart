import 'package:flutter/foundation.dart';

/// Provider that manages the selected network tab index
/// on the Account Details screen.
class AccountDetailsProvider extends ChangeNotifier {
  int _selectedNetworkIndex = 0;

  int get selectedNetworkIndex => _selectedNetworkIndex;

  void selectNetwork(int index) {
    if (_selectedNetworkIndex == index) return;
    _selectedNetworkIndex = index;
    notifyListeners();
  }
}
