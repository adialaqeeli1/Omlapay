import 'package:flutter/material.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';

class CommonExpandableText extends StatefulWidget {
  const CommonExpandableText({
    super.key,
    required this.text,
    this.trimLines = 4,
    this.style,
    this.linkStyle,
  });

  final String text;
  final int trimLines;
  final TextStyle? style;
  final TextStyle? linkStyle;

  @override
  State<CommonExpandableText> createState() => _CommonExpandableTextState();
}

class _CommonExpandableTextState extends State<CommonExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final textDirection = Directionality.of(context);
    final effectiveStyle =
        widget.style ?? DefaultTextStyle.of(context).style;
    final effectiveLinkStyle = widget.linkStyle ??
        effectiveStyle.copyWith(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: effectiveStyle),
          maxLines: widget.trimLines,
          textDirection: textDirection,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);

        final didOverflow = textPainter.didExceedMaxLines;

        if (!didOverflow) {
          return Text(widget.text, style: effectiveStyle);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: effectiveStyle,
              maxLines: _expanded ? null : widget.trimLines,
              overflow:
                  _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  _expanded ? l10n.readLess : l10n.readMore,
                  style: effectiveLinkStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
