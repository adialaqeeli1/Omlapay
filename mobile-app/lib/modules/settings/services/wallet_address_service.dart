import '../../../core/models/user_model/user_model.dart';
import '../../../core/services/storage_helper.dart';
import '../../../core/constants/constants.dart';
import 'dart:convert';

class WalletAddressService {
  static const String walletAddressesKey = 'user_wallet_addresses';

  /// Get wallet addresses for a user
  static Map<String, String> getWalletAddresses(UserModel user) {
    final data = StorageService.getString(walletAddressesKey);
    if (data == null) {
      // Generate default wallet addresses if none exist
      final defaultAddresses = _generateDefaultAddresses(user);
      saveWalletAddresses(user, defaultAddresses);
      return defaultAddresses;
    }

    try {
      final Map<String, dynamic> addressesJson = jsonDecode(data);
      final userKey = '${user.countryCode}${user.mobileNumber}';
      if (addressesJson.containsKey(userKey)) {
        return Map<String, String>.from(addressesJson[userKey] as Map);
      } else {
        final defaultAddresses = _generateDefaultAddresses(user);
        saveWalletAddresses(user, defaultAddresses);
        return defaultAddresses;
      }
    } catch (e) {
      final defaultAddresses = _generateDefaultAddresses(user);
      saveWalletAddresses(user, defaultAddresses);
      return defaultAddresses;
    }
  }

  /// Save wallet addresses for a user
  static Future<void> saveWalletAddresses(
    UserModel user,
    Map<String, String> addresses,
  ) async {
    final data = StorageService.getString(walletAddressesKey);
    Map<String, dynamic> addressesJson = {};
    
    if (data != null) {
      try {
        addressesJson = jsonDecode(data) as Map<String, dynamic>;
      } catch (e) {
        addressesJson = {};
      }
    }

    final userKey = '${user.countryCode}${user.mobileNumber}';
    addressesJson[userKey] = addresses;

    await StorageService.setString(
      walletAddressesKey,
      jsonEncode(addressesJson),
    );
  }

  /// Generate default wallet addresses for a user
  static Map<String, String> _generateDefaultAddresses(UserModel user) {
    // Generate deterministic addresses based on user phone number
    final seed = user.mobileNumber.hashCode.abs();
    return {
      'EVM': '0x${_generateHexAddress(seed, 40)}',
      'Bitcoin': _generateBitcoinAddress(seed),
      'Tron': 'T${_generateHexAddress(seed + 1000, 33)}',
      'Solana': _generateSolanaAddress(seed),
    };
  }

  static String _generateHexAddress(int seed, int length) {
    final chars = '0123456789abcdef';
    String address = '';
    for (int i = 0; i < length; i++) {
      address += chars[(seed + i * 7) % chars.length];
    }
    return address;
  }

  static String _generateBitcoinAddress(int seed) {
    // Bitcoin addresses typically start with 1, 3, or bc1
    final chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    String address = '1'; // Most common format
    for (int i = 0; i < 33; i++) {
      address += chars[(seed + i * 11) % chars.length];
    }
    return address;
  }

  static String _generateSolanaAddress(int seed) {
    // Solana addresses use base58 encoding, typically 32-44 characters
    final chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    String address = '';
    for (int i = 0; i < 44; i++) {
      address += chars[(seed + i * 13) % chars.length];
    }
    return address;
  }

  /// Get email for user (mock - in real app this would come from user model or API)
  static String getUserEmail(UserModel user) {
    // Generate a mock email based on user data
    final email = '${user.firstName.toLowerCase()}.${user.lastName.toLowerCase()}@gmail.com';
    return email;
  }
}
