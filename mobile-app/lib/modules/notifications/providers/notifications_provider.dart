import 'package:flutter/material.dart';

import '../../../core/models/notification/notification_model.dart';
import '../../../core/utils/app_exception.dart';
import '../services/notifications_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsService _service;

  NotificationsProvider({NotificationsService? service})
      : _service = service ?? NotificationsService();

  List<NotificationModel> _items = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _nextCursor;
  String? _errorMessage;

  List<NotificationModel> get items => _items;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.fetchNotifications();
      _items = response.notifications;
      _unreadCount = response.unreadCount;
      _hasMore = response.pagination?.hasMore ?? false;
      _nextCursor = response.pagination?.nextCursor;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load notifications';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _service.fetchNotifications(
        cursor: _nextCursor,
      );
      _items = [..._items, ...response.notifications];
      _unreadCount = response.unreadCount;
      _hasMore = response.pagination?.hasMore ?? false;
      _nextCursor = response.pagination?.nextCursor;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load more notifications';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void markAsRead(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1 && !_items[index].isRead) {
      _items[index] = _items[index].copyWith(isRead: true);
      _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (int i = 0; i < _items.length; i++) {
      if (!_items[i].isRead) {
        _items[i] = _items[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      _unreadCount = 0;
      notifyListeners();
    }
  }
}
