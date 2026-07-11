import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/theme_aware_icon.dart';

enum ShareDestination { whatsapp, messages, mail }

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({super.key, required this.transaction, this.onShare});

  final TransactionModel transaction;
  final void Function(ShareDestination destination)? onShare;

  static void show(
    BuildContext context, {
    required TransactionModel transaction,
    void Function(ShareDestination destination)? onShare,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          ShareBottomSheet(transaction: transaction, onShare: onShare),
    );
  }

  String _formatAmount(String amount) {
    try {
      final cleanAmount = amount.replaceAll(RegExp(r'^[+-]'), '');
      final numValue = double.parse(cleanAmount);
      return NumberFormat('#,##0.00000').format(numValue);
    } catch (e) {
      return amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final surfaceColor = isDarkMode ? AppColors.darkCardColor : Colors.white;
    final textColor = isDarkMode ? AppColors.textWhite : AppColors.textBlack;
    final secondaryColor = AppColors.textLightGrey;

    final amountText =
        '${_formatAmount(transaction.amount)} ${transaction.assetSymbol}';
    final dateText = DateFormat('MMMM, yyyy').format(transaction.createdAt);
    final hashText = transaction.txHash ?? '';

    final shareOptions = [
      (ShareDestination.whatsapp, l10n.whatsapp, const Color(0xFF25D366)),
      (ShareDestination.messages, l10n.messages, const Color(0xFF007AFF)),
      (ShareDestination.mail, l10n.mail, const Color(0xFF9E9E9E)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    l10n.shareTo,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: IconButton(
                      icon: Icon(
                        CupertinoIcons.xmark,
                        color: textColor,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Transaction summary
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ThemeAwareIcon(
                    assetPath: 'assets/icons/upload_circle_fill.svg',
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                amountText,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              dateText,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: textColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (hashText.isNotEmpty)
                          Text(
                            hashText.length > 35
                                ? '${hashText.substring(0, 35)}...'
                                : hashText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryColor,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Share options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: shareOptions.map((option) {
                  final (destination, label, color) = option;
                  return _ShareOption(
                    label: label,
                    color: color,
                    icon: _getShareIcon(destination),
                    onTap: () {
                      onShare?.call(destination);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getShareIcon(ShareDestination destination) {
    switch (destination) {
      case ShareDestination.whatsapp:
        return const Icon(Icons.chat, color: Colors.white, size: 24);
      case ShareDestination.messages:
        return const Icon(Icons.message, color: Colors.white, size: 24);
      case ShareDestination.mail:
        return const Icon(Icons.email, color: Colors.white, size: 24);
    }
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.textWhite : AppColors.textBlack;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
