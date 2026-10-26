import 'dart:async';
import 'dart:convert';
import 'package:omlapay_mobile_app/core/utils/app_logger.dart';
import 'dart:io' show Platform;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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
  appLog('$tag $origin payload received');
  appLog('$tag   messageId: ${message.messageId}');
  appLog('$tag   from: ${message.from}');
  appLog('$tag   sentTime: ${message.sentTime}');
  appLog('$tag   category: ${message.category}');
  appLog('$tag   collapseKey: ${message.collapseKey}');
  if (notification != null) {
    appLog('$tag   notification.title: ${notification.title}');
    appLog('$tag   notification.body: ${notification.body}');
  } else {
    appLog('$tag   notification: <data-only payload>');
  }
  appLog('$tag   data: ${message.data}');
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
    appLog('$_logTag initializeNotifications: start');
    final languageCode =
        StorageService.getString(AppConstants.localeKey) ?? 'en';
    appLog('$_logTag initializeNotifications: languageCode=$languageCode');
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
    appLog('$_logTag initializeNotifications: AwesomeNotifications listeners set');

    // Background handler must be registered before runApp(). It runs in a
    // separate isolate when a message arrives while the app is killed or
    // backgrounded.
    FirebaseMessaging.onBackgroundMessage(pushNotificationBackgroundHandler);
    appLog('$_logTag initializeNotifications: FCM background handler registered');

    // Foreground messages — display via Awesome Notifications (FCM does not
    // show a banner in foreground by default).
    _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _displayForegroundMessage,
    );
    appLog('$_logTag initializeNotifications: onMessage subscribed');

    // User tapped the notification while app was in background.
    _openedAppSubscription?.cancel();
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _routeFromMessage,
    );
    appLog('$_logTag initializeNotifications: onMessageOpenedApp subscribed');

    // App was launched (cold start) by tapping a notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      appLog(
        '$_logTag initializeNotifications: cold-start tap detected '
        '(messageId=${initialMessage.messageId})',
      );
      _routeFromMessage(initialMessage);
    } else {
      appLog('$_logTag initializeNotifications: no cold-start tap');
    }

    // Ensure system-level notification permission is granted. Same OS
    // permission as FCM `requestPermission` — calling both is safe.
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    appLog('$_logTag initializeNotifications: isNotificationAllowed=$isAllowed');
    if (!isAllowed) {
      final granted = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
      appLog(
        '$_logTag initializeNotifications: requestPermission granted=$granted',
      );
    }
    appLog('$_logTag initializeNotifications: done');
  }

  // ---------------------------------------------------------------------------
  // App-icon badge
  // ---------------------------------------------------------------------------

  /// Syncs the OS app-icon (launcher) badge to [count] — the backend
  /// unread-notifications count.
  ///
  /// Why this is needed: the default channel has `channelShowBadge: true`, so
  /// on iOS awesome_notifications auto-increments the global badge counter for
  /// every notification it displays. Without an authoritative reset the badge
  /// grows unbounded and never reflects the real unread state (it keeps a stale
  /// number even after the user reads everything). Call this whenever a fresh
  /// unread count is known — home fetch, notifications fetch/load-more,
  /// mark-as-read, mark-all-read. Pass 0 to clear the badge.
  ///
  /// Never throws — badge support is best-effort and varies by launcher.
  Future<void> syncAppBadge(int count) async {
    final safe = count < 0 ? 0 : count;
    try {
      await AwesomeNotifications().setGlobalBadgeCounter(safe);
      appLog('$_logTag syncAppBadge: set badge=$safe');
    } catch (e) {
      debugPrint('$_logTag syncAppBadge failed: $e');
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
  ///
  /// [delay] — when greater than zero, schedules the notification to fire
  /// after the given duration via [NotificationInterval]. Useful for testing
  /// the auth-gated / app-locked tap flow: trigger this with a 10s delay,
  /// then log out or background the app, then tap the notification when it
  /// fires to verify the deep-link replay path.
  Future<bool> showDemoNotification({
    String title = 'OmlaPay test notification',
    String body =
        'If you can see this, Awesome Notifications is wired up correctly.',
    Duration delay = Duration.zero,
  }) async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      appLog('$_logTag demo: isNotificationAllowed=$isAllowed');
      if (!isAllowed) {
        final granted = await AwesomeNotifications()
            .requestPermissionToSendNotifications();
        appLog('$_logTag demo: requestPermission granted=$granted');
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

      if (delay > Duration.zero) {
        // Scheduled path. Uses `createNotification` (not the JSON helper)
        // so we can attach a `NotificationInterval` schedule. The tap still
        // flows through `_onActionReceivedMethod` → `_navigateToNotificationsList`,
        // which is the exact path real FCM taps take.
        appLog(
          '$_logTag demo: scheduling in ${delay.inSeconds}s '
          'id=$notificationId',
        );
        final scheduled = await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId,
            channelKey: defaultChannelKey,
            title: title,
            body: body,
            notificationLayout: NotificationLayout.Default,
            wakeUpScreen: true,
            payload: const {'source': 'demo_scheduled'},
          ),
          schedule: NotificationInterval(
            interval: delay,
            preciseAlarm: true,
            allowWhileIdle: true,
            repeats: false,
          ),
        );
        appLog('$_logTag demo: createNotification scheduled=$scheduled');
        return scheduled;
      }

      // Immediate path. Sample JSON mirrors what the backend would return
      // and exercises the same `createNotificationFromJsonData` code path
      // as real FCM data messages.
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
      appLog('$_logTag demo: api json = $apiJsonResponse');

      final Map<String, dynamic> decoded =
          jsonDecode(apiJsonResponse) as Map<String, dynamic>;
      appLog('$_logTag demo: decoded keys = ${decoded.keys.toList()}');

      final scheduled = await AwesomeNotifications()
          .createNotificationFromJsonData(decoded);
      appLog('$_logTag demo: createNotificationFromJsonData scheduled=$scheduled');
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

  /// Remembered destination from the most recent notification tap. Kept
  /// across login / app-lock overlays so the user lands on the intended
  /// screen instead of `home` after the auth gate is cleared. Cleared once
  /// replayed.
  String? _pendingDeepLink;

  void _routeFromMessage(RemoteMessage message) {
    appLog(
      '$_logTag tap (FCM): messageId=${message.messageId} '
      'data=${message.data}',
    );
    _navigateToNotificationsList();
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    appLog(
      '$_logTag tap (AwesomeNotifications): id=${receivedAction.id} '
      'channelKey=${receivedAction.channelKey} '
      'buttonKeyPressed=${receivedAction.buttonKeyPressed} '
      'payload=${receivedAction.payload}',
    );
    instance._navigateToNotificationsList();
  }

  void _navigateToNotificationsList() {
    // Stash the intent BEFORE attempting navigation so it survives the
    // auth-middleware redirect (unauthenticated → loginOrRegister) and the
    // AppLockProvider passcode overlay. `replayPendingDeepLink` flushes it
    // after the user signs in or unlocks.
    _pendingDeepLink = Routes.notifications;

    final isAuthed = StorageService.getString(AppConstants.tokenKey) != null;
    final target = isAuthed ? Routes.notifications : Routes.loginOrRegister;
    appLog(
      '$_logTag navigate: isAuthed=$isAuthed pending=$_pendingDeepLink '
      'target=$target',
    );

    // Defer to the next frame. Two reasons:
    //   1. Background-resume tap: when the user taps a banner while the app
    //      was paused/hidden, `_onActionReceivedMethod` can fire before
    //      Flutter has composited a frame post-resume. A synchronous
    //      `router.go` in that window is silently lost and the user lands
    //      on whatever screen they minimized from.
    //   2. Foreground tap: `addPostFrameCallback` runs after the current
    //      microtask, which is harmless (sub-frame latency).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        AppRouter.router.go(target);
        appLog('$_logTag navigate: router.go($target) dispatched (post-frame)');
        // Only clear when we reached the actual final destination. The
        // `loginOrRegister` redirect path leaves the pending intent in
        // place so `replayPendingDeepLink` can flush it after auth completes.
        if (isAuthed && _pendingDeepLink == Routes.notifications) {
          _pendingDeepLink = null;
          appLog('$_logTag navigate: cleared pending deep link');
        }
      } catch (e) {
        debugPrint('$_logTag tap routing failed: $e');
      }
    });
  }

  /// Replays the pending notification deep link (if any). Call after a
  /// successful login / soft-login so the user lands on the screen they
  /// tapped from instead of `home`. Scheduled on the next frame so it wins
  /// over the auth screen's own `context.go(Routes.home)`.
  void replayPendingDeepLink() {
    final target = _pendingDeepLink;
    if (target == null) {
      appLog('$_logTag replayPendingDeepLink: nothing to replay');
      return;
    }
    _pendingDeepLink = null;
    appLog('$_logTag replayPendingDeepLink: scheduling go($target) post-frame');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        AppRouter.router.go(target);
        appLog('$_logTag replayPendingDeepLink: router.go($target) dispatched');
      } catch (e) {
        debugPrint('$_logTag deep-link replay failed: $e');
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Backend registration
  // ---------------------------------------------------------------------------

  /// Returns the current device's FCM registration token, or `null` if it
  /// can't be retrieved. Never throws — used by best-effort flows like logout.
  Future<String?> currentDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        appLog('$_logTag currentDeviceToken: null/empty');
        return null;
      }
      appLog('$_logTag currentDeviceToken: ${_redactToken(token)}');
      return token;
    } catch (e) {
      debugPrint('$_logTag currentDeviceToken failed: $e');
      return null;
    }
  }

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
    appLog('$_logTag registerCurrentDevice: start');
    try {
      final settings = await _messaging.requestPermission();
      appLog(
        '$_logTag registerCurrentDevice: permission '
        'authorizationStatus=${settings.authorizationStatus.name}',
      );

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('$_logTag getToken returned null/empty — skipping');
        return;
      }
      appLog('$_logTag registerCurrentDevice: token=${_redactToken(token)}');

      final uuid = await _readDeviceUuid();
      if (uuid == null || uuid.isEmpty) {
        debugPrint('$_logTag device_uuid unavailable — skipping');
        return;
      }

      final model = await _readDeviceModel();
      appLog(
        '$_logTag registerCurrentDevice: device model=$model '
        'uuid=${_redactToken(uuid)}',
      );

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

  /// Returns a short, log-safe representation of a token / UUID: first 6 and
  /// last 4 characters with the middle elided. Use whenever a sensitive
  /// identifier needs to land in console output.
  String _redactToken(String value) {
    if (value.length <= 12) return '****';
    return '${value.substring(0, 6)}…${value.substring(value.length - 4)} '
        '(len=${value.length})';
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
    appLog('$_logTag startTokenRefreshListener: attached');
    _isAuthenticatedCheck = isAuthenticated;
    _refreshSubscription?.cancel();
    _refreshSubscription = _messaging.onTokenRefresh.listen(
      (token) {
        appLog(
          '$_logTag onTokenRefresh: fired token=${_redactToken(token)} '
          'authed=${_isAuthenticatedCheck?.call() == true}',
        );
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
