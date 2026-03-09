import 'package:flutter/material.dart';
import 'package:omlapay_mobile_app/widgets/theme_aware_icon.dart';

class CommonIconButton extends StatelessWidget {
  const CommonIconButton({
    super.key,
    required this.onTap,
    required this.iconPath,
    required this.iconSize,
    required this.iconPadding,
    this.colorToInvert,
  });

  final VoidCallback onTap;
  final String iconPath;
  final double? iconSize;
  final double? iconPadding;
  final Color? colorToInvert;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: iconPath.split('/').last,
      transitionOnUserGestures: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: iconPadding == null
                ? EdgeInsets.zero
                : EdgeInsets.all(iconPadding!),
            child: ThemeAwareIcon(
              assetPath: iconPath,
              width: iconSize,
              height: iconSize,
              colorToInvert: colorToInvert,
            ),
          ),
        ),
      ),
    );
  }
}
