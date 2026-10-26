import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';

class CurrencySelectionDialog extends StatelessWidget {
  final String initialCurrency;
  final ValueChanged<String> onCurrencyChanged;

  const CurrencySelectionDialog({
    super.key,
    required this.initialCurrency,
    required this.onCurrencyChanged,
  });

  void _selectCurrency(BuildContext context, String currency) {
    onCurrencyChanged(currency);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDark = context.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isDark ? Border.all(color: Colors.white12) : null,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: .min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Spacer for centering title
                Text(
                  l10n.currency,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.textBlack,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: isDark ? AppColors.white : AppColors.textBlack,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Options
            RadioGroup<String>(
              groupValue: initialCurrency,
              onChanged: (value) {
                if (value != null) {
                  _selectCurrency(context, value);
                }
              },
              child: Column(
                children: AppConstants.supportedCurrencies.map((currency) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _buildOption(
                      context,
                      label: l10n.currencyName(currency.toLowerCase()),
                      value: currency,
                      onTap: () => _selectCurrency(context, currency),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.white : AppColors.textBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
          Radio<String>(value: value, activeColor: AppColors.primaryColor),
        ],
      ),
    );
  }
}
