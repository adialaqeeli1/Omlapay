import 'package:flutter/material.dart' hide TableCell;
import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/markdown/markdown_node.dart';
import 'package:omlapay_mobile_app/core/markdown/markdown_renderer.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
  TextDirection direction = TextDirection.ltr,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: Directionality(
        textDirection: direction,
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('renderBlocks — headings and paragraphs', () {
    testWidgets('renders heading text', (tester) async {
      await _pump(
        tester,
        renderBlocks(
          const [
            BlockNode.heading(level: 1, children: [InlineNode.text('Title')]),
          ],
          onLinkTap: null,
        ),
      );
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('renders paragraph text', (tester) async {
      await _pump(
        tester,
        renderBlocks(
          const [BlockNode.paragraph(children: [InlineNode.text('Hello')])],
          onLinkTap: null,
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('heading alignment applies to Text.rich', (tester) async {
      await _pump(
        tester,
        renderBlocks(
          const [
            BlockNode.heading(
              level: 2,
              children: [InlineNode.text('Centered')],
              alignment: TextAlign.center,
            ),
          ],
          onLinkTap: null,
        ),
      );
      final text = tester.widget<Text>(find.text('Centered'));
      expect(text.textAlign, TextAlign.center);
    });
  });

  group('renderBlocks — blockquote and horizontal rule', () {
    testWidgets('blockquote renders children', (tester) async {
      await _pump(
        tester,
        renderBlocks(
          const [
            BlockquoteBlock(children: [
              ParagraphBlock(children: [InlineNode.text('quoted')]),
            ]),
          ],
          onLinkTap: null,
        ),
      );
      expect(find.text('quoted'), findsOneWidget);
    });

    testWidgets('horizontal rule emits a Divider', (tester) async {
      await _pump(
        tester,
        renderBlocks(const [HorizontalRuleBlock()], onLinkTap: null),
      );
      expect(find.byType(Divider), findsOneWidget);
    });
  });

  group('renderBlocks — lists', () {
    testWidgets('unordered list shows bullet and items', (tester) async {
      await _pump(
        tester,
        renderBlocks(
          const [
            UnorderedListBlock(items: [
              ListItem(children: [
                ParagraphBlock(children: [InlineNode.text('alpha')]),
              ]),
              ListItem(children: [
                ParagraphBlock(children: [InlineNode.text('beta')]),
              ]),
            ]),
          ],
          onLinkTap: null,
        ),
      );
      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
      expect(find.text('•'), findsNWidgets(2));
    });

    testWidgets('ordered list shows start numbers', (tester) async {
      await _pump(
        tester,
        renderBlocks(
          const [
            OrderedListBlock(
              startNumber: 3,
              items: [
                ListItem(children: [
                  ParagraphBlock(children: [InlineNode.text('a')]),
                ]),
                ListItem(children: [
                  ParagraphBlock(children: [InlineNode.text('b')]),
                ]),
              ],
            ),
          ],
          onLinkTap: null,
        ),
      );
      expect(find.text('3.'), findsOneWidget);
      expect(find.text('4.'), findsOneWidget);
    });
  });

  group('renderBlocks — code and table', () {
    testWidgets('code block renders with SelectableText', (tester) async {
      await _pump(
        tester,
        renderBlocks(
          const [CodeBlock(code: 'print("hi")')],
          onLinkTap: null,
        ),
      );
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('print("hi")'), findsOneWidget);
    });

    testWidgets('table renders with Table widget and cells', (tester) async {
      await _pump(
        tester,
        renderBlocks(
          const [
            TableBlock(
              columnAlignments: [null, TextAlign.right],
              rows: [
                MarkdownTableRow(cells: [
                  TableCell(children: [InlineNode.text('A')]),
                  TableCell(children: [InlineNode.text('B')]),
                ]),
                MarkdownTableRow(cells: [
                  TableCell(children: [InlineNode.text('1')]),
                  TableCell(children: [InlineNode.text('2')]),
                ]),
              ],
            ),
          ],
          onLinkTap: null,
        ),
      );
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('renderBlocks — html passthrough', () {
    testWidgets('block passthrough renders children transparently',
        (tester) async {
      await _pump(
        tester,
        renderBlocks(
          const [
            HtmlPassthroughBlock(
              tag: 'section',
              attributes: {},
              children: [
                ParagraphBlock(children: [InlineNode.text('inside section')]),
              ],
            ),
          ],
          onLinkTap: null,
        ),
      );
      expect(find.text('inside section'), findsOneWidget);
    });
  });

  group('renderBlocks — inline formatting', () {
    testWidgets('line break emits newline', (tester) async {
      await _pump(
        tester,
        renderBlocks(
          const [
            ParagraphBlock(children: [
              InlineNode.text('a'),
              InlineNode.lineBreak(),
              InlineNode.text('b'),
            ]),
          ],
          onLinkTap: null,
        ),
      );
      expect(find.textContaining('a\nb'), findsOneWidget);
    });
  });

  group('renderBlocks — links', () {
    testWidgets('tapping a link invokes onLinkTap with the URL',
        (tester) async {
      String? tapped;
      await _pump(
        tester,
        renderBlocks(
          const [
            ParagraphBlock(children: [
              InlineNode.link(url: 'https://example.com', children: [
                InlineNode.text('click me'),
              ]),
            ]),
          ],
          onLinkTap: (url) => tapped = url,
        ),
      );
      await tester.tap(find.text('click me'));
      expect(tapped, 'https://example.com');
    });
  });

  group('renderBlocks — images', () {
    testWidgets('renders Image.network for a valid image node',
        (tester) async {
      await _pump(
        tester,
        renderBlocks(
          const [
            ParagraphBlock(children: [
              InlineNode.image(src: 'https://example.com/x.png', alt: 'alt'),
            ]),
          ],
          onLinkTap: null,
        ),
      );
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
