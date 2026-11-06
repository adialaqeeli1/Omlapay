import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

/// Keeps the login secrets in the phone's secure storage instead of
/// SharedPreferences: iOS Keychain ("this device only": never synced to
/// iCloud or restored onto another phone) and, on Android, values encrypted
/// with a key held in the Android Keystore (the key cannot be backed up).
///
/// The app reads tokens synchronously in many places, so [init] loads them
/// into memory once at start and every change is written through to secure
/// storage. [StorageService] sends these keys here automatically.
class SecureTokenStore {
  SecureTokenStore._();

  /// Session access token, refresh token and remembered-device token.
  static const Set<String> keys = {
    AppConstants.tokenKey,
    AppConstants.refreshTokenKey,
    AppConstants.rememberedDeviceTokenKey,
  };

  /// Set in SharedPreferences once secure storage has been set up on this
  /// install (see [init]).
  static const String _readyFlag = 'secure_token_store_ready';

  static const FlutterSecureStorage _defaultStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static FlutterSecureStorage _storage = _defaultStorage;
  static final Map<String, String> _cache = {};

  /// Tests only: use another storage instance.
  @visibleForTesting
  static set storage(FlutterSecureStorage storage) => _storage = storage;

  @visibleForTesting
  static void resetForTest() {
    _storage = _defaultStorage;
    _cache.clear();
  }

  /// Loads the tokens. On the first start after installing (or after this
  /// update):
  /// - clears secure storage, because the iOS Keychain keeps items after the
  ///   app is deleted, and a reinstall must start logged out;
  /// - moves tokens saved in SharedPreferences by older versions into secure
  ///   storage, then deletes them from SharedPreferences.
  static Future<void> init(SharedPreferences prefs) async {
    _cache.clear();
    try {
      if (prefs.getBool(_readyFlag) != true) {
        for (final key in keys) {
          await _storage.delete(key: key);
        }
        for (final key in keys) {
          final old = prefs.getString(key);
          if (old != null && old.isNotEmpty) {
            await _storage.write(key: key, value: old);
          }
        }
        await prefs.setBool(_readyFlag, true);
      }
      for (final key in keys) {
        final value = await _storage.read(key: key);
        if (value != null) _cache[key] = value;
      }
    } catch (e) {
      // Secure storage unavailable (e.g. Keystore error): keep only what is in
      // memory. The user may have to log in again; tokens never fall back to
      // plain storage.
      debugPrint('SecureTokenStore init failed: $e');
    } finally {
      // Never leave tokens in plain storage, whatever happened above.
      for (final key in keys) {
        if (prefs.containsKey(key)) await prefs.remove(key);
      }
    }
  }

  static String? read(String key) => _cache[key];

  static Future<bool> write(String key, String value) async {
    _cache[key] = value;
    try {
      await _storage.write(key: key, value: value);
      return true;
    } catch (e) {
      debugPrint('SecureTokenStore write failed: $e');
      return false;
    }
  }

  static Future<bool> delete(String key) async {
    _cache.remove(key);
    try {
      await _storage.delete(key: key);
      return true;
    } catch (e) {
      debugPrint('SecureTokenStore delete failed: $e');
      return false;
    }
  }

  static Future<void> deleteAll() async {
    for (final key in keys) {
      await delete(key);
    }
  }
}
