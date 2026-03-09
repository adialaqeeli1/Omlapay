import 'package:flutter/material.dart';
import '../core/extentions/context_extensions.dart';
import 'custom_svg_painter.dart';

/// A reusable widget for SVG icons that adapt their border/outline color
/// based on the current theme.
///
/// In light mode: icons will have black borders/outlines
/// In dark mode: icons will have white borders/outlines
class ThemeAwareIcon extends StatelessWidget {
  const ThemeAwareIcon({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.colorToInvert,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? colorToInvert;

  @override
  Widget build(BuildContext context) {
    // In light mode, invert white to black
    // In dark mode, keep white as is
    final color = colorToInvert ?? (context.isDarkMode ? null : Colors.white);

    return CustomSvgPainterWidget(
      assetPath: assetPath,
      width: width,
      height: height,
      fit: fit,
      colorToInvert: color,
    );
  }
}
