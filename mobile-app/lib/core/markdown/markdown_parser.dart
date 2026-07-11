import 'package:flutter/painting.dart' show TextAlign;

import 'html_entities.dart';
import 'markdown_node.dart';

/// Parse [input] (markdown + HTML) into a flat list of top-level block nodes.
/// Returns an empty list for empty or whitespace-only input.
List<BlockNode> parseMarkdown(String input) {
  if (input.trim().isEmpty) return const [];
  final cleaned = _applySecurityHygiene(input);
  if (cleaned.trim().isEmpty) return const [];
  final lines = _splitLines(cleaned);
  return _parseBlocks(lines, 0, lines.length);
}

/// Strip script/style/iframe/form/textarea tags (with their content), drop
/// self-closing <input>, and remove HTML comments. Event handler attributes
/// (`onclick`, etc.) are stripped later in [_parseAttributes].
String _applySecurityHygiene(String input) {
  var cleaned = input;
  const dangerousPaired = ['script', 'style', 'iframe', 'form', 'textarea'];
  for (final tag in dangerousPaired) {
    cleaned = cleaned.replaceAll(
      RegExp(
        '<$tag(\\s[^>]*)?>.*?</$tag>',
        caseSensitive: false,
        dotAll: true,
      ),
      '',
    );
  }
  cleaned = cleaned.replaceAll(
    RegExp(r'<input(\s[^>]*)?/?>', caseSensitive: false),
    '',
  );
  cleaned = cleaned.replaceAll(
    RegExp(r'<!--.*?-->', dotAll: true),
    '',
  );
  return cleaned;
}

List<String> _splitLines(String input) {
  return input.split(RegExp(r'\r\n|\r|\n'));
}

