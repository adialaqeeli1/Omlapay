import 'dart:ui';
import 'package:flutter/material.dart';

class CommonTransparentCard extends StatelessWidget {
  const CommonTransparentCard({
    super.key,
    required this.child,
    this.glassColor = Colors.white, // Default base color
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.blurSigma = 5.0, // Controls the blur strength
    this.opacity = 0.1, // Controls the opacity of the color
    this.borderColor,
  });

  final Widget child;
  final Color glassColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double blurSigma;
  final double opacity;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: glassColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}
