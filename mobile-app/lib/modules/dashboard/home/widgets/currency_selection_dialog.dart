import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';

class CurrencySelectionDialog extends StatefulWidget {
  final String initialCurrency;
  final ValueChanged<String> onCurrencyChanged;

  const CurrencySelectionDialog({
    super.key,
    required this.initialCurrency,
    required this.onCurrencyChanged,
  });

  @override
  State<CurrencySelectionDialog> createState() =>
      _CurrencySelectionDialogState();
}

class _CurrencySelectionDialogState extends State<CurrencySelectionDialog> {
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.initialCurrency;
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
              groupValue: _selectedCurrency,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCurrency = value);
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
                      onTap: () => setState(() => _selectedCurrency = currency),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onCurrencyChanged(_selectedCurrency);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.save,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
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
          Radio<String>(
            value: value,
            onChanged: (_) => onTap(),
            activeColor: AppColors.primaryColor,
          ),
          // Container(
          //   width: 20,
          //   height: 20,
          //   padding: EdgeInsets.zero,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     border: Border.all(
          //       color: isSelected
          //           ? AppColors.primaryColor
          //           : (isDark ? Colors.white24 : Colors.black12),
          //       width: 1,
          //     ),
          //     color: isSelected ? AppColors.primaryColor : Colors.transparent,
          //   ),
          //   child: isSelected
          //       ? Center(
          //           child: Container(
          //             padding: EdgeInsets.all(8),
          //             decoration: const BoxDecoration(
          //               color: Colors.white,
          //               shape: BoxShape.circle,
          //             ),
          //           ),
          //         )
          //       : null,
          // ),
        ],
      ),
    );
  }
}
