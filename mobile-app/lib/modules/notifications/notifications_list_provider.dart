import 'package:flutter/material.dart';

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

  NotificationsListProvider() {
    _items = _createDummyNotifications();
  }

  static List<NotificationItem> _createDummyNotifications() {
    return [
      NotificationItem(
        id: '1',
        title: 'New Transaction Completed',
        description: 'Your payment of 0.5 BTC to [Merchant...',
        date: '8 Aug',
        iconBgColor: const Color(0xFF2196F3),
        icon: Icons.swap_horiz,
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Security Alert',
        description: 'New Login Detected',
        date: '3 July',
        iconBgColor: const Color(0xFFE53935),
        icon: Icons.security,
        isRead: true,
      ),
      NotificationItem(
        id: '3',
        title: 'Important Policy Update',
        description: 'We have updated our user agreemen...',
        date: '22 Jun',
        iconBgColor: const Color(0xFF26A69A),
        icon: Icons.description,
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'Verify Your Account',
        description: 'Your account verification is pending...',
        date: '20 Jun',
        iconBgColor: const Color(0xFFFF9800),
        icon: Icons.person_outline,
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        title: 'Weekly Summary',
        description: 'Your weekly transaction summary is ready.',
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
