import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;
import 'dart:ui' show Color;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../routes/app_router.dart';
import '../constants/constants.dart';
import '../constants/endpoints.dart';
import '../models/push_notification_device_registration_request/push_notification_device_registration_request.dart';
import '../theme/theme.dart';
import 'api_helper.dart';
import 'storage_helper.dart';

/// Top-level FCM background handler. Runs in a separate isolate when the app
/// is in the background or terminated, so it MUST be a top-level (or static)
/// function annotated with `@pragma("vm:entry-point")`.
///
/// For this to display anything, the backend MUST send a **data-only** FCM
/// payload with `awesome_notifications`-compatible keys (at minimum
/// `id`, `channelKey`, `title`, `body`). If the backend sends a `notification`
/// payload, FCM displays its default banner before this handler runs and we
/// cannot suppress it client-side.
@pragma('vm:entry-point')
Future<void> pushNotificationBackgroundHandler(RemoteMessage message) async {
  _logIncomingMessage('background', message);
  if (message.data.isEmpty) return;
  try {
    await AwesomeNotifications().createNotificationFromJsonData(message.data);
  } catch (e) {
    debugPrint('[PushNotification] background createFromJsonData failed: $e');
  }
}

/// Dumps an incoming FCM payload to the debug console so the developer can
/// inspect what the backend sent. Used by both foreground and background
/// handlers — kept top-level so the background handler (separate isolate)
/// can call it.
void _logIncomingMessage(String origin, RemoteMessage message) {
  const tag = '[PushNotification]';
  final notification = message.notification;
  log('$tag $origin payload received');
  log('$tag   messageId: ${message.messageId}');
  log('$tag   from: ${message.from}');
  log('$tag   sentTime: ${message.sentTime}');
  log('$tag   category: ${message.category}');
  log('$tag   collapseKey: ${message.collapseKey}');
  if (notification != null) {
    log('$tag   notification.title: ${notification.title}');
    log('$tag   notification.body: ${notification.body}');
  } else {
    log('$tag   notification: <data-only payload>');
  }
  log('$tag   data: ${message.data}');
}

