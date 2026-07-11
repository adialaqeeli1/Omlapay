import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/widgets/markdown_html_view.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  group('MarkdownHtmlView (non-selectable)', () {
    testWidgets('renders heading and paragraph end-to-end', (tester) async {
      await _pump(tester, const MarkdownHtmlView(data: '# Title\n\nHello'));
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('onLinkTap fires with URL', (tester) async {
      String? tapped;
      await _pump(
        tester,
        MarkdownHtmlView(
          data: '[site](https://x.y)',
          onLinkTap: (url) => tapped = url,
        ),
      );
      await tester.tap(find.text('site'));
      expect(tapped, 'https://x.y');
    });

    testWidgets('HTML heading with align="center" is respected',
        (tester) async {
      await _pump(
        tester,
        const MarkdownHtmlView(
          data: '<h1 align="center">Centered</h1>',
        ),
      );
      final text = tester.widget<Text>(find.text('Centered'));
      expect(text.textAlign, TextAlign.center);
    });
  });

  group('MarkdownHtmlView (selectable)', () {
    testWidgets('selectable=true wraps tree in SelectionArea',
        (tester) async {
      await _pump(
        tester,
        const MarkdownHtmlView(data: 'hello world', selectable: true),
      );
      expect(find.byType(SelectionArea), findsOneWidget);
    });

    testWidgets('rebuild does not throw', (tester) async {
      await _pump(
        tester,
        const MarkdownHtmlView(
          data: 'see [site](https://x.y)',
          selectable: true,
        ),
      );
      await _pump(
        tester,
        const MarkdownHtmlView(
          data: 'plain text only',
          selectable: true,
        ),
      );
      expect(find.text('plain text only'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('MarkdownHtmlView — real content smoke tests', () {
    const termsSnippet = '''<h1 align="center">Terms of Use</h1>

These Terms and Conditions govern your access.

## 1. Definitions

- **"Platform"** means the mobile application.
- **"User"** means any individual.

---

## 2. Acceptance

1. By accessing the Platform, you agree.
2. You warrant that you are at least 18 years old.
''';

    testWidgets('terms content renders without exception', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarkdownHtmlView(data: termsSnippet),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Terms of Use'), findsOneWidget);
      expect(find.textContaining('Definitions'), findsOneWidget);
    });

    testWidgets('centered HTML heading is centered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownHtmlView(data: termsSnippet)),
        ),
      );
      final t = tester.widget<Text>(find.text('Terms of Use'));
      expect(t.textAlign, TextAlign.center);
    });
  });
}
