import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'markdown_node.dart';

typedef OnLinkTap = void Function(String url);

/// Render [blocks] to a widget. Link gesture recognizers are allocated per
/// build and left to the framework to dispose at rebuild (acceptable for the
/// stateless widget path). Callers that need explicit recognizer lifecycle
/// management (selectable mode) should use [renderBlocksWithRecognizers] and
/// dispose the returned recognizers when replacing the widget tree.
Widget renderBlocks(List<BlockNode> blocks, {required OnLinkTap? onLinkTap}) {
  return renderBlocksWithRecognizers(blocks, onLinkTap: onLinkTap).widget;
}

class RenderedMarkdown {
  RenderedMarkdown(this.widget, this.recognizers);
  final Widget widget;
  final List<TapGestureRecognizer> recognizers;
}

RenderedMarkdown renderBlocksWithRecognizers(
  List<BlockNode> blocks, {
  required OnLinkTap? onLinkTap,
}) {
  final recognizers = <TapGestureRecognizer>[];
  final widget = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < blocks.length; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        Builder(
          builder: (context) =>
              _renderBlock(blocks[i], context, onLinkTap, recognizers),
        ),
      ],
    ],
  );
  return RenderedMarkdown(widget, recognizers);
}

// ---------------------------------------------------------------------------
// Block rendering
// ---------------------------------------------------------------------------

Widget _renderBlock(
  BlockNode node,
  BuildContext context,
  OnLinkTap? onLinkTap,
  List<TapGestureRecognizer>? recognizers,
) {
  switch (node) {
    case HeadingBlock(:final level, :final children, :final alignment):
      return _renderHeading(
        level,
        children,
        alignment,
        context,
        onLinkTap,
        recognizers,
      );
    case ParagraphBlock(:final children, :final alignment):
      return _renderParagraph(
        children,
        alignment,
        context,
        onLinkTap,
        recognizers,
      );
    case BlockquoteBlock(:final children):
      return _renderBlockquote(children, context, onLinkTap, recognizers);
    case UnorderedListBlock(:final items):
      return _renderList(
        items,
        context,
        onLinkTap,
        recognizers,
        ordered: false,
        startNumber: 1,
      );
    case OrderedListBlock(:final items, :final startNumber):
      return _renderList(
        items,
        context,
        onLinkTap,
        recognizers,
        ordered: true,
        startNumber: startNumber,
      );
    case CodeBlock(:final code):
      return _renderCodeBlock(code, context);
    case HorizontalRuleBlock():
      return const Divider();
    case TableBlock(:final rows, :final columnAlignments):
      return _renderTable(
        rows,
        columnAlignments,
        context,
        onLinkTap,
        recognizers,
      );
    case HtmlPassthroughBlock(:final tag, :final attributes, :final children):
      final column = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _renderBlock(children[i], context, onLinkTap, recognizers),
          ],
        ],
      );
      final align = _passthroughAlignment(tag, attributes);
      if (align == null) return column;
      return SizedBox(
        width: double.infinity,
        child: Align(alignment: align, child: column),
      );
  }
}

AlignmentGeometry? _passthroughAlignment(
  String tag,
  Map<String, String> attributes,
) {
  if (tag == 'center') return Alignment.topCenter;
  final raw =
      (attributes['align'] ?? _readTextAlignFromStyle(attributes['style']))
          ?.toLowerCase();
  switch (raw) {
    case 'center':
      return Alignment.topCenter;
    case 'right':
      return Alignment.topRight;
    case 'left':
      return Alignment.topLeft;
    default:
      return null;
  }
}

String? _readTextAlignFromStyle(String? style) {
  if (style == null || style.isEmpty) return null;
  final match = RegExp(
    r'text-align\s*:\s*([a-zA-Z]+)',
    caseSensitive: false,
  ).firstMatch(style);
  return match?.group(1);
}

