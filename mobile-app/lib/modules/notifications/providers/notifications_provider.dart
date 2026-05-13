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
  bool _isActionLoading = false;
  bool _hasMore = false;
  String? _nextCursor;
  String? _errorKey;

  List<NotificationModel> get items => _items;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isActionLoading => _isActionLoading;
  bool get hasMore => _hasMore;
  String? get errorKey => _errorKey;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorKey = null;
    notifyListeners();

    try {
      final response = await _service.fetchNotifications();
      _items = response.notifications;
      _unreadCount = response.unreadCount;
      _hasMore = response.pagination?.hasMore ?? false;
      _nextCursor = response.pagination?.nextCursor;
    } on AppException catch (e) {
      _errorKey = e.messageKey ?? 'requestFailed';
    } catch (_) {
      _errorKey = 'failedToLoadNotifications';
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
      final response = await _service.fetchNotifications(cursor: _nextCursor);
      _items = [..._items, ...response.notifications];
      _unreadCount = response.unreadCount;
      _hasMore = response.pagination?.hasMore ?? false;
      _nextCursor = response.pagination?.nextCursor;
    } on AppException catch (e) {
      _errorKey = e.messageKey ?? 'requestFailed';
    } catch (_) {
      _errorKey = 'failedToLoadMoreNotifications';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1 || _items[index].isRead || _isActionLoading) return;

    _isActionLoading = true;
    notifyListeners();

    try {
      await _service.markAsRead(id);
      _items = [
        for (int i = 0; i < _items.length; i++)
          if (i == index) _items[i].copyWith(isRead: true) else _items[i],
      ];
      _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
    } on AppException catch (e) {
      _errorKey = e.messageKey ?? 'requestFailed';
    } catch (_) {
      _errorKey = 'failedToMarkNotificationAsRead';
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    if (_isActionLoading || _unreadCount == 0) return;

    _isActionLoading = true;
    notifyListeners();

    try {
      await _service.markAllAsRead();
      _items = [
        for (final item in _items)
          item.isRead ? item : item.copyWith(isRead: true),
      ];
      _unreadCount = 0;
    } on AppException catch (e) {
      _errorKey = e.messageKey ?? 'requestFailed';
    } catch (_) {
      _errorKey = 'failedToMarkAllNotificationsAsRead';
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
