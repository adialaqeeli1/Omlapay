import 'package:flutter/material.dart';

import 'auth_provider.dart';

/// Re-prompts the soft-login passcode when the app has been in the background
/// long enough that the device may have been handed off (default 60s).
///
/// Owns three pieces of state:
/// - [isUnlocked]: `true` only after a successful login/softLogin in the
///   current process. Reset to `false` when the threshold elapses on resume,
///   or when the user logs out.
/// - `_backgroundedAt`: timestamp of the first paused/hidden event in the
///   current background cycle.
/// - `_isLockOverlayVisible`: re-entrancy guard so we don't stack overlays.
///
/// Show/dismiss are passed in as callbacks so the provider has no direct
/// dependency on the navigator; this keeps it unit-testable.
class AppLockProvider extends ChangeNotifier with WidgetsBindingObserver {
  AppLockProvider({
    required AuthProvider authProvider,
    required void Function() showLockOverlay,
    required void Function() dismissLockOverlay,
    Duration backgroundThreshold = const Duration(seconds: 60),
    DateTime Function() clock = _defaultClock,
  }) : _authProvider = authProvider,
       _showLockOverlay = showLockOverlay,
       _dismissLockOverlay = dismissLockOverlay,
       _backgroundThreshold = backgroundThreshold,
       _clock = clock {
    WidgetsBinding.instance.addObserver(this);
    _authProvider.addListener(_onAuthChanged);
    _wasAuthenticated = _authProvider.state.isAuthenticated;
    _authProvider.onUnlockCallback = markUnlocked;
  }

  final AuthProvider _authProvider;
  final void Function() _showLockOverlay;
  final void Function() _dismissLockOverlay;
  final Duration _backgroundThreshold;
  final DateTime Function() _clock;

  static DateTime _defaultClock() => DateTime.now();

  bool _isUnlocked = false;
  DateTime? _backgroundedAt;
  bool _isLockOverlayVisible = false;
  bool _wasAuthenticated = false;

  bool get isUnlocked => _isUnlocked;

  void markUnlocked() {
    if (_isUnlocked) return;
    _isUnlocked = true;
    if (_isLockOverlayVisible) {
      _isLockOverlayVisible = false;
      _dismissLockOverlay();
    }
    notifyListeners();
  }

  /// Called by the route owner once the lock overlay has actually been popped
  /// (e.g. via `MaterialPageRoute.popped.then`). Lets the provider take a fresh
  /// lock the next time the threshold is crossed.
  void overlayDidDismiss() {
    if (!_isLockOverlayVisible) return;
    _isLockOverlayVisible = false;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt ??= _clock();
        break;
      case AppLifecycleState.resumed:
        final stamp = _backgroundedAt;
        _backgroundedAt = null;
        if (stamp == null) return;
        final elapsed = _clock().difference(stamp);
        if (elapsed < _backgroundThreshold) return;
        if (_shouldLock()) {
          _isUnlocked = false;
          _isLockOverlayVisible = true;
          notifyListeners();
          _showLockOverlay();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // Ignored — see design doc rationale.
        break;
    }
  }

  void _onAuthChanged() {
    final isAuthenticated = _authProvider.state.isAuthenticated;
    if (_wasAuthenticated && !isAuthenticated) {
      _isUnlocked = false;
      if (_isLockOverlayVisible) {
        _isLockOverlayVisible = false;
        _dismissLockOverlay();
      }
      notifyListeners();
    }
    _wasAuthenticated = isAuthenticated;
  }

  bool _shouldLock() {
    return _isUnlocked &&
        _authProvider.state.isAuthenticated &&
        !_isLockOverlayVisible;
  }

  @override
  void dispose() {
    if (identical(_authProvider.onUnlockCallback, markUnlocked)) {
      _authProvider.onUnlockCallback = null;
    }
    _authProvider.removeListener(_onAuthChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
