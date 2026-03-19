import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

const String _logTag = 'QrScannerProvider';

/// Provider for QR scanner logic: camera permission handling.
///
/// Handles permission checking, requesting, and opening app settings.
class QrScannerProvider extends ChangeNotifier {
  QrScannerProvider() {
    developer.log('Camera: Checking initial permission status', name: _logTag);
    _checkPermission();
  }

  ph.PermissionStatus _permissionStatus = ph.PermissionStatus.denied;
  bool _isCheckingPermission = true;

  ph.PermissionStatus get permissionStatus => _permissionStatus;
  bool get isCheckingPermission => _isCheckingPermission;

  bool get isPermissionGranted => _permissionStatus.isGranted;
  bool get isPermissionPermanentlyDenied =>
      _permissionStatus.isPermanentlyDenied;
  bool get canRequestPermission =>
      _permissionStatus.isDenied && !_permissionStatus.isPermanentlyDenied;

  Future<void> _checkPermission() async {
    try {
      final status = await ph.Permission.camera.status;
      _permissionStatus = status;
      _isCheckingPermission = false;
      _logPermissionStatus('Camera: Permission check completed', status);
      notifyListeners();
    } catch (e, stackTrace) {
      developer.log(
        'Camera: Error checking permission: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      _isCheckingPermission = false;
      notifyListeners();
    }
  }

  void _logPermissionStatus(String message, ph.PermissionStatus status) {
    final statusStr = _permissionStatusToString(status);
    developer.log('$message: $statusStr', name: _logTag);
  }

  String _permissionStatusToString(ph.PermissionStatus status) {
    if (status.isGranted) return 'granted';
    if (status.isDenied) return 'denied';
    if (status.isPermanentlyDenied) return 'permanentlyDenied';
    if (status.isRestricted) return 'restricted';
    if (status.isLimited) return 'limited';
    return 'unknown';
  }

  /// Request camera permission from the user.
  Future<void> requestPermission() async {
    developer.log('Camera: Requesting permission from user', name: _logTag);
    try {
      final status = await ph.Permission.camera.request();
      _permissionStatus = status;
      _logPermissionStatus('Camera: Permission request result', status);
      notifyListeners();
    } catch (e, stackTrace) {
      developer.log(
        'Camera: Error requesting permission: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
    }
  }

  /// Open app settings so the user can grant permission manually.
  Future<void> openSettings() async {
    developer.log('Camera: Opening app settings for manual permission grant', name: _logTag);
    await ph.openAppSettings();
    _isCheckingPermission = true;
    notifyListeners();
    await _checkPermission();
  }

  /// Re-check permission status (e.g. after returning from settings).
  Future<void> refreshPermission() async {
    developer.log('Camera: Refreshing permission status', name: _logTag);
    _isCheckingPermission = true;
    notifyListeners();
    await _checkPermission();
  }
}