/// Orchestrates FCM push-notification handling:
///   - Awesome Notifications channel + listener setup.
///   - Bridging FCM messages (foreground/background/terminated) into local
///     notifications shown via Awesome Notifications.
///   - Device registration with the backend.
///   - Token refresh handling.
///
/// Fire-and-forget for registration: every failure path is caught and logged.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const String _logTag = '[PushNotification]';

  /// Default channel used when the backend's payload doesn't specify a
  /// `channelKey`. Backend may set `channelKey` in `data` to target a
  /// different channel registered at init.
  static const String defaultChannelKey = 'omlapay_default';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  StreamSubscription<String>? _refreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  bool Function()? _isAuthenticatedCheck;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initializes Awesome Notifications, registers the FCM background handler,
  /// and wires foreground / opened-app / terminated-tap streams so every
  /// FCM message displays through Awesome Notifications instead of the
  /// default FCM banner (when backend sends data-only payloads).
  ///
  /// Call once from `main()` after `Firebase.initializeApp()` and before
  /// `runApp()`.
  Future<void> initializeNotifications() async {
    final languageCode =
        StorageService.getString(AppConstants.localeKey) ?? 'en';
    await AwesomeNotifications().initialize(
      // null falls back to the application's launcher icon.
      null,
      [
        NotificationChannel(
          channelKey: defaultChannelKey,
          channelName: 'OmlaPay notifications',
          channelGroupKey: 'omlapay_default_group',
          groupKey: 'omlapay_default_group',
          channelDescription: 'General notifications from OmlaPay',
          defaultColor: AppColors.primaryColor,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: kDebugMode,
      languageCode: languageCode,
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
    );

    // Background handler must be registered before runApp(). It runs in a
    // separate isolate when a message arrives while the app is killed or
    // backgrounded.
    FirebaseMessaging.onBackgroundMessage(pushNotificationBackgroundHandler);

    // Foreground messages — display via Awesome Notifications (FCM does not
    // show a banner in foreground by default).
    _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _displayForegroundMessage,
    );

    // User tapped the notification while app was in background.
    _openedAppSubscription?.cancel();
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _routeFromMessage,
    );

    // App was launched (cold start) by tapping a notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _routeFromMessage(initialMessage);
    }

    // Ensure system-level notification permission is granted. Same OS
    // permission as FCM `requestPermission` — calling both is safe.
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // ---------------------------------------------------------------------------
  // Demo / debug
  // ---------------------------------------------------------------------------

  /// Shows a sample local notification through Awesome Notifications without
  /// going through FCM. Use this from a debug menu to verify channel setup,
  /// styling, tap-handling, and OS-level permissions.
  ///
  /// Builds a sample JSON string — same shape the backend would return — then
  /// decodes it with `jsonDecode` and pipes it through
  /// `createNotificationFromJsonData`. This exercises the same code path as
  /// real FCM data messages.
  ///
  /// Logs every step (permission state, raw json, decoded keys, scheduling
  /// result, errors) so silent failures are debuggable from the console.
  ///
  /// Returns `true` if the notification was scheduled, `false` otherwise.
  Future<bool> showDemoNotification({
    String title = 'OmlaPay test notification',
    String body =
        'If you can see this, Awesome Notifications is wired up correctly.',
  }) async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      log('$_logTag demo: isNotificationAllowed=$isAllowed');
      if (!isAllowed) {
        final granted = await AwesomeNotifications()
            .requestPermissionToSendNotifications();
        log('$_logTag demo: requestPermission granted=$granted');
        if (!granted) {
          debugPrint(
            '$_logTag demo skipped — permission denied. '
            'Enable in Settings → OmlaPay → Notifications.',
          );
          return false;
        }
      }

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
        1 << 31,
      );

      // Sample JSON the API/backend would return. Encoding both the outer
      // wrapper and the `payload` inner map as strings mirrors how FCM
      // actually transports nested data (`Map<String, String>` only).
      final String apiJsonResponse = jsonEncode({
        'content': {
          'id': notificationId,
          'channelKey': defaultChannelKey,
          'title': title,
          'body': body,
          'notificationLayout': 'Default',
          'wakeUpScreen': true,
        },
        'payload': {'source': 'demo'},
      });
      log('$_logTag demo: api json = $apiJsonResponse');

      final Map<String, dynamic> decoded =
          jsonDecode(apiJsonResponse) as Map<String, dynamic>;
      log('$_logTag demo: decoded keys = ${decoded.keys.toList()}');

      final scheduled = await AwesomeNotifications()
          .createNotificationFromJsonData(decoded);
      log('$_logTag demo: createNotificationFromJsonData scheduled=$scheduled');
      return scheduled;
    } catch (e, stack) {
      debugPrint('$_logTag demo notification failed: $e');
      debugPrintStack(stackTrace: stack, label: _logTag);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Display bridging (FCM → Awesome Notifications)
  // ---------------------------------------------------------------------------

  Future<void> _displayForegroundMessage(RemoteMessage message) async {
    _logIncomingMessage('foreground', message);

    // Preferred path: backend sends data-only payload with
    // awesome_notifications-compatible keys.
    if (message.data.isNotEmpty) {
      try {
        await AwesomeNotifications().createNotificationFromJsonData(
          message.data,
        );
        return;
      } catch (e) {
        debugPrint('$_logTag createFromJsonData failed, falling back: $e');
      }
    }

    // Fallback: build a notification from `message.notification` (when
    // backend sends a `notification` payload) or from generic `title`/`body`
    // keys in `data`.
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) {
      debugPrint('$_logTag onMessage with no displayable content — skipping');
      return;
    }

    final payload = <String, String>{
      for (final entry in message.data.entries)
        entry.key: entry.value.toString(),
    };

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
          channelKey: defaultChannelKey,
          title: title,
          body: body,
          payload: payload,
          notificationLayout: NotificationLayout.Default,
        ),
      );
    } catch (e) {
      debugPrint('$_logTag fallback createNotification failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Tap → navigation
  // ---------------------------------------------------------------------------

  void _routeFromMessage(RemoteMessage message) {
    _navigateToNotificationsList();
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    instance._navigateToNotificationsList();
  }

  void _navigateToNotificationsList() {
    try {
      AppRouter.router.go(Routes.notifications);
    } catch (e) {
      debugPrint('$_logTag tap routing failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Backend registration
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Device info helpers
  // ---------------------------------------------------------------------------

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
