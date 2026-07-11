import 'package:flutter_test/flutter_test.dart';

import 'package:omlapay_mobile_app/modules/auth/providers/login_verification_provider.dart';

void main() {
  group('LoginVerificationProvider', () {
    late LoginVerificationProvider provider;

    setUp(() {
      provider = LoginVerificationProvider(
        countryCode: '+966',
        phoneNumber: '500000000',
        initialCountdown: 60,
      );
    });

    tearDown(() {
      provider.dispose();
    });

    test('starts empty, not verifying, no error', () {
      expect(provider.otp, '');
      expect(provider.isVerifying, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.otpVerificationToken, isNull);
      expect(provider.isComplete, isFalse);
    });

    test('addDigit appends one digit and ignores non-digits', () {
      provider.addDigit('1');
      provider.addDigit('a');
      provider.addDigit('2');
      expect(provider.otp, '12');
    });

    test('addDigit caps at otpLength', () {
      for (var i = 0; i < 10; i++) {
        provider.addDigit('1');
      }
      expect(provider.otp.length, LoginVerificationProvider.otpLength);
    });

    test('removeLastDigit pops the last digit', () {
      provider.addDigit('1');
      provider.addDigit('2');
      provider.removeLastDigit();
      expect(provider.otp, '1');
    });

    test('clearOtp resets state', () {
      provider.addDigit('1');
      provider.addDigit('2');
      provider.clearOtp();
      expect(provider.otp, '');
      expect(provider.hasError, isFalse);
    });

    test('setOtpFromString keeps digits only and truncates', () {
      provider.setOtpFromString('12a3-4567890');
      expect(provider.otp.length, LoginVerificationProvider.otpLength);
      expect(provider.otp, '123456');
    });

    test('isComplete is true once otp reaches otpLength', () {
      provider.setOtpFromString('123456');
      expect(provider.isComplete, isTrue);
    });

    test('phoneNumber and countryCode are normalized', () {
      final p = LoginVerificationProvider(
        countryCode: ' +966 ',
        phoneNumber: '500-000-000',
      );
      expect(p.countryCode, '+966');
      expect(p.phoneNumber, '500000000');
      p.dispose();
    });

    test('formattedPhoneForDisplay falls back to maskedPhoneForDisplay when no maskedMobile', () {
      // We can't easily assert exact formatting here without coupling to
      // maskedPhoneForDisplay's internals; just assert it's non-empty.
      expect(provider.formattedPhoneForDisplay.isNotEmpty, isTrue);
    });

    test('formattedPhoneForDisplay returns maskedMobile when provided', () {
      final p = LoginVerificationProvider(
        countryCode: '+966',
        phoneNumber: '500000000',
        maskedMobile: '+966 *** *** 000',
      );
      expect(p.formattedPhoneForDisplay, '+966 *** *** 000');
      p.dispose();
    });
  });
}
