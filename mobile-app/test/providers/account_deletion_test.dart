import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/constants/constants.dart';
import 'package:omlapay_mobile_app/core/network/network_client.dart';
import 'package:omlapay_mobile_app/core/services/storage_helper.dart';
import 'package:omlapay_mobile_app/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeApi api;

  Future<AuthProvider> signedIn() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.userKey: jsonEncode({
        'id': 'u1',
        'mobileNumber': '512345678',
        'countryCode': '+966',
      }),
      AppConstants.tokenKey: 'access-0',
      AppConstants.localeKey: 'ar',
    });
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

  group('Delete account (stage 2)', () {
    test(
      'sends the passcode and returns the server message (Arabic app)',
      () async {
        final auth = await signedIn();
        api.replies['/v1/user/settings/request-deletion'] = {
          'status': 'success',
          'message': 'Account deletion scheduled.',
          'message_ar': 'تمت جدولة حذف الحساب.',
          'data': {'deletion_scheduled_for': '2026-11-13T12:00:00.000Z'},
        };
        final message = await auth.requestAccountDeletion('135790');
        expect(message, 'تمت جدولة حذف الحساب.');
        expect(api.requests.single.method, 'POST');
        expect(api.requests.single.data, {'passcode': '135790'});
      },
    );

    test(
      'a refusal from the server (e.g. funds left) is thrown to the screen',
      () async {
        final auth = await signedIn();
        // FakeApi answers 404 for unknown paths, like any server error
        await expectLater(
          auth.requestAccountDeletion('135790'),
          throwsA(anything),
        );
        expect(auth.state.isLoading, isFalse);
      },
    );
  });
}
