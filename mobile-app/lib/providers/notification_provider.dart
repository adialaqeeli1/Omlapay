import 'package:flutter/foundation.dart';
import '../core/services/storage_helper.dart';
import '../core/constants/constants.dart';

class NotificationProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;

  NotificationProvider() {
    _loadNotificationSettings();
  }

  void _loadNotificationSettings() {
    final savedValue = StorageService.getString(AppConstants.notificationEnabledKey);
    if (savedValue != null) {
      _notificationsEnabled = savedValue == 'true';
    } else {
      _notificationsEnabled = true; // Default to enabled
    }
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await StorageService.setString(
      AppConstants.notificationEnabledKey,
      enabled.toString(),
    );
    notifyListeners();
  }
}
