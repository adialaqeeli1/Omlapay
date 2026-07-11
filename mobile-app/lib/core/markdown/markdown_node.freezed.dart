// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'markdown_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BlockNode {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockNode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BlockNode()';
}


}

/// @nodoc
class $BlockNodeCopyWith<$Res>  {
$BlockNodeCopyWith(BlockNode _, $Res Function(BlockNode) __);
}


/// Adds pattern-matching-related methods to [BlockNode].
extension BlockNodePatterns on BlockNode {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HeadingBlock value)?  heading,TResult Function( ParagraphBlock value)?  paragraph,TResult Function( BlockquoteBlock value)?  blockquote,TResult Function( UnorderedListBlock value)?  unorderedList,TResult Function( OrderedListBlock value)?  orderedList,TResult Function( CodeBlock value)?  codeBlock,TResult Function( HorizontalRuleBlock value)?  horizontalRule,TResult Function( TableBlock value)?  table,TResult Function( HtmlPassthroughBlock value)?  htmlPassthrough,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HeadingBlock() when heading != null:
return heading(_that);case ParagraphBlock() when paragraph != null:
return paragraph(_that);case BlockquoteBlock() when blockquote != null:
return blockquote(_that);case UnorderedListBlock() when unorderedList != null:
return unorderedList(_that);case OrderedListBlock() when orderedList != null:
return orderedList(_that);case CodeBlock() when codeBlock != null:
return codeBlock(_that);case HorizontalRuleBlock() when horizontalRule != null:
return horizontalRule(_that);case TableBlock() when table != null:
return table(_that);case HtmlPassthroughBlock() when htmlPassthrough != null:
return htmlPassthrough(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HeadingBlock value)  heading,required TResult Function( ParagraphBlock value)  paragraph,required TResult Function( BlockquoteBlock value)  blockquote,required TResult Function( UnorderedListBlock value)  unorderedList,required TResult Function( OrderedListBlock value)  orderedList,required TResult Function( CodeBlock value)  codeBlock,required TResult Function( HorizontalRuleBlock value)  horizontalRule,required TResult Function( TableBlock value)  table,required TResult Function( HtmlPassthroughBlock value)  htmlPassthrough,}){
final _that = this;
switch (_that) {
case HeadingBlock():
return heading(_that);case ParagraphBlock():
return paragraph(_that);case BlockquoteBlock():
return blockquote(_that);case UnorderedListBlock():
return unorderedList(_that);case OrderedListBlock():
return orderedList(_that);case CodeBlock():
return codeBlock(_that);case HorizontalRuleBlock():
return horizontalRule(_that);case TableBlock():
return table(_that);case HtmlPassthroughBlock():
return htmlPassthrough(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HeadingBlock value)?  heading,TResult? Function( ParagraphBlock value)?  paragraph,TResult? Function( BlockquoteBlock value)?  blockquote,TResult? Function( UnorderedListBlock value)?  unorderedList,TResult? Function( OrderedListBlock value)?  orderedList,TResult? Function( CodeBlock value)?  codeBlock,TResult? Function( HorizontalRuleBlock value)?  horizontalRule,TResult? Function( TableBlock value)?  table,TResult? Function( HtmlPassthroughBlock value)?  htmlPassthrough,}){
final _that = this;
switch (_that) {
case HeadingBlock() when heading != null:
return heading(_that);case ParagraphBlock() when paragraph != null:
return paragraph(_that);case BlockquoteBlock() when blockquote != null:
return blockquote(_that);case UnorderedListBlock() when unorderedList != null:
return unorderedList(_that);case OrderedListBlock() when orderedList != null:
return orderedList(_that);case CodeBlock() when codeBlock != null:
return codeBlock(_that);case HorizontalRuleBlock() when horizontalRule != null:
return horizontalRule(_that);case TableBlock() when table != null:
return table(_that);case HtmlPassthroughBlock() when htmlPassthrough != null:
return htmlPassthrough(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int level,  List<InlineNode> children,  TextAlign? alignment)?  heading,TResult Function( List<InlineNode> children,  TextAlign? alignment)?  paragraph,TResult Function( List<BlockNode> children)?  blockquote,TResult Function( List<ListItem> items)?  unorderedList,TResult Function( List<ListItem> items,  int startNumber)?  orderedList,TResult Function( String code,  String? language)?  codeBlock,TResult Function()?  horizontalRule,TResult Function( List<MarkdownTableRow> rows,  List<TextAlign?> columnAlignments)?  table,TResult Function( String tag,  Map<String, String> attributes,  List<BlockNode> children)?  htmlPassthrough,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HeadingBlock() when heading != null:
return heading(_that.level,_that.children,_that.alignment);case ParagraphBlock() when paragraph != null:
return paragraph(_that.children,_that.alignment);case BlockquoteBlock() when blockquote != null:
return blockquote(_that.children);case UnorderedListBlock() when unorderedList != null:
return unorderedList(_that.items);case OrderedListBlock() when orderedList != null:
return orderedList(_that.items,_that.startNumber);case CodeBlock() when codeBlock != null:
return codeBlock(_that.code,_that.language);case HorizontalRuleBlock() when horizontalRule != null:
return horizontalRule();case TableBlock() when table != null:
return table(_that.rows,_that.columnAlignments);case HtmlPassthroughBlock() when htmlPassthrough != null:
return htmlPassthrough(_that.tag,_that.attributes,_that.children);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int level,  List<InlineNode> children,  TextAlign? alignment)  heading,required TResult Function( List<InlineNode> children,  TextAlign? alignment)  paragraph,required TResult Function( List<BlockNode> children)  blockquote,required TResult Function( List<ListItem> items)  unorderedList,required TResult Function( List<ListItem> items,  int startNumber)  orderedList,required TResult Function( String code,  String? language)  codeBlock,required TResult Function()  horizontalRule,required TResult Function( List<MarkdownTableRow> rows,  List<TextAlign?> columnAlignments)  table,required TResult Function( String tag,  Map<String, String> attributes,  List<BlockNode> children)  htmlPassthrough,}) {final _that = this;
switch (_that) {
case HeadingBlock():
return heading(_that.level,_that.children,_that.alignment);case ParagraphBlock():
return paragraph(_that.children,_that.alignment);case BlockquoteBlock():
return blockquote(_that.children);case UnorderedListBlock():
return unorderedList(_that.items);case OrderedListBlock():
return orderedList(_that.items,_that.startNumber);case CodeBlock():
return codeBlock(_that.code,_that.language);case HorizontalRuleBlock():
return horizontalRule();case TableBlock():
return table(_that.rows,_that.columnAlignments);case HtmlPassthroughBlock():
return htmlPassthrough(_that.tag,_that.attributes,_that.children);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int level,  List<InlineNode> children,  TextAlign? alignment)?  heading,TResult? Function( List<InlineNode> children,  TextAlign? alignment)?  paragraph,TResult? Function( List<BlockNode> children)?  blockquote,TResult? Function( List<ListItem> items)?  unorderedList,TResult? Function( List<ListItem> items,  int startNumber)?  orderedList,TResult? Function( String code,  String? language)?  codeBlock,TResult? Function()?  horizontalRule,TResult? Function( List<MarkdownTableRow> rows,  List<TextAlign?> columnAlignments)?  table,TResult? Function( String tag,  Map<String, String> attributes,  List<BlockNode> children)?  htmlPassthrough,}) {final _that = this;
switch (_that) {
case HeadingBlock() when heading != null:
return heading(_that.level,_that.children,_that.alignment);case ParagraphBlock() when paragraph != null:
return paragraph(_that.children,_that.alignment);case BlockquoteBlock() when blockquote != null:
return blockquote(_that.children);case UnorderedListBlock() when unorderedList != null:
return unorderedList(_that.items);case OrderedListBlock() when orderedList != null:
return orderedList(_that.items,_that.startNumber);case CodeBlock() when codeBlock != null:
return codeBlock(_that.code,_that.language);case HorizontalRuleBlock() when horizontalRule != null:
return horizontalRule();case TableBlock() when table != null:
return table(_that.rows,_that.columnAlignments);case HtmlPassthroughBlock() when htmlPassthrough != null:
return htmlPassthrough(_that.tag,_that.attributes,_that.children);case _:
  return null;

}
}

}

