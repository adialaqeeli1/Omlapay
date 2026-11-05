import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/constants/constants.dart';
import 'package:omlapay_mobile_app/core/constants/endpoints.dart';
import 'package:omlapay_mobile_app/core/services/api_helper.dart';
import 'package:omlapay_mobile_app/core/services/storage_helper.dart';
import 'package:omlapay_mobile_app/core/utils/api_message_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('429 too many attempts', () {
    test('gives a clear English message', () {
      final e = ApiHelper.tooManyAttemptsException(429, arabic: false)!;
      expect(e.messageKey, 'tooManyAttempts');
      expect(e.message, contains('Too many attempts'));
      expect(e.isInvalidOtp, isFalse); // shown as a general error, not on the OTP field
    });

    test('gives a clear Arabic message', () {
      final e = ApiHelper.tooManyAttemptsException(429, arabic: true)!;
      expect(e.message, contains('محاولات كثيرة'));
      expect(e.isInvalidOtp, isFalse);
    });

    test('ignores other status codes', () {
      for (final code in [200, 400, 401, 404, 500, null]) {
        expect(ApiHelper.tooManyAttemptsException(code, arabic: false), isNull);
      }
    });
  });

  group('Arabic server messages (message_ar)', () {
    final response = {
      'code': 'PHONE_NOT_ALLOWED',
      'message': 'Only Saudi mobile numbers are supported (+966 5XXXXXXXX).',
      'message_ar': 'يُسمح فقط بأرقام الجوال السعودية (‎+966 5XXXXXXXX‎).',
    };

    Future<void> useLanguage(String code) async {
      SharedPreferences.setMockInitialValues({AppConstants.localeKey: code});
      await StorageService.init();
    }

    test('Arabic app shows message_ar', () async {
      await useLanguage('ar');
      expect(
        ApiMessageHelper.localizedFromResponse(response, fallback: 'x'),
        response['message_ar'],
      );
    });

    test('English app shows message', () async {
      await useLanguage('en');
      expect(
        ApiMessageHelper.localizedFromResponse(response, fallback: 'x'),
        response['message'],
      );
    });

    test('falls back to English when there is no Arabic text', () async {
      await useLanguage('ar');
      expect(
        ApiMessageHelper.localizedFromResponse({
          'message': 'Only English',
        }, fallback: 'x'),
        'Only English',
      );
    });
  });

  group('API server', () {
    test('debug builds (tests) use the dev API by default', () {
      expect(Endpoints.environment, 'dev');
      expect(Endpoints.baseUrl, 'https://api-dev.omlapay.org');
      expect(Endpoints.apiHost, 'api-dev.omlapay.org');
    });

    test('production address', () {
      expect(Endpoints.productionBaseUrl, 'https://api.omlapay.org');
    });
  });
}
