import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/utils/saudi_phone.dart';

void main() {
  group('SaudiPhone (same rule as the backend)', () {
    for (final input in [
      '512345678',
      '0512345678',
      '966512345678',
      '+966512345678',
      '00966512345678',
      '+966 51 234 5678',
      '051-234-5678',
    ]) {
      test('accepts $input as 512345678', () {
        expect(SaudiPhone.toNational(input), '512345678');
        expect(SaudiPhone.isValid(input), isTrue);
        expect(SaudiPhone.shouldShowError(input), isFalse);
      });
    }

    for (final input in [
      '9876543210', // India (+91)
      '+919876543210',
      '5551234567', // US (+1)
      '+15551234567',
      '112345678', // Saudi landline: not 5
      '51234567', // too short
      '5123456789', // too long
      '9665123456789', // too long with country code
    ]) {
      test('rejects $input', () {
        expect(SaudiPhone.toNational(input), isNull);
        expect(SaudiPhone.isValid(input), isFalse);
      });
    }

    test('shows the error only once a full-length number is typed', () {
      expect(SaudiPhone.shouldShowError(''), isFalse);
      expect(SaudiPhone.shouldShowError('5123'), isFalse); // still typing
      expect(SaudiPhone.shouldShowError('11234567'), isFalse); // 8 digits
      expect(SaudiPhone.shouldShowError('112345678'), isTrue); // 9 digits, not 5…
      expect(SaudiPhone.shouldShowError('9876543210'), isTrue);
    });

    test('longest accepted input fits the field limit', () {
      expect('00966512345678'.length, SaudiPhone.maxInputDigits);
    });
  });
}