/// @nodoc


class HeadingBlock implements BlockNode {
  const HeadingBlock({required this.level, required final  List<InlineNode> children, this.alignment}): _children = children;
  

 final  int level;
 final  List<InlineNode> _children;
 List<InlineNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

 final  TextAlign? alignment;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeadingBlockCopyWith<HeadingBlock> get copyWith => _$HeadingBlockCopyWithImpl<HeadingBlock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HeadingBlock&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.alignment, alignment) || other.alignment == alignment));
}


@override
int get hashCode => Object.hash(runtimeType,level,const DeepCollectionEquality().hash(_children),alignment);

@override
String toString() {
  return 'BlockNode.heading(level: $level, children: $children, alignment: $alignment)';
}


}

/// @nodoc
abstract mixin class $HeadingBlockCopyWith<$Res> implements $BlockNodeCopyWith<$Res> {
  factory $HeadingBlockCopyWith(HeadingBlock value, $Res Function(HeadingBlock) _then) = _$HeadingBlockCopyWithImpl;
@useResult
$Res call({
 int level, List<InlineNode> children, TextAlign? alignment
});




}
/// @nodoc
class _$HeadingBlockCopyWithImpl<$Res>
    implements $HeadingBlockCopyWith<$Res> {
  _$HeadingBlockCopyWithImpl(this._self, this._then);

  final HeadingBlock _self;
  final $Res Function(HeadingBlock) _then;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? level = null,Object? children = null,Object? alignment = freezed,}) {
  return _then(HeadingBlock(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<InlineNode>,alignment: freezed == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as TextAlign?,
  ));
}


}

/// @nodoc


class ParagraphBlock implements BlockNode {
  const ParagraphBlock({required final  List<InlineNode> children, this.alignment}): _children = children;
  

 final  List<InlineNode> _children;
 List<InlineNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

 final  TextAlign? alignment;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParagraphBlockCopyWith<ParagraphBlock> get copyWith => _$ParagraphBlockCopyWithImpl<ParagraphBlock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParagraphBlock&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.alignment, alignment) || other.alignment == alignment));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_children),alignment);

@override
String toString() {
  return 'BlockNode.paragraph(children: $children, alignment: $alignment)';
}


}

/// @nodoc
abstract mixin class $ParagraphBlockCopyWith<$Res> implements $BlockNodeCopyWith<$Res> {
  factory $ParagraphBlockCopyWith(ParagraphBlock value, $Res Function(ParagraphBlock) _then) = _$ParagraphBlockCopyWithImpl;
@useResult
$Res call({
 List<InlineNode> children, TextAlign? alignment
});




}
/// @nodoc
class _$ParagraphBlockCopyWithImpl<$Res>
    implements $ParagraphBlockCopyWith<$Res> {
  _$ParagraphBlockCopyWithImpl(this._self, this._then);

  final ParagraphBlock _self;
  final $Res Function(ParagraphBlock) _then;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? children = null,Object? alignment = freezed,}) {
  return _then(ParagraphBlock(
children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<InlineNode>,alignment: freezed == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as TextAlign?,
  ));
}


}

/// @nodoc


class BlockquoteBlock implements BlockNode {
  const BlockquoteBlock({required final  List<BlockNode> children}): _children = children;
  

 final  List<BlockNode> _children;
 List<BlockNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockquoteBlockCopyWith<BlockquoteBlock> get copyWith => _$BlockquoteBlockCopyWithImpl<BlockquoteBlock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockquoteBlock&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'BlockNode.blockquote(children: $children)';
}


}

