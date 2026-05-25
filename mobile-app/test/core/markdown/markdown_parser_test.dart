import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omlapay_mobile_app/core/markdown/html_entities.dart';
import 'package:omlapay_mobile_app/core/markdown/markdown_node.dart';
import 'package:omlapay_mobile_app/core/markdown/markdown_parser.dart';

void main() {
  group('decodeHtmlEntities', () {
    test('decodes named entities', () {
      expect(decodeHtmlEntities('AT&amp;T'), 'AT&T');
      expect(decodeHtmlEntities('a&lt;b&gt;c'), 'a<b>c');
      expect(decodeHtmlEntities('he said &quot;hi&quot;'), 'he said "hi"');
      expect(decodeHtmlEntities('non&nbsp;break'), 'non break');
      expect(decodeHtmlEntities("it&apos;s"), "it's");
    });

    test('decodes decimal numeric entities', () {
      expect(decodeHtmlEntities('&#39;'), "'");
      expect(decodeHtmlEntities('&#65;'), 'A');
    });

    test('decodes hex numeric entities', () {
      expect(decodeHtmlEntities('&#x27;'), "'");
      expect(decodeHtmlEntities('&#X41;'), 'A');
    });

    test('leaves unknown entities unchanged', () {
      expect(decodeHtmlEntities('&notAThing;'), '&notAThing;');
      expect(decodeHtmlEntities('&'), '&');
      expect(decodeHtmlEntities('a&b'), 'a&b');
    });

    test('handles empty and no-entity input', () {
      expect(decodeHtmlEntities(''), '');
      expect(decodeHtmlEntities('plain text'), 'plain text');
    });
  });

  group('AST construction', () {
    test('BlockNode variants construct and compare by value', () {
      const a = BlockNode.heading(level: 1, children: [InlineNode.text('x')]);
      const b = BlockNode.heading(level: 1, children: [InlineNode.text('x')]);
      expect(a, equals(b));
      expect(a, isA<HeadingBlock>());
    });

    test('InlineNode variants construct and compare by value', () {
      const a = InlineNode.bold([InlineNode.text('x')]);
      const b = InlineNode.bold([InlineNode.text('x')]);
      expect(a, equals(b));
      expect(a, isA<BoldInline>());
    });
  });

  group('parseMarkdown — empty input', () {
    test('empty string returns empty list', () {
      expect(parseMarkdown(''), isEmpty);
    });

    test('whitespace-only input returns empty list', () {
      expect(parseMarkdown('   \n\n  \t \n'), isEmpty);
    });
  });

  group('parseMarkdown — headings', () {
    test('parses # through ###### markdown headings', () {
      for (var level = 1; level <= 6; level++) {
        final input = '${'#' * level} Title';
        final result = parseMarkdown(input);
        expect(result, hasLength(1));
        expect(result.first, isA<HeadingBlock>());
        final h = result.first as HeadingBlock;
        expect(h.level, level);
        expect(h.children, [const InlineNode.text('Title')]);
        expect(h.alignment, isNull);
      }
    });

    test('ignores invalid heading — no space after hashes', () {
      final result = parseMarkdown('#NotAHeading');
      expect(result.first, isA<ParagraphBlock>());
    });

    test('parses <h1>..<h6> HTML as headings (same AST as markdown)', () {
      for (var level = 1; level <= 6; level++) {
        final input = '<h$level>Title</h$level>';
        final result = parseMarkdown(input);
        expect(result, hasLength(1));
        final h = result.first as HeadingBlock;
        expect(h.level, level);
        expect(h.children, [const InlineNode.text('Title')]);
      }
    });

    test('extracts align attribute from HTML heading', () {
      final result = parseMarkdown('<h1 align="center">Title</h1>');
      final h = result.first as HeadingBlock;
      expect(h.alignment, TextAlign.center);
    });

    test('align="right" and align="left" are honored', () {
      expect(
        (parseMarkdown('<h2 align="left">x</h2>').first as HeadingBlock).alignment,
        TextAlign.left,
      );
      expect(
        (parseMarkdown('<h2 align="right">x</h2>').first as HeadingBlock).alignment,
        TextAlign.right,
      );
      expect(
        (parseMarkdown('<h2 align="justify">x</h2>').first as HeadingBlock).alignment,
        TextAlign.justify,
      );
    });
  });

  group('parseMarkdown — paragraphs', () {
    test('single-line paragraph', () {
      final result = parseMarkdown('hello world');
      expect(result, hasLength(1));
      expect(result.first, isA<ParagraphBlock>());
      expect((result.first as ParagraphBlock).children,
          [const InlineNode.text('hello world')]);
    });

    test('multi-line paragraph — lines joined with space', () {
      final result = parseMarkdown('line one\nline two');
      expect(result, hasLength(1));
      expect((result.first as ParagraphBlock).children,
          [const InlineNode.text('line one line two')]);
    });

    test('blank line separates paragraphs', () {
      final result = parseMarkdown('para one\n\npara two');
      expect(result, hasLength(2));
      expect((result[0] as ParagraphBlock).children,
          [const InlineNode.text('para one')]);
      expect((result[1] as ParagraphBlock).children,
          [const InlineNode.text('para two')]);
    });
  });

  group('parseMarkdown — horizontal rules', () {
    test('--- on its own line', () {
      expect(parseMarkdown('---').single, isA<HorizontalRuleBlock>());
    });
    test('*** on its own line', () {
      expect(parseMarkdown('***').single, isA<HorizontalRuleBlock>());
    });
    test('___ on its own line', () {
      expect(parseMarkdown('___').single, isA<HorizontalRuleBlock>());
    });
    test('<hr> on its own line', () {
      expect(parseMarkdown('<hr>').single, isA<HorizontalRuleBlock>());
    });
    test('<hr/> self-closing', () {
      expect(parseMarkdown('<hr/>').single, isA<HorizontalRuleBlock>());
    });
    test('--- inside a paragraph is not an hr', () {
      final result = parseMarkdown('abc---def');
      expect(result.single, isA<ParagraphBlock>());
    });
  });

  group('parseMarkdown — blockquotes', () {
    test('single-line blockquote', () {
      final result = parseMarkdown('> hello');
      expect(result, hasLength(1));
      final bq = result.first as BlockquoteBlock;
      expect(bq.children, hasLength(1));
      expect(bq.children.first, isA<ParagraphBlock>());
      expect((bq.children.first as ParagraphBlock).children,
          [const InlineNode.text('hello')]);
    });

    test('multi-line blockquote — continuation lines', () {
      final result = parseMarkdown('> line one\n> line two');
      final bq = result.first as BlockquoteBlock;
      expect((bq.children.first as ParagraphBlock).children,
          [const InlineNode.text('line one line two')]);
    });

    test('nested blockquotes via recursion', () {
      final result = parseMarkdown('> > nested');
      final outer = result.first as BlockquoteBlock;
      final inner = outer.children.first as BlockquoteBlock;
      expect((inner.children.first as ParagraphBlock).children,
          [const InlineNode.text('nested')]);
    });

    test('<blockquote> HTML maps to same AST', () {
      final result = parseMarkdown('<blockquote>hello</blockquote>');
      expect(result.first, isA<BlockquoteBlock>());
    });
  });

  group('parseMarkdown — unordered lists', () {
    test('basic - list', () {
      final result = parseMarkdown('- a\n- b\n- c');
      expect(result, hasLength(1));
      final list = result.first as UnorderedListBlock;
      expect(list.items, hasLength(3));
      expect(
        (list.items[0].children.first as ParagraphBlock).children,
        [const InlineNode.text('a')],
      );
    });

    test('* and + markers also work', () {
      expect(parseMarkdown('* a').first, isA<UnorderedListBlock>());
      expect(parseMarkdown('+ a').first, isA<UnorderedListBlock>());
    });

    test('<ul><li> HTML produces same AST', () {
      final result = parseMarkdown('<ul><li>a</li><li>b</li></ul>');
      final list = result.first as UnorderedListBlock;
      expect(list.items, hasLength(2));
    });
  });

  group('parseMarkdown — ordered lists', () {
    test('1. 2. 3. markdown', () {
      final result = parseMarkdown('1. one\n2. two\n3. three');
      final list = result.first as OrderedListBlock;
      expect(list.items, hasLength(3));
      expect(list.startNumber, 1);
    });

    test('non-1 start number', () {
      final result = parseMarkdown('5. five\n6. six');
      final list = result.first as OrderedListBlock;
      expect(list.startNumber, 5);
    });

    test('<ol start="3"> HTML', () {
      final result = parseMarkdown('<ol start="3"><li>a</li><li>b</li></ol>');
      final list = result.first as OrderedListBlock;
      expect(list.items, hasLength(2));
      expect(list.startNumber, 3);
    });
  });

  group('parseMarkdown — nested lists', () {
    test('4-space indented sublist under a list item', () {
      final input = '- outer\n    - inner\n    - inner2\n- outer2';
      final result = parseMarkdown(input);
      final outer = result.first as UnorderedListBlock;
      expect(outer.items, hasLength(2));

      final firstItem = outer.items.first;
      // Item children: paragraph('outer'), then a nested UnorderedListBlock
      expect(firstItem.children, hasLength(2));
      expect(firstItem.children[0], isA<ParagraphBlock>());
      expect(firstItem.children[1], isA<UnorderedListBlock>());
      final inner = firstItem.children[1] as UnorderedListBlock;
      expect(inner.items, hasLength(2));
    });

    test('nested ordered list inside unordered', () {
      final input = '- outer\n    1. first\n    2. second';
      final outer = (parseMarkdown(input).first as UnorderedListBlock).items.first;
      expect(outer.children[1], isA<OrderedListBlock>());
    });
  });

  group('parseMarkdown — code blocks', () {
    test('fenced code block', () {
      final input = '```\nfoo\nbar\n```';
      final result = parseMarkdown(input);
      final cb = result.first as CodeBlock;
      expect(cb.code, 'foo\nbar');
      expect(cb.language, isNull);
    });

    test('fenced with language', () {
      final input = '```dart\nvoid main() {}\n```';
      final cb = parseMarkdown(input).first as CodeBlock;
      expect(cb.language, 'dart');
      expect(cb.code, 'void main() {}');
    });

    test('<pre><code> HTML maps to CodeBlock', () {
      final result = parseMarkdown('<pre><code>foo\nbar</code></pre>');
      final cb = result.first as CodeBlock;
      expect(cb.code, 'foo\nbar');
    });
  });

  group('parseMarkdown — tables', () {
    test('basic pipe table with default alignment', () {
      final input = '| A | B |\n| --- | --- |\n| 1 | 2 |\n| 3 | 4 |';
      final result = parseMarkdown(input);
      final t = result.first as TableBlock;
      expect(t.rows, hasLength(3));
      expect(t.columnAlignments, [null, null]);
      expect((t.rows.first.cells[0].children.first as TextInline).value, 'A');
    });

    test('column alignments from divider row', () {
      final input = '| L | C | R |\n| :--- | :---: | ---: |\n| a | b | c |';
      final t = parseMarkdown(input).first as TableBlock;
      expect(t.columnAlignments,
          [TextAlign.left, TextAlign.center, TextAlign.right]);
    });

    test('HTML table maps to same AST', () {
      final input =
          '<table><tr><th>A</th><th>B</th></tr><tr><td>1</td><td>2</td></tr></table>';
      final t = parseMarkdown(input).first as TableBlock;
      expect(t.rows, hasLength(2));
    });

    test('malformed table (missing divider) falls back to paragraph', () {
      final input = '| a | b |\ntext\n';
      expect(parseMarkdown(input).first, isA<ParagraphBlock>());
    });
  });

  group('parseMarkdown — inline text and entities', () {
    test('plain text is decoded for entities', () {
      final p = parseMarkdown('AT&amp;T').first as ParagraphBlock;
      expect(p.children, [const InlineNode.text('AT&T')]);
    });

    test('<br> produces LineBreakInline', () {
      final p = parseMarkdown('a<br>b').first as ParagraphBlock;
      expect(p.children, [
        const InlineNode.text('a'),
        const InlineNode.lineBreak(),
        const InlineNode.text('b'),
      ]);
    });

    test('<br/> also produces LineBreakInline', () {
      final p = parseMarkdown('a<br/>b').first as ParagraphBlock;
      expect(p.children[1], isA<LineBreakInline>());
    });
  });

  group('parseMarkdown — inline formatting', () {
    test('**bold**', () {
      final p = parseMarkdown('a **b** c').first as ParagraphBlock;
      expect(p.children, [
        const InlineNode.text('a '),
        const InlineNode.bold([InlineNode.text('b')]),
        const InlineNode.text(' c'),
      ]);
    });

    test('*italic*', () {
      final p = parseMarkdown('a *b* c').first as ParagraphBlock;
      expect(p.children[1], const InlineNode.italic([InlineNode.text('b')]));
    });

    test('~~strikethrough~~', () {
      final p = parseMarkdown('~~x~~').first as ParagraphBlock;
      expect(p.children, [
        const InlineNode.strikethrough([InlineNode.text('x')]),
      ]);
    });

    test('<b> and <strong> produce bold', () {
      for (final tag in ['b', 'strong']) {
        final p = parseMarkdown('<$tag>x</$tag>').first as ParagraphBlock;
        expect(p.children, [
          const InlineNode.bold([InlineNode.text('x')]),
        ]);
      }
    });

    test('<i> and <em> produce italic', () {
      for (final tag in ['i', 'em']) {
        final p = parseMarkdown('<$tag>x</$tag>').first as ParagraphBlock;
        expect(p.children, [
          const InlineNode.italic([InlineNode.text('x')]),
        ]);
      }
    });

    test('<u> produces underline', () {
      final p = parseMarkdown('<u>x</u>').first as ParagraphBlock;
      expect(p.children, [
        const InlineNode.underline([InlineNode.text('x')]),
      ]);
    });

    test('<s>, <del>, <strike> produce strikethrough', () {
      for (final tag in ['s', 'del', 'strike']) {
        final p = parseMarkdown('<$tag>x</$tag>').first as ParagraphBlock;
        expect(p.children, [
          const InlineNode.strikethrough([InlineNode.text('x')]),
        ]);
      }
    });

    test('nested: **bold _italic_ bold**', () {
      final p = parseMarkdown('**a _b_ c**').first as ParagraphBlock;
      expect(p.children.first, isA<BoldInline>());
      final bold = p.children.first as BoldInline;
      expect(bold.children[1], isA<ItalicInline>());
    });
  });

  group('parseMarkdown — inline code', () {
    test('backtick span', () {
      final p = parseMarkdown('a `code` b').first as ParagraphBlock;
      expect(p.children[1], const InlineNode.code('code'));
    });

    test('content inside code is literal (no markdown)', () {
      final p = parseMarkdown('`**not bold**`').first as ParagraphBlock;
      expect(p.children, [const InlineNode.code('**not bold**')]);
    });

    test('<code> HTML', () {
      final p = parseMarkdown('<code>x</code>').first as ParagraphBlock;
      expect(p.children, [const InlineNode.code('x')]);
    });
  });

  group('parseMarkdown — links', () {
    test('[text](url)', () {
      final p = parseMarkdown('visit [site](https://x.y) today').first
          as ParagraphBlock;
      expect(
        p.children[1],
        const InlineNode.link(
          url: 'https://x.y',
          children: [InlineNode.text('site')],
        ),
      );
    });

    test('<a href="url">text</a>', () {
      final p = parseMarkdown('<a href="https://x.y">site</a>').first
          as ParagraphBlock;
      expect(p.children, [
        const InlineNode.link(
          url: 'https://x.y',
          children: [InlineNode.text('site')],
        ),
      ]);
    });

    test('link with nested bold inside', () {
      final p = parseMarkdown('[**bold**](u)').first as ParagraphBlock;
      final link = p.children.first as LinkInline;
      expect(link.children.first, isA<BoldInline>());
    });

    test('sanitizes javascript: scheme to #', () {
      final p = parseMarkdown('[x](javascript:alert(1))').first as ParagraphBlock;
      final link = p.children.first as LinkInline;
      expect(link.url, '#');
    });

    test('sanitizes data: and vbscript: schemes', () {
      final p1 = parseMarkdown('[x](data:text/html,<script>)').first
          as ParagraphBlock;
      expect((p1.children.first as LinkInline).url, '#');
      final p2 = parseMarkdown('[x](vbscript:evil)').first as ParagraphBlock;
      expect((p2.children.first as LinkInline).url, '#');
    });
  });

  group('parseMarkdown — bare email autolinking', () {
    test('standalone email becomes a mailto link', () {
      final p = parseMarkdown('support@omlapay.com').first as ParagraphBlock;
      expect(p.children, [
        const InlineNode.link(
          url: 'mailto:support@omlapay.com',
          children: [InlineNode.text('support@omlapay.com')],
        ),
      ]);
    });

    test('email embedded in a sentence keeps surrounding text', () {
      final p = parseMarkdown('Reach support@omlapay.com now').first
          as ParagraphBlock;
      expect(p.children[0], const InlineNode.text('Reach '));
      expect(
        p.children[1],
        const InlineNode.link(
          url: 'mailto:support@omlapay.com',
          children: [InlineNode.text('support@omlapay.com')],
        ),
      );
      expect(p.children[2], const InlineNode.text(' now'));
    });

    test('trailing period is left outside the email', () {
      final p = parseMarkdown('Email support@omlapay.com.').first
          as ParagraphBlock;
      expect(
        p.children[1],
        const InlineNode.link(
          url: 'mailto:support@omlapay.com',
          children: [InlineNode.text('support@omlapay.com')],
        ),
      );
      expect(p.children.last, const InlineNode.text('.'));
    });

    test('email inside bold is still linked', () {
      final p = parseMarkdown('**support@omlapay.com**').first
          as ParagraphBlock;
      final bold = p.children.first as BoldInline;
      expect(bold.children.first, isA<LinkInline>());
      expect(
        (bold.children.first as LinkInline).url,
        'mailto:support@omlapay.com',
      );
    });

    test('email inside an existing mailto link is not double-linked', () {
      final p = parseMarkdown(
        '[support@omlapay.com](mailto:support@omlapay.com)',
      ).first as ParagraphBlock;
      final link = p.children.first as LinkInline;
      expect(link.url, 'mailto:support@omlapay.com');
      expect(link.children, [const InlineNode.text('support@omlapay.com')]);
    });

    test('text without a valid email is untouched', () {
      final p = parseMarkdown('mention @handle and a@b').first
          as ParagraphBlock;
      expect(p.children, [const InlineNode.text('mention @handle and a@b')]);
    });
  });

  group('parseMarkdown — bare phone autolinking (international +)', () {
    test('spaced international number becomes a tel link', () {
      final p = parseMarkdown('+995 555 123 456').first as ParagraphBlock;
      expect(p.children, [
        const InlineNode.link(
          url: 'tel:+995555123456',
          children: [InlineNode.text('+995 555 123 456')],
        ),
      ]);
    });

    test('dashed international number strips separators in the URL', () {
      final p = parseMarkdown('+1-234-567-8900').first as ParagraphBlock;
      expect(
        p.children.first,
        const InlineNode.link(
          url: 'tel:+12345678900',
          children: [InlineNode.text('+1-234-567-8900')],
        ),
      );
    });

    test('number with parentheses is linked', () {
      final p = parseMarkdown('Call +1 (234) 567-8900 today').first
          as ParagraphBlock;
      expect(p.children[0], const InlineNode.text('Call '));
      expect(
        p.children[1],
        const InlineNode.link(
          url: 'tel:+12345678900',
          children: [InlineNode.text('+1 (234) 567-8900')],
        ),
      );
      expect(p.children[2], const InlineNode.text(' today'));
    });

    test('trailing period stays outside the number', () {
      final p = parseMarkdown('Reach us at +995 555 123 456.').first
          as ParagraphBlock;
      expect(
        p.children[1],
        const InlineNode.link(
          url: 'tel:+995555123456',
          children: [InlineNode.text('+995 555 123 456')],
        ),
      );
      expect(p.children.last, const InlineNode.text('.'));
    });

    test('too-short +number is left as text', () {
      final p = parseMarkdown('discount +12 34 only').first as ParagraphBlock;
      expect(p.children, [const InlineNode.text('discount +12 34 only')]);
    });

    test('plain numbers (years, sections) are never linked', () {
      final p = parseMarkdown('age 18, year 2026, clause 4.7.1').first
          as ParagraphBlock;
      expect(p.children, [
        const InlineNode.text('age 18, year 2026, clause 4.7.1'),
      ]);
    });

    test('+ following an alphanumeric (e.g. C++) is not a phone number', () {
      final p = parseMarkdown('written in C++ 1995 edition').first
          as ParagraphBlock;
      expect(p.children, [
        const InlineNode.text('written in C++ 1995 edition'),
      ]);
    });

    test('phone inside an existing tel link is not double-linked', () {
      final p = parseMarkdown('[+995 555 123 456](tel:+995555123456)').first
          as ParagraphBlock;
      final link = p.children.first as LinkInline;
      expect(link.url, 'tel:+995555123456');
      expect(link.children, [const InlineNode.text('+995 555 123 456')]);
    });
  });

  group('parseMarkdown — images', () {
    test('![alt](url)', () {
      final p = parseMarkdown('![pic](https://x.y/img.png)').first
          as ParagraphBlock;
      expect(p.children, [
        const InlineNode.image(src: 'https://x.y/img.png', alt: 'pic'),
      ]);
    });

    test('<img src="..." alt="...">', () {
      final p = parseMarkdown('<img src="https://x.y/i.png" alt="pic"/>').first
          as ParagraphBlock;
      expect(
        p.children.first,
        const InlineNode.image(src: 'https://x.y/i.png', alt: 'pic'),
      );
    });

    test('<img> without alt', () {
      final p = parseMarkdown('<img src="https://x.y/i.png">').first
          as ParagraphBlock;
      final img = p.children.first as ImageInline;
      expect(img.alt, isNull);
    });

    test('sanitizes javascript: src', () {
      final p = parseMarkdown('![x](javascript:alert(1))').first
          as ParagraphBlock;
      expect((p.children.first as ImageInline).src, '#');
    });
  });

  group('parseMarkdown — HTML passthrough', () {
    test('unknown block tag <div> preserves children', () {
      final result = parseMarkdown('<div>hello **world**</div>');
      final div = result.first as HtmlPassthroughBlock;
      expect(div.tag, 'div');
      expect(div.children, isNotEmpty);
    });

    test('unknown inline tag <span> becomes HtmlPassthroughInline', () {
      final p = parseMarkdown('<span>text</span>').first as ParagraphBlock;
      expect(p.children.first, isA<HtmlPassthroughInline>());
      final span = p.children.first as HtmlPassthroughInline;
      expect(span.tag, 'span');
      expect(span.children, [const InlineNode.text('text')]);
    });

    test('attributes are preserved on passthrough', () {
      final result = parseMarkdown('<div class="note" id="x">hi</div>');
      final div = result.first as HtmlPassthroughBlock;
      expect(div.attributes['class'], 'note');
      expect(div.attributes['id'], 'x');
    });

    test('<p> HTML is promoted to ParagraphBlock (not passthrough)', () {
      final result = parseMarkdown('<p>hello **world**</p>');
      expect(result.first, isA<ParagraphBlock>());
      final p = result.first as ParagraphBlock;
      expect(p.children.any((c) => c is BoldInline), isTrue);
    });
  });

  group('parseMarkdown — security', () {
    test('<script> content is dropped entirely', () {
      final result = parseMarkdown('before<script>alert(1)</script>after');
      final p = result.first as ParagraphBlock;
      expect(
        p.children.map((n) => (n as TextInline).value).join(''),
        'beforeafter',
      );
    });

    test('<style>, <iframe>, <form>, <textarea> are dropped', () {
      for (final tag in ['style', 'iframe', 'form', 'textarea']) {
        final result = parseMarkdown('a<$tag>X</$tag>b');
        final text = (result.first as ParagraphBlock)
            .children
            .map((n) => (n as TextInline).value)
            .join('');
        expect(text, 'ab', reason: 'tag=$tag');
      }
    });

    test('<input> self-closing tag is dropped', () {
      final result = parseMarkdown('a<input type="text">b');
      expect(
        (result.first as ParagraphBlock)
            .children
            .map((n) => (n as TextInline).value)
            .join(''),
        'ab',
      );
    });

    test('HTML comments are stripped', () {
      final result = parseMarkdown('a<!-- comment -->b');
      expect(
        (result.first as ParagraphBlock)
            .children
            .map((n) => (n as TextInline).value)
            .join(''),
        'ab',
      );
    });

    test('event handler attributes are stripped', () {
      final result = parseMarkdown('<div onclick="bad()" id="x">y</div>');
      final div = result.first as HtmlPassthroughBlock;
      expect(div.attributes.containsKey('onclick'), isFalse);
      expect(div.attributes['id'], 'x');
    });
  });

  group('parseMarkdown — error recovery', () {
    test('unclosed ** emits literal text', () {
      final p = parseMarkdown('**unterminated').first as ParagraphBlock;
      expect(p.children, [const InlineNode.text('**unterminated')]);
    });

    test('unclosed <div> falls back to paragraph', () {
      final result = parseMarkdown('<div>hello');
      expect(result.first, isA<ParagraphBlock>());
    });

    test('unmatched ] is literal', () {
      final p = parseMarkdown('a]b').first as ParagraphBlock;
      expect(p.children, [const InlineNode.text('a]b')]);
    });

    test('unmatched ) is literal', () {
      final p = parseMarkdown('a)b').first as ParagraphBlock;
      expect(p.children, [const InlineNode.text('a)b')]);
    });

    test('empty input yields empty list', () {
      expect(parseMarkdown(''), isEmpty);
    });
  });
}
