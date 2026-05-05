import 'dart:async';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../constants/endpoints.dart';
import '../models/push_notification_device_registration_request/push_notification_device_registration_request.dart';
import 'api_helper.dart';

/// Orchestrates FCM push-notification device registration with the backend.
///
/// Fire-and-forget: every failure path is caught and logged; nothing is
/// rethrown. Safe to call from any auth-success site.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const String _logTag = '[PushNotification]';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  StreamSubscription<String>? _refreshSubscription;
  bool Function()? _isAuthenticatedCheck;

  /// Registers the current device's FCM token with the backend.
  ///
  /// Sequence:
  ///   1. Request push permission (no-op if already granted).
  ///   2. Fetch the FCM token. If null → log + return.
  ///   3. Read `device_uuid` and `device_model` from device_info_plus.
  ///      If `device_uuid` is null/empty → log + return.
  ///   4. POST to `/v1/notifications/devices`.
  ///
  /// All exceptions are caught and logged. Never rethrows.
  Future<void> registerCurrentDevice() async {
    try {
      await _messaging.requestPermission();

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('$_logTag getToken returned null/empty — skipping');
        return;
      }

      final uuid = await _readDeviceUuid();
      if (uuid == null || uuid.isEmpty) {
        debugPrint('$_logTag device_uuid unavailable — skipping');
        return;
      }

      final model = await _readDeviceModel();

      await _registerWithBackend(
        deviceToken: token,
        deviceModel: model,
        deviceUuid: uuid,
      );
      debugPrint('$_logTag registered device successfully');
    } catch (e, stack) {
      debugPrint('$_logTag registration failed: $e');
      debugPrintStack(stackTrace: stack, label: _logTag);
    }
  }

  /// Sends the FCM device registration to the backend.
  /// POSTs to `/v1/notifications/devices`. Auth header is auto-injected by
  /// the network layer. Throws on network/API failure — caller swallows.
  Future<void> _registerWithBackend({
    required String deviceToken,
    required String deviceModel,
    required String deviceUuid,
  }) async {
    final body = PushNotificationDeviceRegistrationRequest(
      deviceToken: deviceToken,
      deviceModel: deviceModel,
      deviceUuid: deviceUuid,
    ).toJson();
    await ApiHelper.post(Endpoints.pushNotificationDevices, body);
  }

  /// Subscribes to FCM token-refresh events. When a refresh fires and the
  /// user is currently authenticated (per [isAuthenticated]), re-registers
  /// the new token. Idempotent — calling twice replaces the previous
  /// subscription.
  void startTokenRefreshListener({required bool Function() isAuthenticated}) {
    _isAuthenticatedCheck = isAuthenticated;
    _refreshSubscription?.cancel();
    _refreshSubscription = _messaging.onTokenRefresh.listen(
      (_) {
        if (_isAuthenticatedCheck?.call() == true) {
          unawaited(registerCurrentDevice());
        } else {
          debugPrint('$_logTag token refresh ignored — not authenticated');
        }
      },
      onError: (Object error) {
        debugPrint('$_logTag onTokenRefresh error: $error');
      },
    );
  }

  Future<String?> _readDeviceUuid() async {
    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return info.identifierForVendor;
    }
    if (Platform.isAndroid) {
      // device_info_plus does not expose Settings.Secure.ANDROID_ID or any
      // per-device unique identifier. fingerprint is the longest, most stable
      // string available in the package. It is unique per (device + OS build),
      // not per physical device — backend should treat (device_token,
      // device_uuid) as the effective uniqueness key.
      final info = await _deviceInfo.androidInfo;
      return info.fingerprint;
    }
    return null;
  }

  Future<String> _readDeviceModel() async {
    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return info.utsname.machine;
    }
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return info.model;
    }
    return 'unknown';
  }
}
