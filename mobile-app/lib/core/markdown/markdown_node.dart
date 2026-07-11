import 'package:flutter/painting.dart' show TextAlign;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'markdown_node.freezed.dart';

@freezed
sealed class BlockNode with _$BlockNode {
  const factory BlockNode.heading({
    required int level,
    required List<InlineNode> children,
    TextAlign? alignment,
  }) = HeadingBlock;

  const factory BlockNode.paragraph({
    required List<InlineNode> children,
    TextAlign? alignment,
  }) = ParagraphBlock;

  const factory BlockNode.blockquote({
    required List<BlockNode> children,
  }) = BlockquoteBlock;

  const factory BlockNode.unorderedList({
    required List<ListItem> items,
  }) = UnorderedListBlock;

  const factory BlockNode.orderedList({
    required List<ListItem> items,
    @Default(1) int startNumber,
  }) = OrderedListBlock;

  const factory BlockNode.codeBlock({
    required String code,
    String? language,
  }) = CodeBlock;

  const factory BlockNode.horizontalRule() = HorizontalRuleBlock;

  const factory BlockNode.table({
    required List<MarkdownTableRow> rows,
    required List<TextAlign?> columnAlignments,
  }) = TableBlock;

  const factory BlockNode.htmlPassthrough({
    required String tag,
    required Map<String, String> attributes,
    required List<BlockNode> children,
  }) = HtmlPassthroughBlock;
}

@freezed
sealed class InlineNode with _$InlineNode {
  const factory InlineNode.text(String value) = TextInline;
  const factory InlineNode.bold(List<InlineNode> children) = BoldInline;
  const factory InlineNode.italic(List<InlineNode> children) = ItalicInline;
  const factory InlineNode.underline(List<InlineNode> children) = UnderlineInline;
  const factory InlineNode.strikethrough(List<InlineNode> children) = StrikethroughInline;
  const factory InlineNode.code(String value) = CodeInline;

  const factory InlineNode.link({
    required String url,
    required List<InlineNode> children,
  }) = LinkInline;

  const factory InlineNode.image({
    required String src,
    String? alt,
  }) = ImageInline;

  const factory InlineNode.lineBreak() = LineBreakInline;

  const factory InlineNode.htmlPassthrough({
    required String tag,
    required Map<String, String> attributes,
    required List<InlineNode> children,
  }) = HtmlPassthroughInline;
}

@freezed
abstract class ListItem with _$ListItem {
  const factory ListItem({
    required List<BlockNode> children,
  }) = _ListItem;
}

@freezed
abstract class MarkdownTableRow with _$MarkdownTableRow {
  const factory MarkdownTableRow({
    required List<TableCell> cells,
  }) = _MarkdownTableRow;
}

@freezed
abstract class TableCell with _$TableCell {
  const factory TableCell({
    required List<InlineNode> children,
  }) = _TableCell;
}