/// Block phase. Consumes [lines] from [from] to [to] and emits block nodes.
List<BlockNode> _parseBlocks(List<String> lines, int from, int to) {
  final blocks = <BlockNode>[];
  var i = from;
  while (i < to) {
    final line = lines[i];

    // Skip blank lines.
    if (line.trim().isEmpty) {
      i++;
      continue;
    }

    // Horizontal rule (check before headings to avoid --- ambiguity).
    if (_isHorizontalRule(line)) {
      blocks.add(const HorizontalRuleBlock());
      i++;
      continue;
    }

    // Fenced code block: ```[lang]
    if (line.startsWith('```')) {
      final lang = line.substring(3).trim();
      final buffer = <String>[];
      var j = i + 1;
      while (j < to && !lines[j].startsWith('```')) {
        buffer.add(lines[j]);
        j++;
      }
      blocks.add(CodeBlock(
        code: buffer.join('\n'),
        language: lang.isEmpty ? null : lang,
      ));
      i = j < to ? j + 1 : j; // skip closing fence
      continue;
    }

    // HTML <pre> block.
    final htmlPre = _matchHtmlBlockTag(
      lines,
      i,
      tag: 'pre',
      build: (inner) {
        final raw = inner.join('\n');
        // Strip an optional inner <code>...</code>.
        final codeInner = RegExp(
          r'<code(\s[^>]*)?>(.*)</code>',
          caseSensitive: false,
          dotAll: true,
        ).firstMatch(raw);
        final code = codeInner == null ? raw : codeInner.group(2)!;
        return CodeBlock(code: code.trim());
      },
    );
    if (htmlPre != null) {
      blocks.add(htmlPre.node);
      i = htmlPre.nextIndex;
      continue;
    }

    // Markdown heading: ^#{1,6}\s+
    final mdHeading = _matchMarkdownHeading(line);
    if (mdHeading != null) {
      blocks.add(mdHeading);
      i++;
      continue;
    }

    // Marker-only heading line (e.g. "##" with no text after). Skip rather
    // than let it fall through to the paragraph collector and render as "##".
    if (_markerOnlyHeading.hasMatch(line)) {
      i++;
      continue;
    }

    // HTML heading block: <h[1-6]...>...</h[1-6]>
    final htmlHeading = _matchHtmlHeadingBlock(lines, i);
    if (htmlHeading != null) {
      blocks.add(htmlHeading.node);
      i = htmlHeading.nextIndex;
      continue;
    }

    // Blockquote: lines starting with >
    if (line.startsWith('>')) {
      final quoteEnd = _findBlockquoteEnd(lines, i, to);
      final stripped = lines
          .sublist(i, quoteEnd)
          .map(_stripBlockquoteMarker)
          .toList();
      blocks.add(
        BlockquoteBlock(children: _parseBlocks(stripped, 0, stripped.length)),
      );
      i = quoteEnd;
      continue;
    }

    // HTML <blockquote>
    final htmlBlockquote = _matchHtmlBlockTag(
      lines,
      i,
      tag: 'blockquote',
      build: (inner) => BlockquoteBlock(
        children: _parseBlocks(inner, 0, inner.length),
      ),
    );
    if (htmlBlockquote != null) {
      blocks.add(htmlBlockquote.node);
      i = htmlBlockquote.nextIndex;
      continue;
    }

    // Unordered list (markdown).
    final ulMatch = _matchUnorderedList(lines, i, to);
    if (ulMatch != null) {
      blocks.add(ulMatch.node);
      i = ulMatch.nextIndex;
      continue;
    }

    // HTML <ul>
    final htmlUl = _matchHtmlBlockTag(
      lines,
      i,
      tag: 'ul',
      build: (inner) => _parseHtmlListItems(inner, ordered: false),
    );
    if (htmlUl != null) {
      blocks.add(htmlUl.node);
      i = htmlUl.nextIndex;
      continue;
    }

    // Ordered list (markdown).
    final olMatch = _matchOrderedList(lines, i, to);
    if (olMatch != null) {
      blocks.add(olMatch.node);
      i = olMatch.nextIndex;
      continue;
    }

    // HTML <ol>
    final htmlOl = _matchHtmlBlockTagWithAttrs(
      lines,
      i,
      tag: 'ol',
      build: (inner, attrs) {
        final list = _parseHtmlListItems(inner, ordered: true) as OrderedListBlock;
        final start = int.tryParse(attrs['start'] ?? '') ?? 1;
        return OrderedListBlock(items: list.items, startNumber: start);
      },
    );
    if (htmlOl != null) {
      blocks.add(htmlOl.node);
      i = htmlOl.nextIndex;
      continue;
    }

    // Pipe table (markdown).
    final tableMatch = _matchPipeTable(lines, i, to);
    if (tableMatch != null) {
      blocks.add(tableMatch.node);
      i = tableMatch.nextIndex;
      continue;
    }

    // HTML <table>
    final htmlTable = _matchHtmlBlockTag(
      lines,
      i,
      tag: 'table',
      build: _buildHtmlTable,
    );
    if (htmlTable != null) {
      blocks.add(htmlTable.node);
      i = htmlTable.nextIndex;
      continue;
    }

    // HTML <p> — promoted to ParagraphBlock (spec normalization table).
    final htmlP = _matchHtmlBlockTag(
      lines,
      i,
      tag: 'p',
      build: (inner) => ParagraphBlock(
        children: _parseInlines(inner.join(' ').trim()),
      ),
    );
    if (htmlP != null) {
      blocks.add(htmlP.node);
      i = htmlP.nextIndex;
      continue;
    }

    // HTML passthrough — any remaining unknown block-level tag.
    final passthrough = _matchHtmlPassthroughBlock(lines, i);
    if (passthrough != null) {
      blocks.add(passthrough.node);
      i = passthrough.nextIndex;
      continue;
    }

    // Paragraph: collect contiguous non-blank, non-block lines.
    // The first line is accepted unconditionally — all block matchers already
    // failed on it — so we always advance past `paraStart` to guarantee
    // progress. Interrupts apply only from the next line onward.
    final paraStart = i;
    i++;
    while (i < to) {
      final cur = lines[i];
      if (cur.trim().isEmpty) break;
      if (_isHorizontalRule(cur)) break;
      if (cur.startsWith('```')) break;
      if (RegExp(r'^<pre(\s|>)', caseSensitive: false).hasMatch(cur)) break;
      if (_matchMarkdownHeading(cur) != null) break;
      if (RegExp(r'^<h[1-6](\s|>)', caseSensitive: false).hasMatch(cur)) break;
      if (cur.startsWith('>')) break;
      if (RegExp(r'^<blockquote(\s|>)', caseSensitive: false).hasMatch(cur)) break;
      if (_unorderedMarker.hasMatch(cur) && !cur.startsWith(' ')) break;
      if (_orderedMarker.hasMatch(cur) && !cur.startsWith(' ')) break;
      if (RegExp(r'^<(ul|ol)(\s|>)', caseSensitive: false).hasMatch(cur)) break;
      if (cur.trim().startsWith('|') && cur.trim().endsWith('|')) break;
      if (RegExp(r'^<table(\s|>)', caseSensitive: false).hasMatch(cur)) break;
      if (RegExp(r'^<p(\s|>)', caseSensitive: false).hasMatch(cur)) break;
      i++;
    }
    final text = _joinInlineLines(lines.sublist(paraStart, i));
    blocks.add(ParagraphBlock(children: _parseInlines(text)));
  }
  return blocks;
}

