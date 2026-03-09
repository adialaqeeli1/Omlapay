import 'package:flutter/material.dart';

import '../core/theme/theme.dart';

class CommonFormLabel extends StatelessWidget {
  const CommonFormLabel({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isDark ? AppColors.textWhite : AppColors.textBlack,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
