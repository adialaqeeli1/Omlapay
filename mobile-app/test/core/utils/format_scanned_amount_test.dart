import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/utils/utility.dart';

void main() {
  group('Utility.formatScannedAmount', () {
    test('returns null for null input', () {
      expect(Utility.formatScannedAmount(null), isNull);
    });

    test('whole numbers render without a trailing .0', () {
      expect(Utility.formatScannedAmount(1.0), '1');
      expect(Utility.formatScannedAmount(42.0), '42');
      expect(Utility.formatScannedAmount(0.0), '0');
    });

    test('fractional amounts keep their decimals', () {
      expect(Utility.formatScannedAmount(1.5), '1.5');
      expect(Utility.formatScannedAmount(0.25), '0.25');
    });

    test('returns null for non-finite values', () {
      expect(Utility.formatScannedAmount(double.infinity), isNull);
      expect(Utility.formatScannedAmount(double.negativeInfinity), isNull);
      expect(Utility.formatScannedAmount(double.nan), isNull);
    });
  });
}