/// @nodoc
abstract mixin class $BlockquoteBlockCopyWith<$Res> implements $BlockNodeCopyWith<$Res> {
  factory $BlockquoteBlockCopyWith(BlockquoteBlock value, $Res Function(BlockquoteBlock) _then) = _$BlockquoteBlockCopyWithImpl;
@useResult
$Res call({
 List<BlockNode> children
});




}
/// @nodoc
class _$BlockquoteBlockCopyWithImpl<$Res>
    implements $BlockquoteBlockCopyWith<$Res> {
  _$BlockquoteBlockCopyWithImpl(this._self, this._then);

  final BlockquoteBlock _self;
  final $Res Function(BlockquoteBlock) _then;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? children = null,}) {
  return _then(BlockquoteBlock(
children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<BlockNode>,
  ));
}


}

/// @nodoc


class UnorderedListBlock implements BlockNode {
  const UnorderedListBlock({required final  List<ListItem> items}): _items = items;
  

 final  List<ListItem> _items;
 List<ListItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnorderedListBlockCopyWith<UnorderedListBlock> get copyWith => _$UnorderedListBlockCopyWithImpl<UnorderedListBlock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnorderedListBlock&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'BlockNode.unorderedList(items: $items)';
}


}

/// @nodoc
abstract mixin class $UnorderedListBlockCopyWith<$Res> implements $BlockNodeCopyWith<$Res> {
  factory $UnorderedListBlockCopyWith(UnorderedListBlock value, $Res Function(UnorderedListBlock) _then) = _$UnorderedListBlockCopyWithImpl;
@useResult
$Res call({
 List<ListItem> items
});




}
/// @nodoc
class _$UnorderedListBlockCopyWithImpl<$Res>
    implements $UnorderedListBlockCopyWith<$Res> {
  _$UnorderedListBlockCopyWithImpl(this._self, this._then);

  final UnorderedListBlock _self;
  final $Res Function(UnorderedListBlock) _then;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(UnorderedListBlock(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ListItem>,
  ));
}


}

/// @nodoc


class OrderedListBlock implements BlockNode {
  const OrderedListBlock({required final  List<ListItem> items, this.startNumber = 1}): _items = items;
  

 final  List<ListItem> _items;
 List<ListItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@JsonKey() final  int startNumber;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderedListBlockCopyWith<OrderedListBlock> get copyWith => _$OrderedListBlockCopyWithImpl<OrderedListBlock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderedListBlock&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.startNumber, startNumber) || other.startNumber == startNumber));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),startNumber);

@override
String toString() {
  return 'BlockNode.orderedList(items: $items, startNumber: $startNumber)';
}


}

/// @nodoc
abstract mixin class $OrderedListBlockCopyWith<$Res> implements $BlockNodeCopyWith<$Res> {
  factory $OrderedListBlockCopyWith(OrderedListBlock value, $Res Function(OrderedListBlock) _then) = _$OrderedListBlockCopyWithImpl;
@useResult
$Res call({
 List<ListItem> items, int startNumber
});




}
/// @nodoc
class _$OrderedListBlockCopyWithImpl<$Res>
    implements $OrderedListBlockCopyWith<$Res> {
  _$OrderedListBlockCopyWithImpl(this._self, this._then);

  final OrderedListBlock _self;
  final $Res Function(OrderedListBlock) _then;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? startNumber = null,}) {
  return _then(OrderedListBlock(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ListItem>,startNumber: null == startNumber ? _self.startNumber : startNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class CodeBlock implements BlockNode {
  const CodeBlock({required this.code, this.language});
  

 final  String code;
 final  String? language;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodeBlockCopyWith<CodeBlock> get copyWith => _$CodeBlockCopyWithImpl<CodeBlock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodeBlock&&(identical(other.code, code) || other.code == code)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode => Object.hash(runtimeType,code,language);

@override
String toString() {
  return 'BlockNode.codeBlock(code: $code, language: $language)';
}


}

/// @nodoc
abstract mixin class $CodeBlockCopyWith<$Res> implements $BlockNodeCopyWith<$Res> {
  factory $CodeBlockCopyWith(CodeBlock value, $Res Function(CodeBlock) _then) = _$CodeBlockCopyWithImpl;
@useResult
$Res call({
 String code, String? language
});




}
/// @nodoc
class _$CodeBlockCopyWithImpl<$Res>
    implements $CodeBlockCopyWith<$Res> {
  _$CodeBlockCopyWithImpl(this._self, this._then);

  final CodeBlock _self;
  final $Res Function(CodeBlock) _then;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,Object? language = freezed,}) {
  return _then(CodeBlock(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class HorizontalRuleBlock implements BlockNode {
  const HorizontalRuleBlock();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HorizontalRuleBlock);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BlockNode.horizontalRule()';
}


}




/// @nodoc


class TableBlock implements BlockNode {
  const TableBlock({required final  List<MarkdownTableRow> rows, required final  List<TextAlign?> columnAlignments}): _rows = rows,_columnAlignments = columnAlignments;
  

 final  List<MarkdownTableRow> _rows;
 List<MarkdownTableRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

 final  List<TextAlign?> _columnAlignments;
 List<TextAlign?> get columnAlignments {
  if (_columnAlignments is EqualUnmodifiableListView) return _columnAlignments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_columnAlignments);
}


/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TableBlockCopyWith<TableBlock> get copyWith => _$TableBlockCopyWithImpl<TableBlock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TableBlock&&const DeepCollectionEquality().equals(other._rows, _rows)&&const DeepCollectionEquality().equals(other._columnAlignments, _columnAlignments));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rows),const DeepCollectionEquality().hash(_columnAlignments));

@override
String toString() {
  return 'BlockNode.table(rows: $rows, columnAlignments: $columnAlignments)';
}


}