/// Joins the lines of a paragraph into a single string for the inline phase,
/// honouring Markdown line-break rules:
///
/// - A line ending in two or more spaces, or in a backslash, is a *hard* line
///   break → emitted as `<br>` (which the inline scanner turns into a
///   [LineBreakInline]).
/// - Any other line boundary is a *soft* break → collapses to a single space.
///
/// Trailing whitespace is trimmed so soft breaks never produce double spaces.
String _joinInlineLines(List<String> lines) {
  final buffer = StringBuffer();
  for (var k = 0; k < lines.length; k++) {
    final line = lines[k];
    final isLast = k == lines.length - 1;
    if (isLast) {
      buffer.write(line);
      break;
    }
    if (RegExp(r' {2,}$').hasMatch(line)) {
      buffer
        ..write(line.trimRight())
        ..write('<br>');
    } else if (line.endsWith(r'\')) {
      buffer
        ..write(line.substring(0, line.length - 1).trimRight())
        ..write('<br>');
    } else {
      buffer
        ..write(line.trimRight())
        ..write(' ');
    }
  }
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// Horizontal rule
// ---------------------------------------------------------------------------

bool _isHorizontalRule(String line) {
  final trimmed = line.trim();
  if (trimmed == '<hr>' || trimmed == '<hr/>' || trimmed == '<hr />') return true;
  if (RegExp(r'^(-{3,}|_{3,}|\*{3,})$').hasMatch(trimmed)) return true;
  return false;
}

// ---------------------------------------------------------------------------
// Headings
// ---------------------------------------------------------------------------

HeadingBlock? _matchMarkdownHeading(String line) {
  final match = RegExp(r'^(#{1,6})\s+(.+?)\s*#*\s*$').firstMatch(line);
  if (match == null) return null;
  final level = match.group(1)!.length;
  final text = match.group(2)!;
  return HeadingBlock(level: level, children: _parseInlines(text));
}

final _markerOnlyHeading = RegExp(r'^#{1,6}\s*$');

_BlockMatch? _matchHtmlHeadingBlock(List<String> lines, int i) {
  final openMatch = RegExp(
    r'^<h([1-6])(\s[^>]*)?>(.*)$',
    caseSensitive: false,
  ).firstMatch(lines[i]);
  if (openMatch == null) return null;
  final level = int.parse(openMatch.group(1)!);
  final attrs = _parseAttributes(openMatch.group(2) ?? '');
  final closeTag = '</h$level>';
  var j = i;
  final buffer = StringBuffer();
  while (j < lines.length) {
    final current = j == i ? (openMatch.group(3) ?? '') : lines[j];
    final closeIdx = current.toLowerCase().indexOf(closeTag.toLowerCase());
    if (closeIdx != -1) {
      // Single-line or end of multi-line: use only content before close tag.
      if (j == i) {
        buffer.clear();
        buffer.write(current.substring(0, closeIdx));
      } else {
        buffer.write('\n${current.substring(0, closeIdx)}');
      }
      final alignment = _alignFromAttr(attrs['align']);
      return _BlockMatch(
        HeadingBlock(
          level: level,
          children: _parseInlines(buffer.toString().trim()),
          alignment: alignment,
        ),
        j + 1,
      );
    }
    if (j == i) {
      buffer.write(openMatch.group(3) ?? '');
    } else {
      buffer.write('\n$current');
    }
    j++;
  }
  return null; // Unclosed — caller falls back to paragraph.
}

// ---------------------------------------------------------------------------
// Blockquotes
// ---------------------------------------------------------------------------

int _findBlockquoteEnd(List<String> lines, int from, int to) {
  var j = from;
  while (j < to && lines[j].startsWith('>')) {
    j++;
  }
  return j;
}

String _stripBlockquoteMarker(String line) {
  if (line.startsWith('> ')) return line.substring(2);
  if (line.startsWith('>')) return line.substring(1);
  return line;
}

// ---------------------------------------------------------------------------
// Lists
// ---------------------------------------------------------------------------

final _unorderedMarker = RegExp(r'^(\s*)([-*+])\s+(.*)$');
final _orderedMarker = RegExp(r'^(\s*)(\d+)\.\s+(.*)$');

_BlockMatch? _matchUnorderedList(List<String> lines, int from, int to) =>
    _matchList(lines, from, to, ordered: false);

_BlockMatch? _matchOrderedList(List<String> lines, int from, int to) =>
    _matchList(lines, from, to, ordered: true);

_BlockMatch? _matchList(
  List<String> lines,
  int from,
  int to, {
  required bool ordered,
}) {
  final marker = ordered ? _orderedMarker : _unorderedMarker;
  final first = marker.firstMatch(lines[from]);
  if (first == null || first.group(1)!.isNotEmpty) return null;
  final startNumber = ordered ? int.parse(first.group(2)!) : 1;
  final items = <ListItem>[];
  var i = from;
  while (i < to) {
    final match = marker.firstMatch(lines[i]);
    if (match == null) break;
    if (match.group(1)!.isNotEmpty) break;
    final firstLine = match.group(3)!;
    final itemContentLines = <String>[firstLine];
    i++;
    // Collect continuation and nested children.
    while (i < to) {
      final cur = lines[i];
      if (cur.trim().isEmpty) break;
      // Another top-level marker ends this item.
      final mkTop = _unorderedMarker.firstMatch(cur) ??
          _orderedMarker.firstMatch(cur);
      if (mkTop != null && mkTop.group(1)!.isEmpty) break;
      itemContentLines.add(cur);
      i++;
    }
    items.add(_parseListItemContent(itemContentLines));
  }
  return _BlockMatch(
    ordered
        ? OrderedListBlock(items: items, startNumber: startNumber)
        : UnorderedListBlock(items: items),
    i,
  );
}

ListItem _parseListItemContent(List<String> contentLines) {
  final body = contentLines.first;
  final rest = contentLines.skip(1).toList();
  final nestedStart = rest.indexWhere(
    (l) => RegExp(r'^\s{2,}([-*+]|\d+\.)\s').hasMatch(l),
  );
  final continuationLines =
      nestedStart == -1 ? rest : rest.sublist(0, nestedStart);
  final nestedLines = nestedStart == -1
      ? const <String>[]
      : rest
          .sublist(nestedStart)
          .map((l) => l.replaceFirst(RegExp(r'^\s{2,4}'), ''))
          .toList();
  final children = <BlockNode>[
    ParagraphBlock(
      children: _parseInlines(
        [body, ...continuationLines.map((l) => l.trim())].join(' '),
      ),
    ),
    if (nestedLines.isNotEmpty) ..._parseBlocks(nestedLines, 0, nestedLines.length),
  ];
  return ListItem(children: children);
}

BlockNode _parseHtmlListItems(List<String> inner, {required bool ordered}) {
  final joined = inner.join('\n');
  final liPattern = RegExp(
    r'<li(\s[^>]*)?>(.*?)</li>',
    caseSensitive: false,
    dotAll: true,
  );
  final items = <ListItem>[
    for (final m in liPattern.allMatches(joined))
      ListItem(children: [
        ParagraphBlock(children: _parseInlines(m.group(2)!.trim())),
      ]),
  ];
  return ordered
      ? OrderedListBlock(items: items)
      : UnorderedListBlock(items: items);
}

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

_BlockMatch? _matchPipeTable(List<String> lines, int from, int to) {
  if (from + 1 >= to) return null;
  final headerCells = _splitTableRow(lines[from]);
  final dividerCells = _splitTableRow(lines[from + 1]);
  if (headerCells == null || dividerCells == null) return null;
  if (headerCells.length != dividerCells.length) return null;
  final alignments = <TextAlign?>[];
  for (final c in dividerCells) {
    final trimmed = c.trim();
    if (!RegExp(r'^:?-{3,}:?$').hasMatch(trimmed)) return null;
    final left = trimmed.startsWith(':');
    final right = trimmed.endsWith(':');
    if (left && right) {
      alignments.add(TextAlign.center);
    } else if (left) {
      alignments.add(TextAlign.left);
    } else if (right) {
      alignments.add(TextAlign.right);
    } else {
      alignments.add(null);
    }
  }
  final rows = <MarkdownTableRow>[_rowFromCells(headerCells)];
  var j = from + 2;
  while (j < to) {
    final cells = _splitTableRow(lines[j]);
    if (cells == null) break;
    rows.add(_rowFromCells(cells));
    j++;
  }
  return _BlockMatch(
    TableBlock(rows: rows, columnAlignments: alignments),
    j,
  );
}

List<String>? _splitTableRow(String line) {
  final trimmed = line.trim();
  if (!trimmed.startsWith('|') || !trimmed.endsWith('|')) return null;
  final inner = trimmed.substring(1, trimmed.length - 1);
  return inner.split('|').map((c) => c.trim()).toList();
}

MarkdownTableRow _rowFromCells(List<String> cells) {
  return MarkdownTableRow(
    cells: [
      for (final c in cells) TableCell(children: _parseInlines(c)),
    ],
  );
}

BlockNode _buildHtmlTable(List<String> inner) {
  final joined = inner.join('\n');
  final rowPattern = RegExp(
    r'<tr(\s[^>]*)?>(.*?)</tr>',
    caseSensitive: false,
    dotAll: true,
  );
  final cellPattern = RegExp(
    r'<(th|td)(\s[^>]*)?>(.*?)</\1>',
    caseSensitive: false,
    dotAll: true,
  );
  final rows = <MarkdownTableRow>[];
  final alignSet = <int, TextAlign>{};
  for (final rm in rowPattern.allMatches(joined)) {
    final cells = <TableCell>[];
    var colIdx = 0;
    for (final cm in cellPattern.allMatches(rm.group(2)!)) {
      final attrs = _parseAttributes(cm.group(2) ?? '');
      final align = _alignFromAttr(attrs['align']);
      if (align != null) alignSet[colIdx] = align;
      cells.add(TableCell(children: _parseInlines(cm.group(3)!.trim())));
      colIdx++;
    }
    rows.add(MarkdownTableRow(cells: cells));
  }
  final colCount = rows.isEmpty ? 0 : rows.first.cells.length;
  final alignments = <TextAlign?>[
    for (var k = 0; k < colCount; k++) alignSet[k],
  ];
  return TableBlock(rows: rows, columnAlignments: alignments);
}

// ---------------------------------------------------------------------------
// Generic HTML block helpers
// ---------------------------------------------------------------------------

class _BlockMatch {
  _BlockMatch(this.node, this.nextIndex);
  final BlockNode node;
  final int nextIndex;
}

_BlockMatch? _matchHtmlBlockTag(
  List<String> lines,
  int i, {
  required String tag,
  required BlockNode Function(List<String> inner) build,
}) {
  final open =
      RegExp('^<$tag(\\s[^>]*)?>(.*)\$', caseSensitive: false)
          .firstMatch(lines[i]);
  if (open == null) return null;
  final close = '</$tag>';
  final buffer = <String>[];
  final firstRemainder = open.group(2) ?? '';
  var j = i;
  while (j < lines.length) {
    final content = j == i ? firstRemainder : lines[j];
    final closeIdx = content.toLowerCase().indexOf(close.toLowerCase());
    if (closeIdx != -1) {
      buffer.add(content.substring(0, closeIdx));
      return _BlockMatch(build(buffer), j + 1);
    }
    buffer.add(content);
    j++;
  }
  return null;
}

_BlockMatch? _matchHtmlBlockTagWithAttrs(
  List<String> lines,
  int i, {
  required String tag,
  required BlockNode Function(List<String> inner, Map<String, String> attrs) build,
}) {
  final open =
      RegExp('^<$tag(\\s[^>]*)?>(.*)\$', caseSensitive: false)
          .firstMatch(lines[i]);
  if (open == null) return null;
  final attrs = _parseAttributes(open.group(1) ?? '');
  final close = '</$tag>';
  final buffer = <String>[];
  final firstRemainder = open.group(2) ?? '';
  var j = i;
  while (j < lines.length) {
    final content = j == i ? firstRemainder : lines[j];
    final closeIdx = content.toLowerCase().indexOf(close.toLowerCase());
    if (closeIdx != -1) {
      buffer.add(content.substring(0, closeIdx));
      return _BlockMatch(build(buffer, attrs), j + 1);
    }
    buffer.add(content);
    j++;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Attribute parsing + alignment
// ---------------------------------------------------------------------------

Map<String, String> _parseAttributes(String attrString) {
  final result = <String, String>{};
  final pattern = RegExp(r'''(\w+)\s*=\s*("([^"]*)"|'([^']*)'|(\S+))''');
  for (final m in pattern.allMatches(attrString)) {
    final name = m.group(1)!.toLowerCase();
    // Drop event-handler attributes (onclick, onload, onerror, …).
    if (name.startsWith('on')) continue;
    final value = m.group(3) ?? m.group(4) ?? m.group(5) ?? '';
    result[name] = value;
  }
  return result;
}

// ---------------------------------------------------------------------------
// HTML passthrough (block)
// ---------------------------------------------------------------------------

const _handledHtmlTags = {
  // Block-level handled by dedicated matchers
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
  'p', 'blockquote', 'ul', 'ol', 'li',
  'pre', 'hr', 'table', 'tr', 'th', 'td', 'thead', 'tbody',
  // Inline handled by the inline scanner
  'br', 'b', 'strong', 'i', 'em', 'u', 's', 'del', 'strike',
  'code', 'a', 'img', 'span',
};

_BlockMatch? _matchHtmlPassthroughBlock(List<String> lines, int i) {
  final open = RegExp(r'^<(\w+)(\s[^>]*)?>(.*)$').firstMatch(lines[i]);
  if (open == null) return null;
  final tag = open.group(1)!.toLowerCase();
  if (_handledHtmlTags.contains(tag)) return null;
  final attrs = _parseAttributes(open.group(2) ?? '');
  final close = '</$tag>';
  final buffer = <String>[];
  final firstRemainder = open.group(3) ?? '';
  var j = i;
  while (j < lines.length) {
    final content = j == i ? firstRemainder : lines[j];
    final closeIdx = content.toLowerCase().indexOf(close.toLowerCase());
    if (closeIdx != -1) {
      buffer.add(content.substring(0, closeIdx));
      return _BlockMatch(
        HtmlPassthroughBlock(
          tag: tag,
          attributes: attrs,
          children: _parseBlocks(buffer, 0, buffer.length),
        ),
        j + 1,
      );
    }
    buffer.add(content);
    j++;
  }
  return null;
}

TextAlign? _alignFromAttr(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'left':
      return TextAlign.left;
    case 'right':
      return TextAlign.right;
    case 'center':
      return TextAlign.center;
    case 'justify':
      return TextAlign.justify;
    default:
      return null;
  }
}

// ---------------------------------------------------------------------------
// Inline phase — character-level scanner with delimiter stack
// ---------------------------------------------------------------------------

List<InlineNode> _parseInlines(String input) {
  return _InlineScanner(input).parseAll();
}

enum _InlineKind { bold, italic, underline, strikethrough }

InlineNode _wrapInlineKind(_InlineKind kind, List<InlineNode> children) {
  switch (kind) {
    case _InlineKind.bold:
      return InlineNode.bold(children);
    case _InlineKind.italic:
      return InlineNode.italic(children);
    case _InlineKind.underline:
      return InlineNode.underline(children);
    case _InlineKind.strikethrough:
      return InlineNode.strikethrough(children);
  }
}

String _sanitizeUrl(String url) {
  final lower = url.trim().toLowerCase();
  if (lower.startsWith('javascript:') ||
      lower.startsWith('data:') ||
      lower.startsWith('vbscript:')) {
    return '#';
  }
  return url;
}

/// Matches a bare email address. Anchored at the scan position via
/// [RegExp.matchAsPrefix]; requires a domain with at least one dot and a
/// letters-only TLD so trailing punctuation (e.g. `…@x.com.`) stays out.
final _emailPattern = RegExp(r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}');

/// Matches a candidate international phone number: a leading `+`, a digit, then
/// digits and `( ) - space` separators ending in a digit. The digit count is
/// validated separately (7–15) so short tokens like `+12` aren't linked.
final _phonePattern = RegExp(r'\+\d[\d\s()\-]*\d');

/// Characters that can appear in an email local part. Used to detect whether
/// the scan position is at a token boundary (so we don't link mid-word).
bool _isEmailLocalChar(int codeUnit) {
  return _isAlphanumeric(codeUnit) ||
      codeUnit == 0x2E || // .
      codeUnit == 0x5F || // _
      codeUnit == 0x25 || // %
      codeUnit == 0x2B || // +
      codeUnit == 0x2D; // -
}

bool _isAlphanumeric(int codeUnit) {
  return (codeUnit >= 0x30 && codeUnit <= 0x39) || // 0-9
      (codeUnit >= 0x41 && codeUnit <= 0x5A) || // A-Z
      (codeUnit >= 0x61 && codeUnit <= 0x7A); // a-z
}

class _InlineScanner {
  _InlineScanner(this.input, {this.autolink = true});

  final String input;

  /// When true, bare email addresses and international phone numbers in plain
  /// text are promoted to `mailto:` / `tel:` links. Disabled while scanning the
  /// text inside an existing link so we never produce a link nested in a link.
  final bool autolink;

  int pos = 0;

  static const _inlineTagMap = {
    'b': _InlineKind.bold,
    'strong': _InlineKind.bold,
    'i': _InlineKind.italic,
    'em': _InlineKind.italic,
    'u': _InlineKind.underline,
    's': _InlineKind.strikethrough,
    'del': _InlineKind.strikethrough,
    'strike': _InlineKind.strikethrough,
  };

  List<InlineNode> parseAll() {
    final result = <InlineNode>[];
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        result.add(InlineNode.text(decodeHtmlEntities(buffer.toString())));
        buffer.clear();
      }
    }

    while (pos < input.length) {
      // <br> / <br/> / <br />
      if (_tryReadSelfClosingTag('br')) {
        flush();
        result.add(const InlineNode.lineBreak());
        continue;
      }

      // Inline code via backticks (literal, no further parsing).
      if (input[pos] == '`') {
        final end = input.indexOf('`', pos + 1);
        if (end != -1) {
          flush();
          result.add(InlineNode.code(input.substring(pos + 1, end)));
          pos = end + 1;
          continue;
        }
      }

      // Image: ![alt](url)
      if (input[pos] == '!' && pos + 1 < input.length && input[pos + 1] == '[') {
        final img = _tryReadImage();
        if (img != null) {
          flush();
          result.add(img);
          continue;
        }
      }

      // Link: [text](url)
      if (input[pos] == '[') {
        final link = _tryReadLink();
        if (link != null) {
          flush();
          result.add(link);
          continue;
        }
      }

      // HTML inline formatting tag: <b>, <strong>, <i>, <em>, <u>, <s>, <del>,
      // <strike>, <code>, <a>, <img>
      if (input[pos] == '<') {
        final htmlNode = _tryReadInlineHtmlTag();
        if (htmlNode != null) {
          flush();
          result.add(htmlNode);
          continue;
        }
      }

      // Markdown formatting: **, __, ~~, *, _
      final mdFmt = _tryReadMarkdownFormatting();
      if (mdFmt != null) {
        flush();
        result.add(mdFmt);
        continue;
      }

      // Bare email autolink: support@example.com -> mailto:support@example.com.
      // Only attempt at a token boundary so we don't link a sub-span of a word.
      if (autolink &&
          (pos == 0 || !_isEmailLocalChar(input.codeUnitAt(pos - 1)))) {
        final email = _emailPattern.matchAsPrefix(input, pos);
        if (email != null) {
          flush();
          final address = email.group(0)!;
          result.add(
            InlineNode.link(
              url: 'mailto:$address',
              children: [InlineNode.text(address)],
            ),
          );
          pos = email.end;
          continue;
        }
      }

      // Bare phone autolink: +995 555 123 456 -> tel:+995555123456. Conservative
      // — requires a leading '+' with 7–15 digits, sitting at a boundary so we
      // never treat `C++` or arithmetic like `5+5` as a phone number.
      if (autolink &&
          input[pos] == '+' &&
          (pos == 0 || !_isAlphanumeric(input.codeUnitAt(pos - 1)))) {
        final phone = _phonePattern.matchAsPrefix(input, pos);
        if (phone != null) {
          final raw = phone.group(0)!;
          final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.length >= 7 && digits.length <= 15) {
            flush();
            result.add(
              InlineNode.link(
                url: 'tel:+$digits',
                children: [InlineNode.text(raw)],
              ),
            );
            pos = phone.end;
            continue;
          }
        }
      }

      // Escape: backslash quotes the next character literally.
      if (input[pos] == r'\' && pos + 1 < input.length) {
        buffer.write(input[pos + 1]);
        pos += 2;
        continue;
      }

      buffer.write(input[pos]);
      pos++;
    }

    flush();
    return result;
  }

  bool _tryReadSelfClosingTag(String name) {
    final lower = input.substring(pos).toLowerCase();
    for (final form in ['<$name>', '<$name/>', '<$name />']) {
      if (lower.startsWith(form)) {
        pos += form.length;
        return true;
      }
    }
    return false;
  }

  InlineNode? _tryReadImage() {
    final bracketOpen = pos + 1; // points at [
    final closeBracket = _findMatching(input, bracketOpen, '[', ']');
    if (closeBracket == -1) return null;
    if (closeBracket + 1 >= input.length || input[closeBracket + 1] != '(') {
      return null;
    }
    final closeParen = input.indexOf(')', closeBracket + 2);
    if (closeParen == -1) return null;
    final alt = input.substring(bracketOpen + 1, closeBracket);
    final src = _sanitizeUrl(input.substring(closeBracket + 2, closeParen));
    pos = closeParen + 1;
    return InlineNode.image(src: src, alt: alt.isEmpty ? null : alt);
  }

  InlineNode? _tryReadLink() {
    final closeBracket = _findMatching(input, pos, '[', ']');
    if (closeBracket == -1) return null;
    if (closeBracket + 1 >= input.length || input[closeBracket + 1] != '(') {
      return null;
    }
    final closeParen = input.indexOf(')', closeBracket + 2);
    if (closeParen == -1) return null;
    final text = input.substring(pos + 1, closeBracket);
    final url = input.substring(closeBracket + 2, closeParen);
    final safeUrl = _sanitizeUrl(url);
    final children = _InlineScanner(text, autolink: false).parseAll();
    pos = closeParen + 1;
    return InlineNode.link(url: safeUrl, children: children);
  }

  InlineNode? _tryReadInlineHtmlTag() {
    final openMatch = RegExp(r'^<(\w+)(\s[^>]*)?(/?)>', caseSensitive: false)
        .matchAsPrefix(input, pos);
    if (openMatch == null) return null;
    final name = openMatch.group(1)!.toLowerCase();
    final attrString = openMatch.group(2) ?? '';
    final selfClosing = openMatch.group(3) == '/';
    final tagEnd = openMatch.end;

    // <img> — self-closing, emits image node.
    if (name == 'img') {
      final attrs = _parseAttributes(attrString);
      final src = _sanitizeUrl(attrs['src'] ?? '');
      final alt = attrs['alt'];
      pos = tagEnd;
      return InlineNode.image(
        src: src,
        alt: (alt == null || alt.isEmpty) ? null : alt,
      );
    }

    // <br> handled by _tryReadSelfClosingTag earlier.
    if (name == 'br') {
      pos = tagEnd;
      return const InlineNode.lineBreak();
    }

    if (selfClosing) {
      // Unknown self-closing tag — skip it, let task 19 promote to passthrough.
      return null;
    }

    // <code> — literal content until </code>.
    if (name == 'code') {
      final close = '</code>';
      final closeIdx = input.toLowerCase().indexOf(close, tagEnd);
      if (closeIdx == -1) return null;
      final inner = input.substring(tagEnd, closeIdx);
      pos = closeIdx + close.length;
      return InlineNode.code(inner);
    }

    // <a href="..."> — link.
    if (name == 'a') {
      final close = '</a>';
      final closeIdx = input.toLowerCase().indexOf(close, tagEnd);
      if (closeIdx == -1) return null;
      final attrs = _parseAttributes(attrString);
      final href = _sanitizeUrl(attrs['href'] ?? '#');
      final inner = input.substring(tagEnd, closeIdx);
      pos = closeIdx + close.length;
      return InlineNode.link(
        url: href,
        children: _InlineScanner(inner, autolink: false).parseAll(),
      );
    }

    // Known formatting tags: <b>, <strong>, <i>, <em>, <u>, <s>, <del>, <strike>.
    final kind = _inlineTagMap[name];
    if (kind != null) {
      final close = '</$name>';
      final closeIdx = input.toLowerCase().indexOf(close, tagEnd);
      if (closeIdx == -1) return null;
      final inner = input.substring(tagEnd, closeIdx);
      pos = closeIdx + close.length;
      return _wrapInlineKind(kind, _InlineScanner(inner).parseAll());
    }

    // Unknown inline tag — emit as HtmlPassthroughInline with attributes
    // preserved and children recursively parsed. If the close tag is missing,
    // leave the raw `<tag…>` in place so the main loop can emit it literally.
    final close = '</$name>';
    final closeIdx = input.toLowerCase().indexOf(close, tagEnd);
    if (closeIdx == -1) return null;
    final attrs = _parseAttributes(attrString);
    final inner = input.substring(tagEnd, closeIdx);
    pos = closeIdx + close.length;
    return InlineNode.htmlPassthrough(
      tag: name,
      attributes: attrs,
      children: _InlineScanner(inner).parseAll(),
    );
  }

  InlineNode? _tryReadMarkdownFormatting() {
    // Order matters: **, __, ~~ before *, _.
    const candidates = <(String, _InlineKind)>[
      ('**', _InlineKind.bold),
      ('__', _InlineKind.bold),
      ('~~', _InlineKind.strikethrough),
      ('*', _InlineKind.italic),
      ('_', _InlineKind.italic),
    ];
    for (final entry in candidates) {
      final delim = entry.$1;
      if (!input.startsWith(delim, pos)) continue;
      final searchFrom = pos + delim.length;
      final closeIdx = input.indexOf(delim, searchFrom);
      if (closeIdx == -1) continue;
      final inner = input.substring(searchFrom, closeIdx);
      if (inner.isEmpty) continue;
      pos = closeIdx + delim.length;
      return _wrapInlineKind(entry.$2, _InlineScanner(inner).parseAll());
    }
    return null;
  }

  int _findMatching(String s, int openPos, String open, String close) {
    var depth = 1;
    var i = openPos + 1;
    while (i < s.length) {
      if (s[i] == r'\' && i + 1 < s.length) {
        i += 2;
        continue;
      }
      if (s[i] == open) depth++;
      if (s[i] == close) {
        depth--;
        if (depth == 0) return i;
      }
      i++;
    }
    return -1;
  }
}
