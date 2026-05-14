import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/utils/utility.dart';

void main() {
  const solAddress = 'GvHeR432g7MjN9uKyX3Dzg66TqwrEWgANLnnFZXMeyyj';

  group('Utility.isValidWalletAddress', () {
    test('unparseable / empty input → invalidFormat', () async {
      expect(
        await Utility.isValidWalletAddress(''),
        QrValidationError.invalidFormat,
      );
      expect(
        await Utility.isValidWalletAddress('[1,2,3]'),
        QrValidationError.invalidFormat,
      );
    });

    test('parsed but address fails known-format regex → invalidAddress',
        () async {
      expect(
        await Utility.isValidWalletAddress('solana:not-a-real-address'),
        QrValidationError.invalidAddress,
      );
    });

    test('bare valid address (symbol empty) is accepted without backend call',
        () async {
      expect(await Utility.isValidWalletAddress(solAddress), isNull);
    });

    test(
        'JSON payload with empty symbol is accepted via regex-only branch '
        '(no backend call)', () async {
      expect(
        await Utility.isValidWalletAddress(
          '{"symbol":"","address":"$solAddress"}',
        ),
        isNull,
      );
    });
  });
}
