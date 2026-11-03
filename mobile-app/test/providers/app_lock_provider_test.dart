import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:omlapay_mobile_app/core/models/auth_state/auth_state.dart';
import 'package:omlapay_mobile_app/core/models/user_model/user_model.dart';
import 'package:omlapay_mobile_app/providers/app_lock_provider.dart';
import 'package:omlapay_mobile_app/providers/auth_provider.dart';

/// Test double: lets us drive auth state and listener notifications without
/// touching real storage.
class FakeAuthProvider extends AuthProvider {
  FakeAuthProvider() : super();

  AuthState? _testState;

  void setState(AuthState newState) {
    _testState = newState;
    notifyListeners();
  }

  @override
  AuthState get state => _testState ?? super.state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AuthState authenticated() => AuthState(
        authStatus: AuthStatus.authorized,
        user: const UserModel(
          id: 'u1',
          email: 'test@example.com',
          fullMobileNumber: '+966500000000',
          countryCode: '+966',
          mobileNumber: '500000000',
          password: '123456',
          firstName: 'Test',
          lastName: 'User',
          isVerified: true,
        ),
      );

  AuthState unauthenticated() => const AuthState(
        authStatus: AuthStatus.unauthorized,
      );

  group('AppLockProvider', () {
    late FakeAuthProvider authProvider;
    late AppLockProvider lock;
    late int showCalls;
    late int dismissCalls;
    late DateTime fakeNow;

    setUp(() {
      authProvider = FakeAuthProvider();
      authProvider.setState(authenticated());
      fakeNow = DateTime(2026, 5, 8, 10, 0, 0);
      showCalls = 0;
      dismissCalls = 0;
      lock = AppLockProvider(
        authProvider: authProvider,
        showLockOverlay: () => showCalls++,
        dismissLockOverlay: () => dismissCalls++,
        backgroundThreshold: const Duration(seconds: 60),
        clock: () => fakeNow,
      );
    });

    tearDown(() {
      lock.dispose();
      authProvider.dispose();
    });

    test('starts locked', () {
      expect(lock.isUnlocked, isFalse);
    });

    test('markUnlocked flips isUnlocked to true', () {
      lock.markUnlocked();
      expect(lock.isUnlocked, isTrue);
    });

    test('paused → resumed under threshold does NOT lock', () {
      lock.markUnlocked();
      lock.didChangeAppLifecycleState(AppLifecycleState.paused);
      fakeNow = fakeNow.add(const Duration(seconds: 30));
      lock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(lock.isUnlocked, isTrue);
      expect(showCalls, 0);
    });

    test('paused → resumed at threshold locks and shows overlay', () {
      lock.markUnlocked();
      lock.didChangeAppLifecycleState(AppLifecycleState.paused);
      fakeNow = fakeNow.add(const Duration(seconds: 60));
      lock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(lock.isUnlocked, isFalse);
      expect(showCalls, 1);
    });

    test('paused → resumed past threshold while unauthenticated does NOT lock',
        () {
      lock.markUnlocked();
      authProvider.setState(unauthenticated());
      lock.didChangeAppLifecycleState(AppLifecycleState.paused);
      fakeNow = fakeNow.add(const Duration(seconds: 120));
      lock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(showCalls, 0);
    });

    test('paused → resumed past threshold while NOT yet unlocked does NOT lock',
        () {
      // Cold start case: user authenticated but hasn't gone through soft-login yet.
      lock.didChangeAppLifecycleState(AppLifecycleState.paused);
      fakeNow = fakeNow.add(const Duration(seconds: 120));
      lock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(showCalls, 0);
    });

    test('inactive does NOT start the timer', () {
      lock.markUnlocked();
      lock.didChangeAppLifecycleState(AppLifecycleState.inactive);
      fakeNow = fakeNow.add(const Duration(seconds: 120));
      lock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(lock.isUnlocked, isTrue);
      expect(showCalls, 0);
    });

    test('multiple paused events stamp only the first', () {
      lock.markUnlocked();
      lock.didChangeAppLifecycleState(AppLifecycleState.paused);
      fakeNow = fakeNow.add(const Duration(seconds: 30));
      lock.didChangeAppLifecycleState(AppLifecycleState.paused);
      fakeNow = fakeNow.add(const Duration(seconds: 31));
      // 61s since FIRST paused; if re-stamping happened, elapsed would be 31s.
      lock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(showCalls, 1);
    });

    test('overlay is not stacked on subsequent resumes', () {
      lock.markUnlocked();
      lock.didChangeAppLifecycleState(AppLifecycleState.paused);
      fakeNow = fakeNow.add(const Duration(seconds: 60));
      lock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(showCalls, 1);
      // Background again while overlay is up.
      lock.didChangeAppLifecycleState(AppLifecycleState.paused);
      fakeNow = fakeNow.add(const Duration(seconds: 60));
      lock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(showCalls, 1, reason: 'isUnlocked already false → no second overlay');
    });

    test('logout while overlay is visible dismisses the overlay', () {
      lock.markUnlocked();
      lock.didChangeAppLifecycleState(AppLifecycleState.paused);
      fakeNow = fakeNow.add(const Duration(seconds: 60));
      lock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(showCalls, 1);
      authProvider.setState(unauthenticated());
      expect(dismissCalls, 1);
    });

    test('overlayDidDismiss clears the visible flag', () {
      lock.markUnlocked();
      lock.didChangeAppLifecycleState(AppLifecycleState.paused);
      fakeNow = fakeNow.add(const Duration(seconds: 60));
      lock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(showCalls, 1);
      lock.overlayDidDismiss();
      // After successful unlock the caller pops the route and notifies us;
      // a fresh threshold-crossing should now produce a new overlay.
      lock.markUnlocked();
      lock.didChangeAppLifecycleState(AppLifecycleState.paused);
      fakeNow = fakeNow.add(const Duration(seconds: 60));
      lock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(showCalls, 2);
    });
  });
}
