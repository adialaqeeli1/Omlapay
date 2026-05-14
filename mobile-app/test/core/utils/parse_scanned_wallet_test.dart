import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/utils/utility.dart';

void main() {
  const solAddress = 'GvHeR432g7MjN9uKyX3Dzg66TqwrEWgANLnnFZXMeyyj';

  group('Utility.parseScannedWallet', () {
    test('parses OmlaPay JSON payload', () {
      final payload = Utility.parseScannedWallet(
        '{"symbol":"SOL","address":"$solAddress"}',
      );
      expect(payload, isNotNull);
      expect(payload!.address, solAddress);
      expect(payload.symbol, 'SOL');
      expect(payload.amount, isNull);
    });

    test('parses Solana Pay URI with query params', () {
      final payload = Utility.parseScannedWallet(
        'solana:$solAddress?amount=1&spl-token=EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v'
        '&reference=72FrP58fnrD24Fo48jKR2PoyjjaTcKQJHM9inPV6TFGn&label=Solana%20Pay',
      );
      expect(payload, isNotNull);
      expect(payload!.address, solAddress);
      expect(payload.symbol, 'SOL');
      expect(payload.amount, 1.0);
    });

    test('parses bare Solana Pay URI without query', () {
      final payload = Utility.parseScannedWallet('solana:$solAddress');
      expect(payload, isNotNull);
      expect(payload!.address, solAddress);
      expect(payload.symbol, 'SOL');
      expect(payload.amount, isNull);
    });

    test('parses a bare address string', () {
      final payload = Utility.parseScannedWallet(solAddress);
      expect(payload, isNotNull);
      expect(payload!.address, solAddress);
      expect(payload.symbol, '');
      expect(payload.amount, isNull);
    });

    test('non-solana scheme keeps symbol empty but extracts address/amount', () {
      final payload = Utility.parseScannedWallet(
        'bitcoin:1BoatSLRHtKNngkdXEeobR76b53LETtpyT?amount=0.5',
      );
      expect(payload, isNotNull);
      expect(payload!.address, '1BoatSLRHtKNngkdXEeobR76b53LETtpyT');
      expect(payload.symbol, '');
      expect(payload.amount, 0.5);
    });

    test('scheme matching is case-insensitive', () {
      final payload = Utility.parseScannedWallet('SOLANA:$solAddress');
      expect(payload!.symbol, 'SOL');
    });

    test('whitespace around a bare address is trimmed', () {
      final payload = Utility.parseScannedWallet('  $solAddress  ');
      expect(payload!.address, solAddress);
    });

    test('empty / whitespace-only input returns null', () {
      expect(Utility.parseScannedWallet(''), isNull);
      expect(Utility.parseScannedWallet('   '), isNull);
    });

    test('JSON array (not an object) returns null', () {
      expect(Utility.parseScannedWallet('[1,2,3]'), isNull);
    });

    test('JSON object without an address yields a payload with null address', () {
      final payload = Utility.parseScannedWallet('{"foo":"bar"}');
      expect(payload, isNotNull);
      expect(payload!.address, isNull);
      expect(payload.symbol, '');
    });

    test('bare numeric string falls through to bare-address handling', () {
      final payload = Utility.parseScannedWallet('1234567890123456789012345');
      expect(payload, isNotNull);
      expect(payload!.address, '1234567890123456789012345');
      expect(payload.symbol, '');
    });

    test('URI scheme with empty path falls through to bare-address handling', () {
      final payload = Utility.parseScannedWallet('solana:');
      expect(payload, isNotNull);
      expect(payload!.address, 'solana:');
    });
  });
}