TextStyle _headingStyle(int level, BuildContext context) {
  final theme = Theme.of(context);
  final t = theme.textTheme;
  final TextStyle base;
  switch (level) {
    case 1:
      base = t.displaySmall!;
    case 2:
      base = t.headlineMedium!;
    case 3:
      base = t.headlineSmall!;
    case 4:
      base = t.titleLarge!;
    case 5:
      base = t.titleMedium!;
    default:
      base = t.titleSmall!;
  }
  return base.copyWith(
    color: theme.colorScheme.onSurface,
    fontWeight: base.fontWeight ?? FontWeight.bold,
  );
}

Widget _withAlignment(Widget text, TextAlign? alignment) {
  if (alignment == null) return text;
  return SizedBox(width: double.infinity, child: text);
}

Widget _renderHeading(
  int level,
  List<InlineNode> children,
  TextAlign? alignment,
  BuildContext context,
  OnLinkTap? onLinkTap,
  List<TapGestureRecognizer>? recognizers,
) {
  final style = _headingStyle(level, context);
  return _withAlignment(
    Text.rich(
      TextSpan(
        style: style,
        children: [
          for (final c in children)
            _renderInline(c, context, style, onLinkTap, recognizers),
        ],
      ),
      textAlign: alignment,
    ),
    alignment,
  );
}

Widget _renderParagraph(
  List<InlineNode> children,
  TextAlign? alignment,
  BuildContext context,
  OnLinkTap? onLinkTap,
  List<TapGestureRecognizer>? recognizers,
) {
  final style = Theme.of(context).textTheme.bodyLarge!;
  return _withAlignment(
    Text.rich(
      TextSpan(
        style: style,
        children: [
          for (final c in children)
            _renderInline(c, context, style, onLinkTap, recognizers),
        ],
      ),
      textAlign: alignment,
    ),
    alignment,
  );
}

Widget _renderBlockquote(
  List<BlockNode> children,
  BuildContext context,
  OnLinkTap? onLinkTap,
  List<TapGestureRecognizer>? recognizers,
) {
  final theme = Theme.of(context);
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  final border = BorderSide(color: theme.colorScheme.outline, width: 3);
  return Container(
    padding: const EdgeInsetsDirectional.only(start: 12, top: 4, bottom: 4),
    decoration: BoxDecoration(
      border: Border(
        left: isRtl ? BorderSide.none : border,
        right: isRtl ? border : BorderSide.none,
      ),
    ),
    child: DefaultTextStyle.merge(
      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _renderBlock(children[i], context, onLinkTap, recognizers),
          ],
        ],
      ),
    ),
  );
}

Widget _renderList(
  List<ListItem> items,
  BuildContext context,
  OnLinkTap? onLinkTap,
  List<TapGestureRecognizer>? recognizers, {
  required bool ordered,
  required int startNumber,
}) {
  final bodyStyle = Theme.of(context).textTheme.bodyLarge;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < items.length; i++)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: ordered ? 28 : 16,
                child: Text(
                  ordered ? '${startNumber + i}.' : '•',
                  style: bodyStyle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var j = 0; j < items[i].children.length; j++) ...[
                      if (j > 0) const SizedBox(height: 4),
                      _renderBlock(
                        items[i].children[j],
                        context,
                        onLinkTap,
                        recognizers,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

Widget _renderCodeBlock(String code, BuildContext context) {
  final theme = Theme.of(context);
  return Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(6),
    ),
    padding: const EdgeInsets.all(10),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SelectableText(
        code,
        style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
      ),
    ),
  );
}

