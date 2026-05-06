import 'package:flutter/foundation.dart';

import '../core/constants/constants.dart';
import '../core/constants/endpoints.dart';
import '../core/services/api_helper.dart';
import '../core/services/storage_helper.dart';

class NotificationProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _hasFetchedFromServer = false;
  bool _isAuthenticated = false;

  bool get notificationsEnabled => _notificationsEnabled;

  NotificationProvider() {
    _loadNotificationSettings();
  }

  void _loadNotificationSettings() {
    final savedValue =
        StorageService.getString(AppConstants.notificationEnabledKey);
    if (savedValue != null) {
      _notificationsEnabled = savedValue == 'true';
    } else {
      _notificationsEnabled = true; // Default to enabled
    }
    notifyListeners();
  }

  void onAuthChanged(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    if (isAuthenticated) {
      if (!_hasFetchedFromServer) {
        _fetchNotificationSetting();
      }
    } else {
      _hasFetchedFromServer = false;
    }
  }

  /// Re-fetches the latest server value, bypassing the once-per-session gate.
  /// Used by screens (e.g. Settings) that should always show fresh state on
  /// open, even if the user is bouncing in and out of the screen.
  Future<void> refreshFromServer() async {
    if (!_isAuthenticated) return;
    await _fetchNotificationSetting();
  }

  Future<void> _fetchNotificationSetting() async {
    _hasFetchedFromServer = true;

    try {
      final response =
          await ApiHelper.get(Endpoints.userSettingsNotifications);
      final enabled = response['data']?['notifications_enabled'] as bool?;
      if (enabled != null && _notificationsEnabled != enabled) {
        _notificationsEnabled = enabled;
        await StorageService.setString(
          AppConstants.notificationEnabledKey,
          enabled.toString(),
        );
        notifyListeners();
      }
    } catch (_) {
      // API failed, keep locally saved value.
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    final previous = _notificationsEnabled;
    _notificationsEnabled = enabled;
    await StorageService.setString(
      AppConstants.notificationEnabledKey,
      enabled.toString(),
    );
    notifyListeners();

    if (!_isAuthenticated) return;

    try {
      await ApiHelper.put(
        Endpoints.userSettingsNotifications,
        {'notifications_enabled': enabled},
      );
    } catch (_) {
      // Roll back on failure so the UI reflects the actual server state.
      _notificationsEnabled = previous;
      await StorageService.setString(
        AppConstants.notificationEnabledKey,
        previous.toString(),
      );
      notifyListeners();
      rethrow;
    }
  }
}