/// @nodoc
abstract mixin class $TableBlockCopyWith<$Res> implements $BlockNodeCopyWith<$Res> {
  factory $TableBlockCopyWith(TableBlock value, $Res Function(TableBlock) _then) = _$TableBlockCopyWithImpl;
@useResult
$Res call({
 List<MarkdownTableRow> rows, List<TextAlign?> columnAlignments
});




}
/// @nodoc
class _$TableBlockCopyWithImpl<$Res>
    implements $TableBlockCopyWith<$Res> {
  _$TableBlockCopyWithImpl(this._self, this._then);

  final TableBlock _self;
  final $Res Function(TableBlock) _then;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rows = null,Object? columnAlignments = null,}) {
  return _then(TableBlock(
rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<MarkdownTableRow>,columnAlignments: null == columnAlignments ? _self._columnAlignments : columnAlignments // ignore: cast_nullable_to_non_nullable
as List<TextAlign?>,
  ));
}


}

/// @nodoc


class HtmlPassthroughBlock implements BlockNode {
  const HtmlPassthroughBlock({required this.tag, required final  Map<String, String> attributes, required final  List<BlockNode> children}): _attributes = attributes,_children = children;
  

 final  String tag;
 final  Map<String, String> _attributes;
 Map<String, String> get attributes {
  if (_attributes is EqualUnmodifiableMapView) return _attributes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_attributes);
}

 final  List<BlockNode> _children;
 List<BlockNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HtmlPassthroughBlockCopyWith<HtmlPassthroughBlock> get copyWith => _$HtmlPassthroughBlockCopyWithImpl<HtmlPassthroughBlock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HtmlPassthroughBlock&&(identical(other.tag, tag) || other.tag == tag)&&const DeepCollectionEquality().equals(other._attributes, _attributes)&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,tag,const DeepCollectionEquality().hash(_attributes),const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'BlockNode.htmlPassthrough(tag: $tag, attributes: $attributes, children: $children)';
}


}

/// @nodoc
abstract mixin class $HtmlPassthroughBlockCopyWith<$Res> implements $BlockNodeCopyWith<$Res> {
  factory $HtmlPassthroughBlockCopyWith(HtmlPassthroughBlock value, $Res Function(HtmlPassthroughBlock) _then) = _$HtmlPassthroughBlockCopyWithImpl;
@useResult
$Res call({
 String tag, Map<String, String> attributes, List<BlockNode> children
});




}
/// @nodoc
class _$HtmlPassthroughBlockCopyWithImpl<$Res>
    implements $HtmlPassthroughBlockCopyWith<$Res> {
  _$HtmlPassthroughBlockCopyWithImpl(this._self, this._then);

  final HtmlPassthroughBlock _self;
  final $Res Function(HtmlPassthroughBlock) _then;

/// Create a copy of BlockNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tag = null,Object? attributes = null,Object? children = null,}) {
  return _then(HtmlPassthroughBlock(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,attributes: null == attributes ? _self._attributes : attributes // ignore: cast_nullable_to_non_nullable
as Map<String, String>,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<BlockNode>,
  ));
}


}

/// @nodoc
mixin _$InlineNode {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InlineNode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'InlineNode()';
}


}

/// @nodoc
class $InlineNodeCopyWith<$Res>  {
$InlineNodeCopyWith(InlineNode _, $Res Function(InlineNode) __);
}


