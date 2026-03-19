import 'package:flutter/material.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';
import 'custom_svg_painter.dart';

class NoTransactionsFound extends StatelessWidget {
  const NoTransactionsFound({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;

    return Column(
      crossAxisAlignment: .center,
      mainAxisAlignment: .center,
      mainAxisSize: .max,
      children: [
        // Using a placeholder icon since we don't have the exact asset
        CustomSvgPainterWidget(
          assetPath: 'assets/icons/empty-state.svg',
          colorToInvert: context.isDarkMode ? Colors.white : Colors.black,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.noTransactionsFound,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.isDarkMode
                ? AppColors.textGrey
                : AppColors.textBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.allIncomingTransactionsListed,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.isDarkMode
                ? AppColors.textGrey
                : AppColors.textLightGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
