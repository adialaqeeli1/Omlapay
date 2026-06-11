import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omlapay_mobile_app/core/constants/constants.dart';
import 'package:omlapay_mobile_app/core/services/biometric_service.dart';
import 'package:omlapay_mobile_app/core/services/storage_helper.dart';
import 'package:omlapay_mobile_app/providers/biometric_provider.dart';

class _FakeBiometricService extends BiometricService {
  _FakeBiometricService({
    required this.canUse,
    required this.authResult,
    this.kind = BiometricKind.fingerprint,
  });
  bool canUse;
  bool authResult;
  BiometricKind kind;
  int authCalls = 0;

  @override
  Future<bool> canUseBiometrics() async => canUse;

  @override
  Future<BiometricKind> primaryKind() async => kind;

  @override
  Future<bool> authenticate({required String reason}) async {
    authCalls++;
    return authResult;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  String? storedFlag() =>
      StorageService.getString(AppConstants.biometricEnabledKey);

  test('isAvailable reflects device capability after refresh', () async {
    final p = BiometricProvider(
      service: _FakeBiometricService(canUse: true, authResult: true),
    );
    await p.refreshAvailability();
    expect(p.isAvailable, true);
  });

  test('enable runs a confirming scan, persists, and sets isEnabled', () async {
    final fake = _FakeBiometricService(canUse: true, authResult: true);
    final p = BiometricProvider(service: fake);
    await p.refreshAvailability();

    final ok = await p.toggle(true, reason: 'r');

    expect(ok, true);
    expect(p.isEnabled, true);
    expect(fake.authCalls, 1);
    expect(storedFlag(), 'true');
  });

  test('enable failure leaves it disabled and not persisted true', () async {
    final fake = _FakeBiometricService(canUse: true, authResult: false);
    final p = BiometricProvider(service: fake);
    await p.refreshAvailability();

    final ok = await p.toggle(true, reason: 'r');

    expect(ok, false);
    expect(p.isEnabled, false);
    expect(storedFlag(), isNot('true'));
  });

  test('disable clears the flag without a scan', () async {
    final fake = _FakeBiometricService(canUse: true, authResult: true);
    final p = BiometricProvider(service: fake);
    await p.refreshAvailability();
    await p.toggle(true, reason: 'r');

    final ok = await p.toggle(false);

    expect(ok, true);
    expect(p.isEnabled, false);
    expect(fake.authCalls, 1); // no extra scan on disable
    expect(storedFlag(), 'false');
  });

  test('refreshAvailability auto-disables when capability disappears', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.biometricEnabledKey: 'true',
    });
    await StorageService.init();
    final fake = _FakeBiometricService(canUse: false, authResult: true);
    final p = BiometricProvider(service: fake);

    await p.refreshAvailability();

    expect(p.isAvailable, false);
    expect(p.isEnabled, false);
    expect(storedFlag(), 'false');
  });

  test('kind reflects the device modality after refresh', () async {
    final faceProvider = BiometricProvider(
      service: _FakeBiometricService(
        canUse: true,
        authResult: true,
        kind: BiometricKind.face,
      ),
    );
    await faceProvider.refreshAvailability();
    expect(faceProvider.kind, BiometricKind.face);

    final fingerprintProvider = BiometricProvider(
      service: _FakeBiometricService(
        canUse: true,
        authResult: true,
        kind: BiometricKind.fingerprint,
      ),
    );
    await fingerprintProvider.refreshAvailability();
    expect(fingerprintProvider.kind, BiometricKind.fingerprint);
  });
}
