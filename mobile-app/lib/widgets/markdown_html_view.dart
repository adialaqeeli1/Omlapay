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
    this.textScale = 1.0,
    this.headingScale = 1.0,
  });

  final String data;
  final void Function(String url)? onLinkTap;
  final bool selectable;

  /// Multiplier applied on top of the user's current text scale. Use a value
  /// below 1.0 to render this document slightly smaller than the rest of the
  /// app (e.g. dense legal copy) while preserving the user's accessibility
  /// scale.
  final double textScale;

  /// Additional multiplier applied only to heading-tier text styles
  /// (`displaySmall`, `headlineMedium`/`Small`, `titleLarge`/`Medium`/`Small`).
  /// Stacks with [textScale] for headings (final scale = textScale *
  /// headingScale); body text is unaffected.
  final double headingScale;

  @override
  Widget build(BuildContext context) {
    Widget child = selectable
        ? _SelectableMarkdownHtmlBody(data: data, onLinkTap: onLinkTap)
        : renderBlocks(parseMarkdown(data), onLinkTap: onLinkTap);

    if (headingScale != 1.0) {
      final theme = Theme.of(context);
      final t = theme.textTheme;
      child = Theme(
        data: theme.copyWith(
          textTheme: t.copyWith(
            displaySmall: _scaledFontSize(t.displaySmall, headingScale),
            headlineMedium: _scaledFontSize(t.headlineMedium, headingScale),
            headlineSmall: _scaledFontSize(t.headlineSmall, headingScale),
            titleLarge: _scaledFontSize(t.titleLarge, headingScale),
            titleMedium: _scaledFontSize(t.titleMedium, headingScale),
            titleSmall: _scaledFontSize(t.titleSmall, headingScale),
          ),
        ),
        child: child,
      );
    }

    if (textScale != 1.0) {
      final mediaQuery = MediaQuery.of(context);
      final combined = mediaQuery.textScaler.scale(1.0) * textScale;
      child = MediaQuery(
        data: mediaQuery.copyWith(textScaler: TextScaler.linear(combined)),
        child: child,
      );
    }
    return child;
  }
}

TextStyle? _scaledFontSize(TextStyle? style, double scale) {
  if (style == null || style.fontSize == null) return style;
  return style.copyWith(fontSize: style.fontSize! * scale);
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
