import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Provides a stable per-device identifier used as the `macAddress` for
/// guest support-request endpoints.
///
/// Real MAC addresses are not exposed to apps on modern iOS / Android
/// (both platforms return the placeholder `02:00:00:00:00:00` to
/// non-privileged apps). To still satisfy backends that require a
/// `xx:xx:xx:xx:xx:xx` shape, we derive a stable 6-byte value by hashing
/// the platform's vendor identifier (IDFV on iOS, fingerprint on Android)
/// with SHA-256 and formatting the first 6 bytes as colon-separated hex.
///
/// The result is deterministic per-install on the same device, so the
/// backend can use it as a guest-scope key — but it is **not** a real
/// hardware MAC address.
///
/// Cached in memory for the process lifetime so repeated calls don't
/// re-hit the platform channel.
class DeviceIdentifierService {
  DeviceIdentifierService._();

  static final DeviceIdentifierService instance = DeviceIdentifierService._();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _cachedId;

  /// Returns a MAC-style identifier (`xx:xx:xx:xx:xx:xx`) derived from
  /// the device's vendor identifier, or `null` when the underlying
  /// platform call fails or the platform is unsupported.
  Future<String?> getDeviceIdentifier() async {
    if (_cachedId != null && _cachedId!.isNotEmpty) return _cachedId;

    final rawId = await _readRawDeviceId();
    if (rawId == null || rawId.isEmpty) return null;

    _cachedId = _formatAsMacAddress(rawId);
    return _cachedId;
  }

  Future<String?> _readRawDeviceId() async {
    try {
      if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return info.identifierForVendor;
      }
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return info.fingerprint;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Hashes [seed] with SHA-256 and formats the first 6 bytes as a
  /// colon-separated hex string (`xx:xx:xx:xx:xx:xx`, uppercase).
  String _formatAsMacAddress(String seed) {
    final digest = sha256.convert(utf8.encode(seed));
    final bytes = digest.bytes.take(6).toList();
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }
}
