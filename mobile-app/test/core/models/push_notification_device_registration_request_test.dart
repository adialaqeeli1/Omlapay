import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/models/push_notification_device_registration_request/push_notification_device_registration_request.dart';

void main() {
  group('PushNotificationDeviceRegistrationRequest', () {
    test('toJson produces snake_case keys matching backend contract', () {
      const request = PushNotificationDeviceRegistrationRequest(
        deviceToken: 'fK9-token',
        deviceModel: 'iPhone16,1',
        deviceUuid: '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(request.toJson(), {
        'device_token': 'fK9-token',
        'device_model': 'iPhone16,1',
        'device_uuid': '550e8400-e29b-41d4-a716-446655440000',
      });
    });

    test('fromJson round-trips snake_case keys', () {
      final json = {
        'device_token': 'fK9-token',
        'device_model': 'Pixel 8 Pro',
        'device_uuid': 'abcdef0123456789',
      };

      final request = PushNotificationDeviceRegistrationRequest.fromJson(json);

      expect(request.deviceToken, 'fK9-token');
      expect(request.deviceModel, 'Pixel 8 Pro');
      expect(request.deviceUuid, 'abcdef0123456789');
    });
  });
}
