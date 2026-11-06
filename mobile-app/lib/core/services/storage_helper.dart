import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'secure_token_store.dart';

/// Local storage. Login secrets ([SecureTokenStore.keys]: session tokens and
/// the remembered-device token) go to the phone's secure storage
/// (Keychain / Android Keystore); everything else to SharedPreferences.
class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await SecureTokenStore.init(_prefs!);
  }

  static Future<bool> setString(String key, String value) async {
    if (SecureTokenStore.keys.contains(key)) {
      return SecureTokenStore.write(key, value);
    }
    return await _prefs?.setString(key, value) ?? false;
  }

  static String? getString(String key) {
    if (SecureTokenStore.keys.contains(key)) return SecureTokenStore.read(key);
    return _prefs?.getString(key);
  }

  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await setString(key, jsonEncode(value));
  }

  static Map<String, dynamic>? getJson(String key) {
    final value = getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<bool> remove(String key) async {
    if (SecureTokenStore.keys.contains(key)) {
      return SecureTokenStore.delete(key);
    }
    return await _prefs?.remove(key) ?? false;
  }

  static Future<bool> clear() async {
    await SecureTokenStore.deleteAll();
    return await _prefs?.clear() ?? false;
  }
}

