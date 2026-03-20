import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../providers/coins_prices_provider.dart';

/// First tab is always **All**; remaining tabs follow the SSE coin list order.
class CoinFilterTabs extends StatelessWidget {
  const CoinFilterTabs({
    super.key,
    required this.selectedCoin,
    required this.onCoinSelected,
  });

  /// `null` means All.
  final String? selectedCoin;
  final ValueChanged<String?> onCoinSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDarkMode = context.isDarkMode;
    final coinsPrices = context.watch<CoinsPricesProvider>();
    final seen = <String>{};
    final coinSymbols = <String>[];
    for (final c in coinsPrices.coins) {
      if (seen.add(c.symbol.toUpperCase())) {
        coinSymbols.add(c.symbol);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.only(start: 4, end: 16),
          child: Row(
            children: [
              _CoinFilterTabChip(
                label: l10n.all,
                isSelected: selectedCoin == null,
                isDarkMode: isDarkMode,
                textTheme: context.textTheme,
                onTap: () => onCoinSelected(null),
              ),
              ...coinSymbols.map(
                (symbol) => _CoinFilterTabChip(
                  label: symbol,
                  isSelected:
                      selectedCoin?.toUpperCase() == symbol.toUpperCase(),
                  isDarkMode: isDarkMode,
                  textTheme: context.textTheme,
                  onTap: () => onCoinSelected(symbol),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: isDarkMode ? AppColors.darkCardColor : const Color(0xFFE8E8E8),
        ),
      ],
    );
  }
}

class _CoinFilterTabChip extends StatelessWidget {
  const _CoinFilterTabChip({
    required this.label,
    required this.isSelected,
    required this.isDarkMode,
    required this.textTheme,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDarkMode;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 4),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? AppColors.primaryColor
                      : (isDarkMode
                          ? AppColors.textLightGrey
                          : AppColors.textGrey),
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 20,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              )
            else
              const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
