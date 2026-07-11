import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../utils/app_logger.dart';

/// The kind of biometric a device offers, used to pick the right UI icon.
///
/// We only distinguish face vs fingerprint. Android often reports a generic
/// `strong`/`weak` class instead of the modality, so anything that isn't
/// explicitly face is treated as fingerprint (the common default).
enum BiometricKind { face, fingerprint }

/// Thin wrapper around the `local_auth` plugin. The single place that touches
/// the biometric platform channel. All methods are non-throwing.
class BiometricService {
  BiometricService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// True only when the device supports biometrics AND at least one biometric
  /// (Face ID / fingerprint) is enrolled.
  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } catch (e) {
      appLog('BiometricService.canUseBiometrics error: $e');
      return false;
    }
  }

  /// The primary enrolled biometric modality, used to choose the UI icon.
  /// Returns face only when Face ID / face unlock is explicitly enrolled;
  /// otherwise fingerprint. Never throws.
  Future<BiometricKind> primaryKind() async {
    try {
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.contains(BiometricType.face)
          ? BiometricKind.face
          : BiometricKind.fingerprint;
    } catch (e) {
      appLog('BiometricService.primaryKind error: $e');
      return BiometricKind.fingerprint;
    }
  }

  /// Prompts a biometric scan. Returns true only on a successful scan.
  /// Returns false (never throws) on cancel, lockout, or unavailability.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on PlatformException catch (e) {
      appLog('BiometricService.authenticate error: ${e.code}');
      return false;
    } catch (e) {
      appLog('BiometricService.authenticate error: $e');
      return false;
    }
  }
}