Widget _renderTable(
  List<MarkdownTableRow> rows,
  List<TextAlign?> alignments,
  BuildContext context,
  OnLinkTap? onLinkTap,
  List<TapGestureRecognizer>? recognizers,
) {
  final theme = Theme.of(context);
  final borderColor = theme.colorScheme.outline;
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder.all(color: borderColor),
      children: [
        for (var r = 0; r < rows.length; r++)
          TableRow(
            decoration: r == 0
                ? BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                  )
                : null,
            children: [
              for (var c = 0; c < rows[r].cells.length; c++)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        for (final child in rows[r].cells[c].children)
                          _renderInline(
                            child,
                            context,
                            r == 0
                                ? theme.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )
                                : theme.textTheme.bodyLarge!,
                            onLinkTap,
                            recognizers,
                          ),
                      ],
                    ),
                    textAlign: c < alignments.length ? alignments[c] : null,
                  ),
                ),
            ],
          ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Inline rendering
// ---------------------------------------------------------------------------

InlineSpan _renderInline(
  InlineNode node,
  BuildContext context,
  TextStyle baseStyle,
  OnLinkTap? onLinkTap,
  List<TapGestureRecognizer>? recognizers, {
  TapGestureRecognizer? linkRecognizer,
}) {
  switch (node) {
    case TextInline(:final value):
      return TextSpan(
        text: value,
        style: baseStyle,
        recognizer: linkRecognizer,
      );
    case BoldInline(:final children):
      return _wrapSpan(
        children,
        baseStyle.copyWith(fontWeight: FontWeight.bold),
        context,
        onLinkTap,
        recognizers,
        linkRecognizer: linkRecognizer,
      );
    case ItalicInline(:final children):
      return _wrapSpan(
        children,
        baseStyle.copyWith(fontStyle: FontStyle.italic),
        context,
        onLinkTap,
        recognizers,
        linkRecognizer: linkRecognizer,
      );
    case UnderlineInline(:final children):
      return _wrapSpan(
        children,
        baseStyle.copyWith(decoration: TextDecoration.underline),
        context,
        onLinkTap,
        recognizers,
        linkRecognizer: linkRecognizer,
      );
    case StrikethroughInline(:final children):
      return _wrapSpan(
        children,
        baseStyle.copyWith(decoration: TextDecoration.lineThrough),
        context,
        onLinkTap,
        recognizers,
        linkRecognizer: linkRecognizer,
      );
    case CodeInline(:final value):
      final t = Theme.of(context);
      return TextSpan(
        text: value,
        style: baseStyle.copyWith(
          fontFamily: 'monospace',
          backgroundColor: t.colorScheme.surfaceContainerHighest,
        ),
        recognizer: linkRecognizer,
      );
    case LineBreakInline():
      return const TextSpan(text: '\n');
    case LinkInline(:final url, :final children):
      final t = Theme.of(context);
      final linkStyle = baseStyle.copyWith(color: t.colorScheme.primary);
      final recognizer = TapGestureRecognizer()
        ..onTap = () => onLinkTap?.call(url);
      recognizers?.add(recognizer);
      return TextSpan(
        style: linkStyle,
        children: [
          for (final c in children)
            _renderInline(
              c,
              context,
              linkStyle,
              onLinkTap,
              recognizers,
              linkRecognizer: recognizer,
            ),
        ],
      );
    case ImageInline(:final src, :final alt):
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Image.network(
          src,
          errorBuilder: (context, error, stackTrace) =>
              Text(alt ?? '', style: baseStyle),
        ),
      );
    case HtmlPassthroughInline(:final children):
      return _wrapSpan(
        children,
        baseStyle,
        context,
        onLinkTap,
        recognizers,
        linkRecognizer: linkRecognizer,
      );
  }
}

InlineSpan _wrapSpan(
  List<InlineNode> children,
  TextStyle style,
  BuildContext context,
  OnLinkTap? onLinkTap,
  List<TapGestureRecognizer>? recognizers, {
  TapGestureRecognizer? linkRecognizer,
}) {
  return TextSpan(
    style: style,
    children: [
      for (final c in children)
        _renderInline(
          c,
          context,
          style,
          onLinkTap,
          recognizers,
          linkRecognizer: linkRecognizer,
        ),
    ],
  );
}