/// Adds pattern-matching-related methods to [InlineNode].
extension InlineNodePatterns on InlineNode {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TextInline value)?  text,TResult Function( BoldInline value)?  bold,TResult Function( ItalicInline value)?  italic,TResult Function( UnderlineInline value)?  underline,TResult Function( StrikethroughInline value)?  strikethrough,TResult Function( CodeInline value)?  code,TResult Function( LinkInline value)?  link,TResult Function( ImageInline value)?  image,TResult Function( LineBreakInline value)?  lineBreak,TResult Function( HtmlPassthroughInline value)?  htmlPassthrough,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TextInline() when text != null:
return text(_that);case BoldInline() when bold != null:
return bold(_that);case ItalicInline() when italic != null:
return italic(_that);case UnderlineInline() when underline != null:
return underline(_that);case StrikethroughInline() when strikethrough != null:
return strikethrough(_that);case CodeInline() when code != null:
return code(_that);case LinkInline() when link != null:
return link(_that);case ImageInline() when image != null:
return image(_that);case LineBreakInline() when lineBreak != null:
return lineBreak(_that);case HtmlPassthroughInline() when htmlPassthrough != null:
return htmlPassthrough(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TextInline value)  text,required TResult Function( BoldInline value)  bold,required TResult Function( ItalicInline value)  italic,required TResult Function( UnderlineInline value)  underline,required TResult Function( StrikethroughInline value)  strikethrough,required TResult Function( CodeInline value)  code,required TResult Function( LinkInline value)  link,required TResult Function( ImageInline value)  image,required TResult Function( LineBreakInline value)  lineBreak,required TResult Function( HtmlPassthroughInline value)  htmlPassthrough,}){
final _that = this;
switch (_that) {
case TextInline():
return text(_that);case BoldInline():
return bold(_that);case ItalicInline():
return italic(_that);case UnderlineInline():
return underline(_that);case StrikethroughInline():
return strikethrough(_that);case CodeInline():
return code(_that);case LinkInline():
return link(_that);case ImageInline():
return image(_that);case LineBreakInline():
return lineBreak(_that);case HtmlPassthroughInline():
return htmlPassthrough(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TextInline value)?  text,TResult? Function( BoldInline value)?  bold,TResult? Function( ItalicInline value)?  italic,TResult? Function( UnderlineInline value)?  underline,TResult? Function( StrikethroughInline value)?  strikethrough,TResult? Function( CodeInline value)?  code,TResult? Function( LinkInline value)?  link,TResult? Function( ImageInline value)?  image,TResult? Function( LineBreakInline value)?  lineBreak,TResult? Function( HtmlPassthroughInline value)?  htmlPassthrough,}){
final _that = this;
switch (_that) {
case TextInline() when text != null:
return text(_that);case BoldInline() when bold != null:
return bold(_that);case ItalicInline() when italic != null:
return italic(_that);case UnderlineInline() when underline != null:
return underline(_that);case StrikethroughInline() when strikethrough != null:
return strikethrough(_that);case CodeInline() when code != null:
return code(_that);case LinkInline() when link != null:
return link(_that);case ImageInline() when image != null:
return image(_that);case LineBreakInline() when lineBreak != null:
return lineBreak(_that);case HtmlPassthroughInline() when htmlPassthrough != null:
return htmlPassthrough(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String value)?  text,TResult Function( List<InlineNode> children)?  bold,TResult Function( List<InlineNode> children)?  italic,TResult Function( List<InlineNode> children)?  underline,TResult Function( List<InlineNode> children)?  strikethrough,TResult Function( String value)?  code,TResult Function( String url,  List<InlineNode> children)?  link,TResult Function( String src,  String? alt)?  image,TResult Function()?  lineBreak,TResult Function( String tag,  Map<String, String> attributes,  List<InlineNode> children)?  htmlPassthrough,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TextInline() when text != null:
return text(_that.value);case BoldInline() when bold != null:
return bold(_that.children);case ItalicInline() when italic != null:
return italic(_that.children);case UnderlineInline() when underline != null:
return underline(_that.children);case StrikethroughInline() when strikethrough != null:
return strikethrough(_that.children);case CodeInline() when code != null:
return code(_that.value);case LinkInline() when link != null:
return link(_that.url,_that.children);case ImageInline() when image != null:
return image(_that.src,_that.alt);case LineBreakInline() when lineBreak != null:
return lineBreak();case HtmlPassthroughInline() when htmlPassthrough != null:
return htmlPassthrough(_that.tag,_that.attributes,_that.children);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String value)  text,required TResult Function( List<InlineNode> children)  bold,required TResult Function( List<InlineNode> children)  italic,required TResult Function( List<InlineNode> children)  underline,required TResult Function( List<InlineNode> children)  strikethrough,required TResult Function( String value)  code,required TResult Function( String url,  List<InlineNode> children)  link,required TResult Function( String src,  String? alt)  image,required TResult Function()  lineBreak,required TResult Function( String tag,  Map<String, String> attributes,  List<InlineNode> children)  htmlPassthrough,}) {final _that = this;
switch (_that) {
case TextInline():
return text(_that.value);case BoldInline():
return bold(_that.children);case ItalicInline():
return italic(_that.children);case UnderlineInline():
return underline(_that.children);case StrikethroughInline():
return strikethrough(_that.children);case CodeInline():
return code(_that.value);case LinkInline():
return link(_that.url,_that.children);case ImageInline():
return image(_that.src,_that.alt);case LineBreakInline():
return lineBreak();case HtmlPassthroughInline():
return htmlPassthrough(_that.tag,_that.attributes,_that.children);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String value)?  text,TResult? Function( List<InlineNode> children)?  bold,TResult? Function( List<InlineNode> children)?  italic,TResult? Function( List<InlineNode> children)?  underline,TResult? Function( List<InlineNode> children)?  strikethrough,TResult? Function( String value)?  code,TResult? Function( String url,  List<InlineNode> children)?  link,TResult? Function( String src,  String? alt)?  image,TResult? Function()?  lineBreak,TResult? Function( String tag,  Map<String, String> attributes,  List<InlineNode> children)?  htmlPassthrough,}) {final _that = this;
switch (_that) {
case TextInline() when text != null:
return text(_that.value);case BoldInline() when bold != null:
return bold(_that.children);case ItalicInline() when italic != null:
return italic(_that.children);case UnderlineInline() when underline != null:
return underline(_that.children);case StrikethroughInline() when strikethrough != null:
return strikethrough(_that.children);case CodeInline() when code != null:
return code(_that.value);case LinkInline() when link != null:
return link(_that.url,_that.children);case ImageInline() when image != null:
return image(_that.src,_that.alt);case LineBreakInline() when lineBreak != null:
return lineBreak();case HtmlPassthroughInline() when htmlPassthrough != null:
return htmlPassthrough(_that.tag,_that.attributes,_that.children);case _:
  return null;

}
}

}

/// @nodoc


class TextInline implements InlineNode {
  const TextInline(this.value);
  

 final  String value;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextInlineCopyWith<TextInline> get copyWith => _$TextInlineCopyWithImpl<TextInline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextInline&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'InlineNode.text(value: $value)';
}


}

/// @nodoc
abstract mixin class $TextInlineCopyWith<$Res> implements $InlineNodeCopyWith<$Res> {
  factory $TextInlineCopyWith(TextInline value, $Res Function(TextInline) _then) = _$TextInlineCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$TextInlineCopyWithImpl<$Res>
    implements $TextInlineCopyWith<$Res> {
  _$TextInlineCopyWithImpl(this._self, this._then);

  final TextInline _self;
  final $Res Function(TextInline) _then;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(TextInline(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BoldInline implements InlineNode {
  const BoldInline(final  List<InlineNode> children): _children = children;
  

 final  List<InlineNode> _children;
 List<InlineNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoldInlineCopyWith<BoldInline> get copyWith => _$BoldInlineCopyWithImpl<BoldInline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoldInline&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'InlineNode.bold(children: $children)';
}


}

/// @nodoc
abstract mixin class $BoldInlineCopyWith<$Res> implements $InlineNodeCopyWith<$Res> {
  factory $BoldInlineCopyWith(BoldInline value, $Res Function(BoldInline) _then) = _$BoldInlineCopyWithImpl;
@useResult
$Res call({
 List<InlineNode> children
});




}
/// @nodoc
class _$BoldInlineCopyWithImpl<$Res>
    implements $BoldInlineCopyWith<$Res> {
  _$BoldInlineCopyWithImpl(this._self, this._then);

  final BoldInline _self;
  final $Res Function(BoldInline) _then;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? children = null,}) {
  return _then(BoldInline(
null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<InlineNode>,
  ));
}


}

/// @nodoc


class ItalicInline implements InlineNode {
  const ItalicInline(final  List<InlineNode> children): _children = children;
  

 final  List<InlineNode> _children;
 List<InlineNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItalicInlineCopyWith<ItalicInline> get copyWith => _$ItalicInlineCopyWithImpl<ItalicInline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItalicInline&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'InlineNode.italic(children: $children)';
}


}

