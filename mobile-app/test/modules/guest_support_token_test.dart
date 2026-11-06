import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/constants/constants.dart';
import 'package:omlapay_mobile_app/core/network/network_client.dart';
import 'package:omlapay_mobile_app/core/services/secure_token_store.dart';
import 'package:omlapay_mobile_app/core/services/storage_helper.dart';
import 'package:omlapay_mobile_app/modules/help_center/services/help_center_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeApi api;
  final service = HelpCenterService();
  const device = 'AA:BB:CC:DD:EE:FF';

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({'secure_token_store_ready': true});
    SecureTokenStore.resetForTest();
    await StorageService.init();
    api = FakeApi();
    NetworkClient.testAdapter = api;
    api.replies['/v1/guest/support-requests'] = {
      'status': 'success',
      'data': {
        'request': {'id': 'r1'},
        'guest_token': 'guest-secret-1',
        'requests': [],
        'pagination': {'page': '1', 'limit': '10', 'total': 0, 'totalPages': 0},
      },
    };
  });
  tearDown(() => NetworkClient.testAdapter = null);

  group('Support without an account: server-issued guest token', () {
    test('the first guest request saves the token in secure storage', () async {
      await service.submitRequest(
        title: 't',
        description: 'd',
        macAddress: device,
      );
      expect(
        StorageService.getString(AppConstants.guestSupportTokenKey),
        'guest-secret-1',
      );
      expect(
        await const FlutterSecureStorage().read(
          key: AppConstants.guestSupportTokenKey,
        ),
        'guest-secret-1',
      );
      expect(api.requests.single.headers.containsKey('X-Guest-Token'), isFalse);
    });

    test('later guest calls send the token as X-Guest-Token', () async {
      await StorageService.setString(
        AppConstants.guestSupportTokenKey,
        'guest-secret-1',
      );
      await service.fetchSupportRequests(macAddress: device);
      await service.submitRequest(
        title: 't',
        description: 'd',
        macAddress: device,
      );
      for (final r in api.requests) {
        expect(r.headers['X-Guest-Token'], 'guest-secret-1');
      }
    });

    test('logged-in requests never send the guest token', () async {
      await StorageService.setString(
        AppConstants.guestSupportTokenKey,
        'guest-secret-1',
      );
      api.replies['/v1/user/support-requests'] = {
        'status': 'success',
        'data': {
          'requests': [],
          'pagination': {
            'page': '1',
            'limit': '10',
            'total': 0,
            'totalPages': 0,
          },
        },
      };
      await service.fetchSupportRequests();
      expect(api.requests.single.path, '/v1/user/support-requests');
      expect(api.requests.single.headers.containsKey('X-Guest-Token'), isFalse);
    });
  });
}
