import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/markdown/markdown_parser.dart';
import '../core/markdown/markdown_renderer.dart';

/// Renders a markdown + HTML document as a column of Flutter widgets.
///
/// The widget parses [data] on every build (cost is sub-millisecond for the
/// document sizes this app uses). Styling flows entirely from
/// [Theme.of(context)] — there are no style-override props.
///
/// Links fire via [onLinkTap]; URL policy (open in browser, navigate, copy,
/// ignore) is the caller's responsibility.
///
/// Images render with [Image.network] and fall back to alt text on load error.
///
/// When [selectable] is true the output is wrapped in a [SelectionArea] and
/// the widget internally delegates to a [StatefulWidget] so tap-gesture
/// recognizers attached to link spans are disposed on rebuild.
class MarkdownHtmlView extends StatelessWidget {
  const MarkdownHtmlView({
    super.key,
    required this.data,
    this.onLinkTap,
    this.selectable = false,
  });

  final String data;
  final void Function(String url)? onLinkTap;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    if (selectable) {
      return _SelectableMarkdownHtmlBody(
        data: data,
        onLinkTap: onLinkTap,
      );
    }
    return renderBlocks(parseMarkdown(data), onLinkTap: onLinkTap);
  }
}

class _SelectableMarkdownHtmlBody extends StatefulWidget {
  const _SelectableMarkdownHtmlBody({
    required this.data,
    required this.onLinkTap,
  });

  final String data;
  final void Function(String url)? onLinkTap;

  @override
  State<_SelectableMarkdownHtmlBody> createState() =>
      _SelectableMarkdownHtmlBodyState();
}

class _SelectableMarkdownHtmlBodyState
    extends State<_SelectableMarkdownHtmlBody> {
  final List<TapGestureRecognizer> _recognizers = [];

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final blocks = parseMarkdown(widget.data);
    final rendered = renderBlocksWithRecognizers(
      blocks,
      onLinkTap: widget.onLinkTap,
    );
    _recognizers.addAll(rendered.recognizers);
    return SelectionArea(child: rendered.widget);
  }
}