/// @nodoc
abstract mixin class $ItalicInlineCopyWith<$Res> implements $InlineNodeCopyWith<$Res> {
  factory $ItalicInlineCopyWith(ItalicInline value, $Res Function(ItalicInline) _then) = _$ItalicInlineCopyWithImpl;
@useResult
$Res call({
 List<InlineNode> children
});




}
/// @nodoc
class _$ItalicInlineCopyWithImpl<$Res>
    implements $ItalicInlineCopyWith<$Res> {
  _$ItalicInlineCopyWithImpl(this._self, this._then);

  final ItalicInline _self;
  final $Res Function(ItalicInline) _then;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? children = null,}) {
  return _then(ItalicInline(
null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<InlineNode>,
  ));
}


}

/// @nodoc


class UnderlineInline implements InlineNode {
  const UnderlineInline(final  List<InlineNode> children): _children = children;
  

 final  List<InlineNode> _children;
 List<InlineNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnderlineInlineCopyWith<UnderlineInline> get copyWith => _$UnderlineInlineCopyWithImpl<UnderlineInline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnderlineInline&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'InlineNode.underline(children: $children)';
}


}

/// @nodoc
abstract mixin class $UnderlineInlineCopyWith<$Res> implements $InlineNodeCopyWith<$Res> {
  factory $UnderlineInlineCopyWith(UnderlineInline value, $Res Function(UnderlineInline) _then) = _$UnderlineInlineCopyWithImpl;
@useResult
$Res call({
 List<InlineNode> children
});




}
/// @nodoc
class _$UnderlineInlineCopyWithImpl<$Res>
    implements $UnderlineInlineCopyWith<$Res> {
  _$UnderlineInlineCopyWithImpl(this._self, this._then);

  final UnderlineInline _self;
  final $Res Function(UnderlineInline) _then;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? children = null,}) {
  return _then(UnderlineInline(
null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<InlineNode>,
  ));
}


}

/// @nodoc


class StrikethroughInline implements InlineNode {
  const StrikethroughInline(final  List<InlineNode> children): _children = children;
  

 final  List<InlineNode> _children;
 List<InlineNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StrikethroughInlineCopyWith<StrikethroughInline> get copyWith => _$StrikethroughInlineCopyWithImpl<StrikethroughInline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StrikethroughInline&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'InlineNode.strikethrough(children: $children)';
}


}

/// @nodoc
abstract mixin class $StrikethroughInlineCopyWith<$Res> implements $InlineNodeCopyWith<$Res> {
  factory $StrikethroughInlineCopyWith(StrikethroughInline value, $Res Function(StrikethroughInline) _then) = _$StrikethroughInlineCopyWithImpl;
@useResult
$Res call({
 List<InlineNode> children
});




}
/// @nodoc
class _$StrikethroughInlineCopyWithImpl<$Res>
    implements $StrikethroughInlineCopyWith<$Res> {
  _$StrikethroughInlineCopyWithImpl(this._self, this._then);

  final StrikethroughInline _self;
  final $Res Function(StrikethroughInline) _then;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? children = null,}) {
  return _then(StrikethroughInline(
null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<InlineNode>,
  ));
}


}

/// @nodoc


class CodeInline implements InlineNode {
  const CodeInline(this.value);
  

 final  String value;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodeInlineCopyWith<CodeInline> get copyWith => _$CodeInlineCopyWithImpl<CodeInline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodeInline&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'InlineNode.code(value: $value)';
}


}

/// @nodoc
abstract mixin class $CodeInlineCopyWith<$Res> implements $InlineNodeCopyWith<$Res> {
  factory $CodeInlineCopyWith(CodeInline value, $Res Function(CodeInline) _then) = _$CodeInlineCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$CodeInlineCopyWithImpl<$Res>
    implements $CodeInlineCopyWith<$Res> {
  _$CodeInlineCopyWithImpl(this._self, this._then);

  final CodeInline _self;
  final $Res Function(CodeInline) _then;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(CodeInline(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LinkInline implements InlineNode {
  const LinkInline({required this.url, required final  List<InlineNode> children}): _children = children;
  

 final  String url;
 final  List<InlineNode> _children;
 List<InlineNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkInlineCopyWith<LinkInline> get copyWith => _$LinkInlineCopyWithImpl<LinkInline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkInline&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,url,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'InlineNode.link(url: $url, children: $children)';
}


}

/// @nodoc
abstract mixin class $LinkInlineCopyWith<$Res> implements $InlineNodeCopyWith<$Res> {
  factory $LinkInlineCopyWith(LinkInline value, $Res Function(LinkInline) _then) = _$LinkInlineCopyWithImpl;
@useResult
$Res call({
 String url, List<InlineNode> children
});




}
/// @nodoc
class _$LinkInlineCopyWithImpl<$Res>
    implements $LinkInlineCopyWith<$Res> {
  _$LinkInlineCopyWithImpl(this._self, this._then);

  final LinkInline _self;
  final $Res Function(LinkInline) _then;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? url = null,Object? children = null,}) {
  return _then(LinkInline(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<InlineNode>,
  ));
}


}

/// @nodoc


class ImageInline implements InlineNode {
  const ImageInline({required this.src, this.alt});
  

 final  String src;
 final  String? alt;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageInlineCopyWith<ImageInline> get copyWith => _$ImageInlineCopyWithImpl<ImageInline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageInline&&(identical(other.src, src) || other.src == src)&&(identical(other.alt, alt) || other.alt == alt));
}


@override
int get hashCode => Object.hash(runtimeType,src,alt);

@override
String toString() {
  return 'InlineNode.image(src: $src, alt: $alt)';
}


}

