import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

void main() {
  // Pretend the clipboard has a valid 6-digit code.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': '123456'};
      }
      if (call.method == 'Clipboard.hasStrings') {
        return <String, dynamic>{'value': true};
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    debugDefaultTargetPlatformOverride = null;
  });

  // [withTapOutside] mirrors the two call-site patterns in the app:
  //  - otp_verification_view / two_factor: pass onTapOutside (unfocus). This
  //    wraps the field in a TapRegion the paste menu lives OUTSIDE of, which is
  //    what previously tore the menu down before the tap registered.
  //  - forgot_passcode: no onTapOutside, so the field stays focused at paste
  //    time (exercises the unfocus-before-write path in _applyPaste).
  Future<PinInputController> pumpField(
    WidgetTester tester, {
    required bool withTapOutside,
  }) async {
    final controller = PinInputController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MaterialPinField(
              length: 6,
              autoFocus: true,
              enablePaste: true,
              pinController: controller,
              onTapOutside: withTapOutside
                  ? (_) => FocusManager.instance.primaryFocus?.unfocus()
                  : null,
              keyboardType: TextInputType.number,
              theme: const MaterialPinTheme(
                shape: MaterialPinShape.outlined,
                cellSize: Size(48, 56),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    return controller;
  }

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final withTapOutside in [true, false]) {
      final label = withTapOutside ? 'with onTapOutside' : 'no onTapOutside';
      testWidgets('long-press paste fills the field on $platform ($label)',
          (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final controller =
            await pumpField(tester, withTapOutside: withTapOutside);

        // Long-press on the field region.
        final fieldFinder = find.byType(MaterialPinField);
        expect(fieldFinder, findsOneWidget);
        await tester.longPress(fieldFinder);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 300));

        // The Paste menu should be visible.
        expect(find.text('Paste'), findsOneWidget,
            reason: 'Expected a Paste button after long-press on $platform');

        // Tapping Paste should fill the field with the clipboard contents.
        await tester.tap(find.text('Paste'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        debugDefaultTargetPlatformOverride = null;

        expect(controller.text, '123456',
            reason: 'Expected the field to be filled after tapping Paste on '
                '$platform ($label)');
      });
    }
  }
}
