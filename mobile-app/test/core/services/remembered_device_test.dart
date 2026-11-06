import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/services/remembered_device.dart';
import 'package:omlapay_mobile_app/core/services/storage_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  group('RememberedDevice (login/passcode needs a device token)', () {
    test('no token until the backend issues one', () {
      expect(RememberedDevice.token, isNull);
    });

    test(
      'saves data.device_token from login, registration or reset responses',
      () async {
        await RememberedDevice.saveFromResponse({
          'status': 'success',
          'data': {
            'access_token': 'a',
            'device_token': 'dev-123',
            'device_token_expires_in': 2592000,
          },
        });
        expect(RememberedDevice.token, 'dev-123');
      },
    );

    test('a response without a device token keeps the saved one', () async {
      await RememberedDevice.saveFromResponse({
        'data': {'device_token': 'dev-123'},
      });
      await RememberedDevice.saveFromResponse({
        'data': {'access_token': 'a'},
      });
      await RememberedDevice.saveFromResponse({'status': 'success'});
      expect(RememberedDevice.token, 'dev-123');
    });

    test('forget() removes it (logout)', () async {
      await RememberedDevice.saveFromResponse({
        'data': {'device_token': 'dev-123'},
      });
      await RememberedDevice.forget();
      expect(RememberedDevice.token, isNull);
    });

    test('device_id is left out when the platform gives none', () async {
      expect(await RememberedDevice.deviceIdField(), isEmpty);
    });
  });
}
