import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    // Check the initial connectivity status.
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    _isInitialized = true;
    notifyListeners();

    // Listen for subsequent changes.
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final connected = results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);
    if (_isConnected != connected) {
      _isConnected = connected;
      notifyListeners();
    }
  }

  /// Manually re-check connectivity (e.g. from "Try Again" button).
  Future<void> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
