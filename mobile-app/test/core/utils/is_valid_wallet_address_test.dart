import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/utils/utility.dart';

void main() {
  const solAddress = 'GvHeR432g7MjN9uKyX3Dzg66TqwrEWgANLnnFZXMeyyj';
  // Real Solana addresses can start with any base58 character, including
  // '3' (looks like a BTC P2SH prefix) and 'T' (looks like a Tron prefix).
  const solAddressStartingWith3 =
      '3QQuWmkTddS23tE8fJTWRfgkufM1935k4ZhH8jm5CVXe';

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

    test(
        'OmlaPay JSON QR with SOL address starting with "3" passes regex '
        '(network hint disambiguates from BTC)', () async {
      // App-generated QR payload from receive flow: full wallet shape with
      // network=SOL. The address starts with "3" but is 44 base58 chars —
      // must not be misclassified as BTC.
      final raw =
          '{"name":"Solana","symbol":"SOL","address":"$solAddressStartingWith3",'
          '"addressTag":null,"network":"SOL","networkDisplayName":"Solana",'
          '"networkIconUrl":"https://example.com/sol.png",'
          '"balance":0.0,"currentBalance":0.0,"currentBalanceSar":0.0}';
      // With symbol "SOL" the validator would call the backend, so we only
      // assert it does not fail the local regex with invalidAddress.
      final result = await Utility.isValidWalletAddress(raw);
      expect(result, isNot(QrValidationError.invalidAddress));
      expect(result, isNot(QrValidationError.invalidFormat));
    });

    test('bare SOL address starting with "3" is accepted (regex falls through)',
        () async {
      expect(
        await Utility.isValidWalletAddress(solAddressStartingWith3),
        isNull,
      );
    });

    test('JSON with empty symbol but SOL-shaped address starting with "3"',
        () async {
      expect(
        await Utility.isValidWalletAddress(
          '{"symbol":"","address":"$solAddressStartingWith3"}',
        ),
        isNull,
      );
    });
  });
}
