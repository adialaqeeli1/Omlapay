import 'package:flutter/foundation.dart';

import '../core/constants/constants.dart';
import '../core/services/biometric_service.dart';
import '../core/services/storage_helper.dart';

/// Owns the biometric-login preference + device capability.
///
/// The enabled flag is a SharedPreferences boolean (not a secret). The passcode
/// reused for unlock is the one already persisted in the user JSON; this
/// provider never stores credentials.
class BiometricProvider extends ChangeNotifier {
  BiometricProvider({BiometricService? service})
      : _service = service ?? BiometricService() {
    _loadEnabledFlag();
    // ignore: discarded_futures
    refreshAvailability();
  }

  final BiometricService _service;

  bool _isEnabled = false;
  bool _isAvailable = false;
  BiometricKind _kind = BiometricKind.fingerprint;

  bool get isEnabled => _isEnabled;
  bool get isAvailable => _isAvailable;

  /// The device's primary biometric modality (face vs fingerprint), used by the
  /// UI to show the matching icon. Defaults to fingerprint until resolved.
  BiometricKind get kind => _kind;

  void _loadEnabledFlag() {
    _isEnabled =
        StorageService.getString(AppConstants.biometricEnabledKey) == 'true';
  }

  /// Re-checks device capability. If capability is gone while the toggle was
  /// enabled, auto-disable so the UI/flag never claim biometrics that the OS
  /// no longer offers.
  Future<void> refreshAvailability() async {
    final available = await _service.canUseBiometrics();
    var changed = false;
    if (available != _isAvailable) {
      _isAvailable = available;
      changed = true;
    }
    if (available) {
      final kind = await _service.primaryKind();
      if (kind != _kind) {
        _kind = kind;
        changed = true;
      }
    }
    if (!available && _isEnabled) {
      _isEnabled = false;
      await StorageService.setString(
        AppConstants.biometricEnabledKey,
        'false',
      );
      changed = true;
    }
    if (changed) notifyListeners();
  }

  /// Enable requires a confirming scan; disable just clears the flag.
  /// Returns true on success. On a failed enable, returns false and leaves the
  /// toggle disabled (the caller shows an error).
  Future<bool> toggle(bool value, {String reason = ''}) async {
    if (value) {
      final ok = await _service.authenticate(reason: reason);
      if (!ok) {
        notifyListeners();
        return false;
      }
      _isEnabled = true;
      await StorageService.setString(AppConstants.biometricEnabledKey, 'true');
      notifyListeners();
      return true;
    }
    _isEnabled = false;
    await StorageService.setString(AppConstants.biometricEnabledKey, 'false');
    notifyListeners();
    return true;
  }

  /// Used by the lock screen to prompt a scan for unlock.
  Future<bool> authenticate(String reason) =>
      _service.authenticate(reason: reason);

  void onAuthChanged(bool isAuthenticated) {
    // Re-sync the persisted flag on every auth transition. This is read-only:
    // it never writes/clears the key here, so a cold start (which briefly
    // reports `unauthorized` before auth resolves) can't erase a legitimately
    // enabled preference. After logout/account removal the key is already gone
    // from storage, so this drops the stale in-memory "enabled" state.
    final wasEnabled = _isEnabled;
    _loadEnabledFlag();
    if (isAuthenticated) {
      // ignore: discarded_futures
      refreshAvailability();
      notifyListeners();
    } else if (wasEnabled != _isEnabled) {
      notifyListeners();
    }
  }
}
