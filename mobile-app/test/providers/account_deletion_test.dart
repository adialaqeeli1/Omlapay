import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/constants/constants.dart';
import 'package:omlapay_mobile_app/core/l10n/app_localizations_ar.dart';
import 'package:omlapay_mobile_app/core/l10n/app_localizations_en.dart';
import 'package:omlapay_mobile_app/core/network/network_client.dart';
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

    test('a login that cancelled the deletion is recognized', () {
      expect(
        AuthProvider.deletionWasCancelled({'deletion_cancelled': true}),
        isTrue,
      );
      expect(AuthProvider.deletionWasCancelled({'access_token': 'a'}), isFalse);
      expect(AuthProvider.deletionWasCancelled(null), isFalse);
    });

    test(
      'the deletion texts mention the 7 days, cancelling by logging in, and the cancel notice (EN + AR)',
      () {
        final en = AppLocalizationsEn();
        final ar = AppLocalizationsAr();
        expect(
          en.deleteAccountConfirmMessage,
          contains('7 days to cancel by logging in again'),
        );
        expect(
          en.deleteAccountScheduled,
          contains('7 days to cancel by logging in again'),
        );
        expect(
          en.deleteAccountCancelled,
          'Account deletion cancelled. Your account stays active.',
        );
        expect(
          ar.deleteAccountConfirmMessage,
          contains('7 أيام للإلغاء عن طريق تسجيل الدخول'),
        );
        expect(
          ar.deleteAccountScheduled,
          contains('7 أيام للإلغاء عن طريق تسجيل الدخول'),
        );
        expect(
          ar.deleteAccountCancelled,
          'تم إلغاء حذف الحساب. سيبقى حسابك نشطًا.',
        );
      },
    );
  });
}
