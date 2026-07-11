import 'package:flutter/material.dart';

import '../core/theme/theme.dart';

/// A compact pill switch whose track stays [AppColors.primaryColor] in **both**
/// states. A white thumb slides left/right and [label] is rendered in the
/// blank track space opposite the thumb (iOS labeled-switch style).
///
/// Built for the settings language toggle (`EN` / `AR`) but kept generic so any
/// two-state choice with a short code can reuse it. Positioning is forced LTR
/// so the thumb side stays predictable even after the app flips to RTL.
class LabeledToggleSwitch extends StatelessWidget {
  const LabeledToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.width = 58,
    this.height = 30,
  });

  /// Current state. The thumb sits on the right when `true`, left when `false`.
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Short text shown in the blank track space opposite the thumb — e.g. the
  /// active language code, `EN` / `AR`.
  final String label;

  final double width;
  final double height;

  static const Duration _duration = Duration(milliseconds: 200);
  static const Curve _curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thumbSize = height - 6;
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: height,
        // Matches the Material Switch used by the 2FA / notification rows:
        // a primary-tinted track at half opacity with a solid primary thumb.
        // Same fill regardless of on/off, per design.
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              // Label fills the blank space opposite the thumb.
              AnimatedAlign(
                duration: _duration,
                curve: _curve,
                alignment: value ? Alignment.centerLeft : Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isDark ? AppColors.white : AppColors.textBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // Solid primary sliding thumb.
              AnimatedAlign(
                duration: _duration,
                curve: _curve,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
