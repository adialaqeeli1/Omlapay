import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
import 'package:intl/intl.dart';

class TransactionSectionHeader extends StatelessWidget {
  const TransactionSectionHeader({
    super.key,
    required this.date,
    this.isFirst = false,
  });

  final DateTime date;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDarkMode = context.isDarkMode;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    String sectionTitle;
    if (txDate == today || txDate == yesterday) {
      sectionTitle = l10n.recently;
    } else {
      sectionTitle = DateFormat('MMMM, yyyy').format(date);
    }

    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 0 : 24,
        bottom: 12,
      ),
      child: Text(
        sectionTitle,
        style: context.textTheme.bodyMedium?.copyWith(
          color: isDarkMode ? AppColors.textLightGrey : AppColors.textGrey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
