import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/l10n/app_localizations_ar.dart';
import 'package:omlapay_mobile_app/core/l10n/app_localizations_en.dart';
import 'package:omlapay_mobile_app/core/utils/passcode_strength.dart';

void main() {
  group('obvious passcodes (same rule as the backend)', () {
    for (final p in [
      '000000',
      '111111',
      '123456',
      '234567',
      '012345',
      '654321',
      '987654',
      '543210',
    ]) {
      test('$p is refused', () => expect(isWeakPasscode(p), isTrue));
    }
    for (final p in [
      '135790',
      '246802',
      '112233',
      '123455',
      '890123',
      '121212',
      '100000',
    ]) {
      test('$p is accepted', () => expect(isWeakPasscode(p), isFalse));
    }
    test('the message exists in English and Arabic', () {
      expect(AppLocalizationsEn().weakPasscode, contains('too easy to guess'));
      expect(AppLocalizationsAr().weakPasscode, contains('سهل التخمين'));
    });
  });
}
