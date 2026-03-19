import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_coin_icon.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final TransactionModel transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDarkMode = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Coin Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCoinColor(
                  transaction.coinSymbol,
                ).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CommonCoinIcon(
                  symbol: transaction.coinSymbol,
                  radius: 20,
                  iconBackgroundColor: _getCoinColor(transaction.coinSymbol),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Transaction Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.coinSymbol,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppColors.white : AppColors.textBlack,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(transaction.date),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Amount or Status
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                transaction.status == TransactionStatus.failed
                    ? l10n.failed
                    : '${_getTypePrefix(transaction.type)}${transaction.amount} ${transaction.coinSymbol}',
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: transaction.status == TransactionStatus.failed
                      ? Colors.red
                      : _getAmountColor(transaction.type, isDarkMode),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCoinColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'USDT':
        return AppColors.usdtColor;
      case 'BTC':
        return AppColors.bitcoinColor;
      case 'ETH':
        return AppColors.textWhite;
      case 'SOL':
        return const Color(0xFF9945FF); // Solana purple
      default:
        return AppColors.primaryColor;
    }
  }

  String _getTypePrefix(TransactionType type) {
    switch (type) {
      case TransactionType.sent:
        return '-';
      case TransactionType.received:
        return '+';
      case TransactionType.swap:
        return '';
    }
  }

  Color _getAmountColor(TransactionType type, bool isDarkMode) {
    switch (type) {
      case TransactionType.sent:
        return Colors.red;
      case TransactionType.received:
        return AppColors.greenColor;
      case TransactionType.swap:
        return isDarkMode ? AppColors.white : AppColors.textBlack;
    }
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }
}