/// @nodoc
abstract mixin class $ImageInlineCopyWith<$Res> implements $InlineNodeCopyWith<$Res> {
  factory $ImageInlineCopyWith(ImageInline value, $Res Function(ImageInline) _then) = _$ImageInlineCopyWithImpl;
@useResult
$Res call({
 String src, String? alt
});




}
/// @nodoc
class _$ImageInlineCopyWithImpl<$Res>
    implements $ImageInlineCopyWith<$Res> {
  _$ImageInlineCopyWithImpl(this._self, this._then);

  final ImageInline _self;
  final $Res Function(ImageInline) _then;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? src = null,Object? alt = freezed,}) {
  return _then(ImageInline(
src: null == src ? _self.src : src // ignore: cast_nullable_to_non_nullable
as String,alt: freezed == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class LineBreakInline implements InlineNode {
  const LineBreakInline();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineBreakInline);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'InlineNode.lineBreak()';
}


}




/// @nodoc


class HtmlPassthroughInline implements InlineNode {
  const HtmlPassthroughInline({required this.tag, required final  Map<String, String> attributes, required final  List<InlineNode> children}): _attributes = attributes,_children = children;
  

 final  String tag;
 final  Map<String, String> _attributes;
 Map<String, String> get attributes {
  if (_attributes is EqualUnmodifiableMapView) return _attributes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_attributes);
}

 final  List<InlineNode> _children;
 List<InlineNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HtmlPassthroughInlineCopyWith<HtmlPassthroughInline> get copyWith => _$HtmlPassthroughInlineCopyWithImpl<HtmlPassthroughInline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HtmlPassthroughInline&&(identical(other.tag, tag) || other.tag == tag)&&const DeepCollectionEquality().equals(other._attributes, _attributes)&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,tag,const DeepCollectionEquality().hash(_attributes),const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'InlineNode.htmlPassthrough(tag: $tag, attributes: $attributes, children: $children)';
}


}

/// @nodoc
abstract mixin class $HtmlPassthroughInlineCopyWith<$Res> implements $InlineNodeCopyWith<$Res> {
  factory $HtmlPassthroughInlineCopyWith(HtmlPassthroughInline value, $Res Function(HtmlPassthroughInline) _then) = _$HtmlPassthroughInlineCopyWithImpl;
@useResult
$Res call({
 String tag, Map<String, String> attributes, List<InlineNode> children
});




}
/// @nodoc
class _$HtmlPassthroughInlineCopyWithImpl<$Res>
    implements $HtmlPassthroughInlineCopyWith<$Res> {
  _$HtmlPassthroughInlineCopyWithImpl(this._self, this._then);

  final HtmlPassthroughInline _self;
  final $Res Function(HtmlPassthroughInline) _then;

/// Create a copy of InlineNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tag = null,Object? attributes = null,Object? children = null,}) {
  return _then(HtmlPassthroughInline(
tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,attributes: null == attributes ? _self._attributes : attributes // ignore: cast_nullable_to_non_nullable
as Map<String, String>,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<InlineNode>,
  ));
}


}

/// @nodoc
mixin _$ListItem {

 List<BlockNode> get children;
/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListItemCopyWith<ListItem> get copyWith => _$ListItemCopyWithImpl<ListItem>(this as ListItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListItem&&const DeepCollectionEquality().equals(other.children, children));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'ListItem(children: $children)';
}


}

/// @nodoc
abstract mixin class $ListItemCopyWith<$Res>  {
  factory $ListItemCopyWith(ListItem value, $Res Function(ListItem) _then) = _$ListItemCopyWithImpl;
@useResult
$Res call({
 List<BlockNode> children
});




}
/// @nodoc
class _$ListItemCopyWithImpl<$Res>
    implements $ListItemCopyWith<$Res> {
  _$ListItemCopyWithImpl(this._self, this._then);

  final ListItem _self;
  final $Res Function(ListItem) _then;

/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? children = null,}) {
  return _then(_self.copyWith(
children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<BlockNode>,
  ));
}

}


/// Adds pattern-matching-related methods to [ListItem].
extension ListItemPatterns on ListItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListItem value)  $default,){
final _that = this;
switch (_that) {
case _ListItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListItem value)?  $default,){
final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BlockNode> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that.children);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BlockNode> children)  $default,) {final _that = this;
switch (_that) {
case _ListItem():
return $default(_that.children);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BlockNode> children)?  $default,) {final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that.children);case _:
  return null;

}
}

}

/// @nodoc


class _ListItem implements ListItem {
  const _ListItem({required final  List<BlockNode> children}): _children = children;
  

 final  List<BlockNode> _children;
@override List<BlockNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListItemCopyWith<_ListItem> get copyWith => __$ListItemCopyWithImpl<_ListItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListItem&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'ListItem(children: $children)';
}


}

/// @nodoc
abstract mixin class _$ListItemCopyWith<$Res> implements $ListItemCopyWith<$Res> {
  factory _$ListItemCopyWith(_ListItem value, $Res Function(_ListItem) _then) = __$ListItemCopyWithImpl;
@override @useResult
$Res call({
 List<BlockNode> children
});




}
/// @nodoc
class __$ListItemCopyWithImpl<$Res>
    implements _$ListItemCopyWith<$Res> {
  __$ListItemCopyWithImpl(this._self, this._then);

  final _ListItem _self;
  final $Res Function(_ListItem) _then;

/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? children = null,}) {
  return _then(_ListItem(
children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<BlockNode>,
  ));
}


}

/// @nodoc
mixin _$MarkdownTableRow {

 List<TableCell> get cells;
/// Create a copy of MarkdownTableRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkdownTableRowCopyWith<MarkdownTableRow> get copyWith => _$MarkdownTableRowCopyWithImpl<MarkdownTableRow>(this as MarkdownTableRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkdownTableRow&&const DeepCollectionEquality().equals(other.cells, cells));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(cells));

@override
String toString() {
  return 'MarkdownTableRow(cells: $cells)';
}


}

