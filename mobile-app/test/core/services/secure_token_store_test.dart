import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/constants/constants.dart';
import 'package:omlapay_mobile_app/core/services/remembered_device.dart';
import 'package:omlapay_mobile_app/core/services/secure_token_store.dart';
import 'package:omlapay_mobile_app/core/services/storage_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const secure = FlutterSecureStorage();
  late SharedPreferences prefs;

  /// Starts the app's storage with these plain (SharedPreferences) and secure values.
  Future<void> start({
    Map<String, Object> plain = const {},
    Map<String, String> keychain = const {},
  }) async {
    SharedPreferences.setMockInitialValues(plain);
    FlutterSecureStorage.setMockInitialValues(Map.of(keychain));
    SecureTokenStore.resetForTest();
    await StorageService.init();
    prefs = await SharedPreferences.getInstance();
  }

  tearDown(SecureTokenStore.resetForTest);

  group(
    'Login secrets live in Keychain / Android Keystore, not SharedPreferences',
    () {
      test('tokens are written to secure storage only', () async {
        await start(plain: {'secure_token_store_ready': true});
        await StorageService.setString(AppConstants.tokenKey, 'access-1');
        await StorageService.setString(
          AppConstants.refreshTokenKey,
          'refresh-1',
        );
        await RememberedDevice.saveFromResponse({
          'data': {'device_token': 'device-1'},
        });

        expect(StorageService.getString(AppConstants.tokenKey), 'access-1');
        expect(RememberedDevice.token, 'device-1');
        expect(await secure.read(key: AppConstants.tokenKey), 'access-1');
        expect(
          await secure.read(key: AppConstants.refreshTokenKey),
          'refresh-1',
        );
        expect(
          await secure.read(key: AppConstants.rememberedDeviceTokenKey),
          'device-1',
        );
        for (final key in SecureTokenStore.keys) {
          expect(prefs.containsKey(key), isFalse, reason: key);
        }
      });

      test('other settings stay in SharedPreferences', () async {
        await start(plain: {'secure_token_store_ready': true});
        await StorageService.setString(AppConstants.localeKey, 'ar');
        expect(prefs.getString(AppConstants.localeKey), 'ar');
        expect(await secure.read(key: AppConstants.localeKey), isNull);
      });

      test(
        'tokens saved by an older version are moved out of plain storage',
        () async {
          await start(
            plain: {
              AppConstants.tokenKey: 'old-access',
              AppConstants.refreshTokenKey: 'old-refresh',
              AppConstants.rememberedDeviceTokenKey: 'old-device',
              AppConstants.localeKey: 'ar',
            },
          );
          expect(StorageService.getString(AppConstants.tokenKey), 'old-access');
          expect(
            StorageService.getString(AppConstants.refreshTokenKey),
            'old-refresh',
          );
          expect(RememberedDevice.token, 'old-device');
          expect(await secure.read(key: AppConstants.tokenKey), 'old-access');
          for (final key in SecureTokenStore.keys) {
            expect(prefs.containsKey(key), isFalse, reason: key);
          }
          expect(prefs.getString(AppConstants.localeKey), 'ar'); // untouched
        },
      );

      test(
        'a reinstall starts logged out (iOS keeps Keychain items after uninstall)',
        () async {
          // Fresh install: no SharedPreferences at all, but an old Keychain entry.
          await start(
            keychain: {AppConstants.tokenKey: 'left-from-old-install'},
          );
          expect(StorageService.getString(AppConstants.tokenKey), isNull);
          expect(await secure.read(key: AppConstants.tokenKey), isNull);
        },
      );

      test('tokens survive a normal app restart', () async {
        await start(plain: {'secure_token_store_ready': true});
        await StorageService.setString(AppConstants.tokenKey, 'access-1');
        SecureTokenStore.resetForTest(); // memory gone, like an app restart
        FlutterSecureStorage.setMockInitialValues({
          AppConstants.tokenKey: 'access-1',
        });
        await StorageService.init();
        expect(StorageService.getString(AppConstants.tokenKey), 'access-1');
      });

      test('logout removes them from secure storage', () async {
        await start(plain: {'secure_token_store_ready': true});
        await StorageService.setString(AppConstants.tokenKey, 'access-1');
        await StorageService.remove(AppConstants.tokenKey);
        await RememberedDevice.forget();
        expect(StorageService.getString(AppConstants.tokenKey), isNull);
        expect(await secure.read(key: AppConstants.tokenKey), isNull);
      });

      test('clear() wipes secure storage too', () async {
        await start(plain: {'secure_token_store_ready': true});
        await StorageService.setString(
          AppConstants.refreshTokenKey,
          'refresh-1',
        );
        await StorageService.clear();
        expect(StorageService.getString(AppConstants.refreshTokenKey), isNull);
        expect(await secure.read(key: AppConstants.refreshTokenKey), isNull);
      });

      test(
        'if secure storage fails, tokens never fall back to plain storage',
        () async {
          SharedPreferences.setMockInitialValues({
            AppConstants.tokenKey: 'old-access',
          });
          SecureTokenStore.resetForTest();
          SecureTokenStore.storage = _BrokenStorage();
          await StorageService.init();
          prefs = await SharedPreferences.getInstance();
          expect(prefs.containsKey(AppConstants.tokenKey), isFalse);
          await StorageService.setString(AppConstants.tokenKey, 'access-1');
          expect(prefs.containsKey(AppConstants.tokenKey), isFalse);
          expect(
            StorageService.getString(AppConstants.tokenKey),
            'access-1',
          ); // this run only
        },
      );
    },
  );
}

class _BrokenStorage extends FlutterSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => throw Exception('keystore unavailable');

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => throw Exception('keystore unavailable');

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => throw Exception('keystore unavailable');
}
