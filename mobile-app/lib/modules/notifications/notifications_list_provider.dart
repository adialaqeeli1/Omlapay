import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';

/// In-memory notification item. State is not persisted; reset each time screen opens.
class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String date;
  final Color iconBgColor;
  final IconData icon;

  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.iconBgColor,
    required this.icon,
    this.isRead = false,
  });
}

class NotificationsListProvider extends ChangeNotifier {
  late final List<NotificationItem> _items;

  List<NotificationItem> get items => _items;

  int get unreadCount => _items.where((e) => !e.isRead).length;

  NotificationsListProvider(AppLocalizations l10n) {
    _items = _createDummyNotifications(l10n);
  }

  static List<NotificationItem> _createDummyNotifications(AppLocalizations l10n) {
    return [
      NotificationItem(
        id: '1',
        title: l10n.notificationMockNewTransactionTitle,
        description: l10n.notificationMockNewTransactionBody,
        date: '8 Aug',
        iconBgColor: const Color(0xFF2196F3),
        icon: Icons.swap_horiz,
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: l10n.notificationMockSecurityTitle,
        description: l10n.notificationMockSecurityBody,
        date: '3 July',
        iconBgColor: const Color(0xFFE53935),
        icon: Icons.security,
        isRead: true,
      ),
      NotificationItem(
        id: '3',
        title: l10n.notificationMockPolicyTitle,
        description: l10n.notificationMockPolicyBody,
        date: '22 Jun',
        iconBgColor: const Color(0xFF26A69A),
        icon: Icons.description,
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: l10n.notificationMockVerifyTitle,
        description: l10n.notificationMockVerifyBody,
        date: '20 Jun',
        iconBgColor: const Color(0xFFFF9800),
        icon: Icons.person_outline,
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        title: l10n.notificationMockWeeklyTitle,
        description: l10n.notificationMockWeeklyBody,
        date: '15 Jun',
        iconBgColor: const Color(0xFF9C27B0),
        icon: Icons.summarize,
        isRead: false,
      ),
    ];
  }

  void markAsRead(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1 && !_items[index].isRead) {
      _items[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (final item in _items) {
      if (!item.isRead) {
        item.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }
}
