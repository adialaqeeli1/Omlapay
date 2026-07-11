import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/models/scanned_qr_payload/scanned_qr_payload.dart';

void main() {
  group('ScannedQrPayload', () {
    test('defaults: symbol empty, address and amount null', () {
      const payload = ScannedQrPayload();
      expect(payload.address, isNull);
      expect(payload.symbol, '');
      expect(payload.amount, isNull);
    });

    test('holds provided values', () {
      const payload = ScannedQrPayload(
        address: 'GvHeR432g7MjN9uKyX3Dzg66TqwrEWgANLnnFZXMeyyj',
        symbol: 'SOL',
        amount: 1.5,
      );
      expect(payload.address, 'GvHeR432g7MjN9uKyX3Dzg66TqwrEWgANLnnFZXMeyyj');
      expect(payload.symbol, 'SOL');
      expect(payload.amount, 1.5);
    });

    test('fromJson round-trips fields and applies symbol default when absent', () {
      // Full round-trip: all three fields present.
      final full = ScannedQrPayload.fromJson({
        'address': 'GvHeR432g7MjN9uKyX3Dzg66TqwrEWgANLnnFZXMeyyj',
        'symbol': 'SOL',
        'amount': 1.5,
      });
      expect(full.address, 'GvHeR432g7MjN9uKyX3Dzg66TqwrEWgANLnnFZXMeyyj');
      expect(full.symbol, 'SOL');
      expect(full.amount, 1.5);

      // Default applied: symbol key absent → symbol falls back to ''.
      final partial = ScannedQrPayload.fromJson({
        'address': 'GvHeR432g7MjN9uKyX3Dzg66TqwrEWgANLnnFZXMeyyj',
      });
      expect(partial.address, 'GvHeR432g7MjN9uKyX3Dzg66TqwrEWgANLnnFZXMeyyj');
      expect(partial.symbol, '');
      expect(partial.amount, isNull);
    });
  });
}
