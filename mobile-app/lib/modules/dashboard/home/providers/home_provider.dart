import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../../../core/constants/endpoints.dart';
import '../models/home_model.dart';
import '../../../../core/services/api_helper.dart';
import '../../../../core/services/push_notification_service.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasFetchedHome = false;
  bool get hasFetchedHome => _hasFetchedHome;

  HomeModel? _homeData;
  HomeModel? get homeData => _homeData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    _hasFetchedHome = true;
    notifyListeners();

    try {
      final response = await ApiHelper.get(Endpoints.home);

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        _homeData = HomeModel.fromJson(response['data']);
        // Keep the OS app-icon badge aligned with the authoritative unread
        // count on launch/resume. awesome_notifications otherwise leaves a
        // stale, ever-incrementing badge that never reflects reality.
        unawaited(
          PushNotificationService.instance.syncAppBadge(
            _homeData!.unreadNotifications,
          ),
        );
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch home data';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _homeData = null;
    _errorMessage = null;
    _hasFetchedHome = false;
    notifyListeners();
    // Clear the OS app-icon badge on logout so a stale unread count doesn't
    // linger for the next user / signed-out state.
    unawaited(PushNotificationService.instance.syncAppBadge(0));
  }

  void updateUnreadNotifications(int count) {
    if (_homeData != null) {
      _homeData = _homeData!.copyWith(unreadNotifications: count);
      notifyListeners();
    }
    unawaited(PushNotificationService.instance.syncAppBadge(count));
  }

  void onAuthChanged(bool isAuthenticated) {
    if (!isAuthenticated) {
      clearData();
    } else if (!_hasFetchedHome) {
      fetchHomeData();
    }
  }
}
