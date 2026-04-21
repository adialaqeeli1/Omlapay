import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../providers/coins_prices_provider.dart';
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
    final isDarkMode = context.isDarkMode;
    final coins = context.watch<CoinsPricesProvider>().coins;
    final matchingCoin = coins
        .where((c) => c.symbol == transaction.assetSymbol)
        .firstOrNull;
    final fallbackIcon = matchingCoin?.iconUrl ?? matchingCoin?.networkIconUrl;

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
                  transaction.assetSymbol,
                ).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CommonCoinIcon(
                  symbol: transaction.assetSymbol,
                  radius: 20,
                  iconBackgroundColor: _getCoinColor(transaction.assetSymbol),
                  networkIconUrl:
                      transaction.networkIconUrl ??
                      transaction.assetIconUrl ??
                      fallbackIcon,
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
                    transaction.assetSymbol,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppColors.white : AppColors.textBlack,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(transaction.createdAt),
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
                transaction.isFailed
                    ? context.l10n!.failed
                    : '${(double.tryParse(transaction.amount) ?? 0).toStringAsFixed(5)} ${transaction.assetSymbol}',
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: transaction.isFailed
                      ? Colors.red
                      : _getAmountColor(transaction, isDarkMode),
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
        return const Color(0xFF9945FF);
      default:
        return AppColors.primaryColor;
    }
  }

  Color _getAmountColor(TransactionModel tx, bool isDarkMode) {
    if (tx.isSent) return Colors.red;
    if (tx.isReceived) return AppColors.greenColor;
    return isDarkMode ? AppColors.white : AppColors.textBlack;
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd h:mm a').format(date.toLocal());
  }
}
