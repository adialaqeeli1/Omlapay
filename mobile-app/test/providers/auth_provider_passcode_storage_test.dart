import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/constants/constants.dart';
import 'package:omlapay_mobile_app/core/models/user_model/user_model.dart';
import 'package:omlapay_mobile_app/core/network/network_client.dart';
import 'package:omlapay_mobile_app/core/services/storage_helper.dart';
import 'package:omlapay_mobile_app/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers API calls with canned JSON by path and records what was sent.
class FakeApi implements HttpClientAdapter {
  final Map<String, Map<String, dynamic>> replies = {};
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final reply = replies[options.path];
    return ResponseBody.fromString(
      jsonEncode(reply ?? {'message': 'not found'}),
      reply == null ? 404 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const passcode = '135790';

/// Everything the app keeps in local storage, as one string.
String allStorage(SharedPreferences prefs) =>
    prefs.getKeys().map((k) => '$k=${prefs.get(k)}').join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeApi api;
  late SharedPreferences prefs;

  Future<AuthProvider> start([Map<String, Object> saved = const {}]) async {
    SharedPreferences.setMockInitialValues(saved);
    await StorageService.init();
    prefs = await SharedPreferences.getInstance();
    final auth = AuthProvider();
    await pumpEventQueue();
    return auth;
  }

  setUp(() {
    api = FakeApi();
    NetworkClient.testAdapter = api;
  });
  tearDown(() => NetworkClient.testAdapter = null);

  test('the user model has no passcode field', () {
    final user = UserModel.fromJson({'id': 'u1', 'password': passcode});
    expect(user.toJson().containsKey('password'), isFalse);
    expect(jsonEncode(user.toJson()), isNot(contains(passcode)));
  });

  test(
    'a passcode saved by an older app version is removed on start',
    () async {
      final auth = await start({
        AppConstants.userKey: jsonEncode({
          'id': 'u1',
          'mobileNumber': '512345678',
          'countryCode': '+966',
          'password': passcode,
        }),
        AppConstants.tokenKey: 'access-0',
      });
      expect(auth.state.isAuthenticated, isTrue);
      expect(auth.state.user?.mobileNumber, '512345678');
      expect(allStorage(prefs), isNot(contains(passcode)));
    },
  );

  // login() and loginWithPasscode() also register for push notifications
  // (Firebase), which does not run in unit tests. They build the saved user
  // from UserModel, which has no passcode field (first test above).

  group('signed in', () {
    Future<AuthProvider> signedIn() => start({
      AppConstants.userKey: jsonEncode({
        'id': 'u1',
        'mobileNumber': '512345678',
        'countryCode': '+966',
        'twoFactorEnabled': true,
      }),
      AppConstants.tokenKey: 'access-0',
    });

    test('unlocking with the passcode does not save it', () async {
      final auth = await signedIn();
      api.replies['/v1/auth/soft-login'] = {
        'status': 'success',
        'data': {'user_id': 'u1'},
      };
      expect(await auth.softLogin(passcode), isTrue);
      expect(allStorage(prefs), isNot(contains(passcode)));
    });

    test('the "current passcode" check asks the server', () async {
      final auth = await signedIn();
      api.replies['/v1/auth/soft-login'] = {
        'status': 'success',
        'data': {'user_id': 'u1'},
      };
      expect(await auth.verifyPasscodeWithServer(passcode), isTrue);
      expect(api.requests.single.path, '/v1/auth/soft-login');
      expect(api.requests.single.data, {'passcode': passcode});

      api.replies.clear(); // server says no
      expect(await auth.verifyPasscodeWithServer('000000'), isFalse);
    });

    test(
      'biometric unlock checks the session with the server, sends no passcode',
      () async {
        final auth = await signedIn();
        var unlocked = 0;
        auth.onUnlockCallback = () => unlocked++;
        api.replies['/v1/auth/session-status'] = {
          'status': 'success',
          'data': {'is_valid': true},
        };
        expect(await auth.unlockWithBiometrics(), isTrue);
        expect(unlocked, 1);
        expect(api.requests.first.path, '/v1/auth/session-status');

        api.replies['/v1/auth/session-status'] = {
          'status': 'success',
          'data': {'is_valid': false},
        };
        expect(await auth.unlockWithBiometrics(), isFalse);
        api.replies.clear(); // offline / error: stays locked
        expect(await auth.unlockWithBiometrics(), isFalse);
        expect(unlocked, 1);
      },
    );

    test(
      'turning off 2FA uses the new session from the server (no passcode)',
      () async {
        final auth = await signedIn();
        api.replies['/v1/user/settings/2fa/disable'] = {
          'status': 'success',
          'message': 'Two-factor authentication has been disabled.',
          'data': {'access_token': 'access-2', 'refresh_token': 'refresh-2'},
        };
        await auth.toggleTwoFactor(false);
        expect(prefs.getString(AppConstants.tokenKey), 'access-2');
        expect(prefs.getString('refresh_token'), 'refresh-2');
        expect(auth.state.user?.twoFactorEnabled, isFalse);
        expect(
          api.requests.map((r) => r.path),
          isNot(contains('/v1/auth/login/passcode')),
        );
      },
    );
  });
}