/// @nodoc
abstract mixin class $MarkdownTableRowCopyWith<$Res>  {
  factory $MarkdownTableRowCopyWith(MarkdownTableRow value, $Res Function(MarkdownTableRow) _then) = _$MarkdownTableRowCopyWithImpl;
@useResult
$Res call({
 List<TableCell> cells
});




}
/// @nodoc
class _$MarkdownTableRowCopyWithImpl<$Res>
    implements $MarkdownTableRowCopyWith<$Res> {
  _$MarkdownTableRowCopyWithImpl(this._self, this._then);

  final MarkdownTableRow _self;
  final $Res Function(MarkdownTableRow) _then;

/// Create a copy of MarkdownTableRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cells = null,}) {
  return _then(_self.copyWith(
cells: null == cells ? _self.cells : cells // ignore: cast_nullable_to_non_nullable
as List<TableCell>,
  ));
}

}


/// Adds pattern-matching-related methods to [MarkdownTableRow].
extension MarkdownTableRowPatterns on MarkdownTableRow {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarkdownTableRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarkdownTableRow() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarkdownTableRow value)  $default,){
final _that = this;
switch (_that) {
case _MarkdownTableRow():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarkdownTableRow value)?  $default,){
final _that = this;
switch (_that) {
case _MarkdownTableRow() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TableCell> cells)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarkdownTableRow() when $default != null:
return $default(_that.cells);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TableCell> cells)  $default,) {final _that = this;
switch (_that) {
case _MarkdownTableRow():
return $default(_that.cells);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TableCell> cells)?  $default,) {final _that = this;
switch (_that) {
case _MarkdownTableRow() when $default != null:
return $default(_that.cells);case _:
  return null;

}
}

}

/// @nodoc


class _MarkdownTableRow implements MarkdownTableRow {
  const _MarkdownTableRow({required final  List<TableCell> cells}): _cells = cells;
  

 final  List<TableCell> _cells;
@override List<TableCell> get cells {
  if (_cells is EqualUnmodifiableListView) return _cells;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cells);
}


/// Create a copy of MarkdownTableRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkdownTableRowCopyWith<_MarkdownTableRow> get copyWith => __$MarkdownTableRowCopyWithImpl<_MarkdownTableRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkdownTableRow&&const DeepCollectionEquality().equals(other._cells, _cells));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cells));

@override
String toString() {
  return 'MarkdownTableRow(cells: $cells)';
}


}

/// @nodoc
abstract mixin class _$MarkdownTableRowCopyWith<$Res> implements $MarkdownTableRowCopyWith<$Res> {
  factory _$MarkdownTableRowCopyWith(_MarkdownTableRow value, $Res Function(_MarkdownTableRow) _then) = __$MarkdownTableRowCopyWithImpl;
@override @useResult
$Res call({
 List<TableCell> cells
});




}
/// @nodoc
class __$MarkdownTableRowCopyWithImpl<$Res>
    implements _$MarkdownTableRowCopyWith<$Res> {
  __$MarkdownTableRowCopyWithImpl(this._self, this._then);

  final _MarkdownTableRow _self;
  final $Res Function(_MarkdownTableRow) _then;

/// Create a copy of MarkdownTableRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cells = null,}) {
  return _then(_MarkdownTableRow(
cells: null == cells ? _self._cells : cells // ignore: cast_nullable_to_non_nullable
as List<TableCell>,
  ));
}


}

/// @nodoc
mixin _$TableCell {

 List<InlineNode> get children;
/// Create a copy of TableCell
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TableCellCopyWith<TableCell> get copyWith => _$TableCellCopyWithImpl<TableCell>(this as TableCell, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TableCell&&const DeepCollectionEquality().equals(other.children, children));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'TableCell(children: $children)';
}


}

/// @nodoc
abstract mixin class $TableCellCopyWith<$Res>  {
  factory $TableCellCopyWith(TableCell value, $Res Function(TableCell) _then) = _$TableCellCopyWithImpl;
@useResult
$Res call({
 List<InlineNode> children
});




}
/// @nodoc
class _$TableCellCopyWithImpl<$Res>
    implements $TableCellCopyWith<$Res> {
  _$TableCellCopyWithImpl(this._self, this._then);

  final TableCell _self;
  final $Res Function(TableCell) _then;

/// Create a copy of TableCell
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? children = null,}) {
  return _then(_self.copyWith(
children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<InlineNode>,
  ));
}

}


/// Adds pattern-matching-related methods to [TableCell].
extension TableCellPatterns on TableCell {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TableCell value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TableCell() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TableCell value)  $default,){
final _that = this;
switch (_that) {
case _TableCell():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TableCell value)?  $default,){
final _that = this;
switch (_that) {
case _TableCell() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<InlineNode> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TableCell() when $default != null:
return $default(_that.children);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<InlineNode> children)  $default,) {final _that = this;
switch (_that) {
case _TableCell():
return $default(_that.children);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<InlineNode> children)?  $default,) {final _that = this;
switch (_that) {
case _TableCell() when $default != null:
return $default(_that.children);case _:
  return null;

}
}

}

/// @nodoc


class _TableCell implements TableCell {
  const _TableCell({required final  List<InlineNode> children}): _children = children;
  

 final  List<InlineNode> _children;
@override List<InlineNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of TableCell
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TableCellCopyWith<_TableCell> get copyWith => __$TableCellCopyWithImpl<_TableCell>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TableCell&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'TableCell(children: $children)';
}


}

/// @nodoc
abstract mixin class _$TableCellCopyWith<$Res> implements $TableCellCopyWith<$Res> {
  factory _$TableCellCopyWith(_TableCell value, $Res Function(_TableCell) _then) = __$TableCellCopyWithImpl;
@override @useResult
$Res call({
 List<InlineNode> children
});




}
/// @nodoc
class __$TableCellCopyWithImpl<$Res>
    implements _$TableCellCopyWith<$Res> {
  __$TableCellCopyWithImpl(this._self, this._then);

  final _TableCell _self;
  final $Res Function(_TableCell) _then;

/// Create a copy of TableCell
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? children = null,}) {
  return _then(_TableCell(
children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<InlineNode>,
  ));
}


}

// dart format on
