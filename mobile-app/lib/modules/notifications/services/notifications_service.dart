import '../../../core/constants/endpoints.dart';
import '../../../core/models/notification/notification_model.dart';
import '../../../core/services/api_helper.dart';
import '../../../core/utils/app_exception.dart';

class NotificationsService {
  Future<NotificationsResponse> fetchNotifications({
    int limit = 20,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    final response = await ApiHelper.get(
      Endpoints.notifications,
      queryParameters: queryParams,
    );

    final dynamic data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw AppException(
        'Invalid notifications response',
        messageKey: 'requestFailed',
      );
    }

    return NotificationsResponse.fromJson(data);
  }

  Future<void> markAsRead(String id) async {
    await ApiHelper.post(Endpoints.notificationRead(id), {});
  }

  Future<void> markAllAsRead() async {
    await ApiHelper.post(Endpoints.notificationsMarkAllRead, {});
  }
}
