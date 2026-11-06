import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/constants/constants.dart';
import 'package:omlapay_mobile_app/core/network/network_client.dart';
import 'package:omlapay_mobile_app/core/services/secure_token_store.dart';
import 'package:omlapay_mobile_app/core/services/storage_helper.dart';
import 'package:omlapay_mobile_app/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeApi api;

  Future<AuthProvider> signedIn() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({
      AppConstants.userKey: jsonEncode({
        'id': 'u1',
        'mobileNumber': '512345678',
        'countryCode': '+966',
      }),
      AppConstants.tokenKey: 'access-0',
    });
    SecureTokenStore.resetForTest();
    await StorageService.init();
    final auth = AuthProvider();
    await pumpEventQueue();
    return auth;
  }

  setUp(() {
    api = FakeApi();
    NetworkClient.testAdapter = api;
  });
  tearDown(() => NetworkClient.testAdapter = null);

  group('Change passcode (stage 3)', () {
    test(
      'sends current/new/confirm and keeps this phone logged in with the new session',
      () async {
        final auth = await signedIn();
        api.replies['/v1/user/settings/change-passcode'] = {
          'status': 'success',
          'message': 'Passcode changed successfully.',
          'data': {
            'access_token': 'access-new',
            'refresh_token': 'refresh-new',
            'expires_in': 86400,
          },
        };
        final message = await auth.changePasscodeAndRefreshSession(
          currentPasscode: '135790',
          newPasscode: '246813',
          confirmPasscode: '246813',
        );
        expect(message, 'Passcode changed successfully.');
        expect(api.requests.single.data, {
          'current_passcode': '135790',
          'new_passcode': '246813',
          'confirm_passcode': '246813',
        });
        expect(StorageService.getString(AppConstants.tokenKey), 'access-new');
        expect(
          StorageService.getString(AppConstants.refreshTokenKey),
          'refresh-new',
        );
        expect(auth.state.isAuthenticated, isTrue);
        // no second login needed
        expect(
          api.requests.map((r) => r.path),
          isNot(contains('/v1/auth/login/passcode')),
        );
      },
    );

    test(
      'a refusal (wrong current passcode, weak passcode) reaches the screen',
      () async {
        final auth = await signedIn();
        await expectLater(
          auth.changePasscodeAndRefreshSession(
            currentPasscode: '000001',
            newPasscode: '246813',
            confirmPasscode: '246813',
          ),
          throwsA(anything),
        );
        expect(StorageService.getString(AppConstants.tokenKey), 'access-0');
      },
    );
  });
}
