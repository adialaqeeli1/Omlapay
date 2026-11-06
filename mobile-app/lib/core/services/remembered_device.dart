import '../constants/constants.dart';
import 'device_identifier_service.dart';
import 'storage_helper.dart';

/// Remembered-device login (backend: POST /v1/auth/login/passcode).
///
/// The backend gives this phone a `device_token` only after an SMS check on it: SMS login,
/// registration or forgot-passcode reset. With it, the app can log in again with the passcode
/// alone (used right after registration, passcode reset, passcode change, turning off 2FA and
/// phone change). Without it, the backend answers 401 DEVICE_NOT_TRUSTED and the user logs in
/// with an SMS code. The token expires after 30 days and is revoked by logout.
///
/// Not the push-notification device token (see PushNotificationService).
class RememberedDevice {
  RememberedDevice._();

  /// The saved device token, or null if this phone is not remembered.
  static String? get token =>
      StorageService.getString(AppConstants.rememberedDeviceTokenKey);

  /// Saves `data.device_token` from a login, registration or passcode-reset response.
  static Future<void> saveFromResponse(Map<String, dynamic> response) async {
    final data = response['data'];
    final token = data is Map ? data['device_token']?.toString() : null;
    if (token != null && token.isNotEmpty) {
      await StorageService.setString(
        AppConstants.rememberedDeviceTokenKey,
        token,
      );
    }
  }

  static Future<void> forget() =>
      StorageService.remove(AppConstants.rememberedDeviceTokenKey);

  /// `{'device_id': …}` for requests that issue or use a device token (empty if unavailable).
  static Future<Map<String, dynamic>> deviceIdField() async {
    final id = await DeviceIdentifierService.instance.getDeviceIdentifier();
    return id == null || id.isEmpty ? {} : {'device_id': id};
  }
}
