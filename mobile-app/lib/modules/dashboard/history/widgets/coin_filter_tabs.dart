import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';

class CoinFilterTabs extends StatelessWidget {
  const CoinFilterTabs({
    super.key,
    required this.selectedCoin,
    required this.onCoinSelected,
  });

  final String? selectedCoin;
  final ValueChanged<String?> onCoinSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDarkMode = context.isDarkMode;
    final coins = ['All', 'USDT', 'ETH', 'Sol', 'BTC'];

    return Column(
      children: [
        // Tabs Row
        Row(
          children: coins.map((coin) {
            final isSelected =
                (selectedCoin == null && coin == 'All') ||
                selectedCoin?.toUpperCase() == coin.toUpperCase();

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  onCoinSelected(coin == 'All' ? null : coin);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        coin == 'All' ? l10n.all : coin,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppColors.primaryColor
                              : (isDarkMode
                                    ? AppColors.textLightGrey
                                    : AppColors.textGrey),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
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
          }).toList(),
        ),
        // Divider line below all tabs
        Divider(
          height: 1,
          thickness: 1,
          color: isDarkMode ? AppColors.darkCardColor : const Color(0xFFE8E8E8),
        ),
      ],
    );
  }
}
