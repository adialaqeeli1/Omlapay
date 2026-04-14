import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../core/theme/theme.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_back_button.dart';
import '../provider/send_provider.dart';

class ReviewSendView extends StatelessWidget {
  const ReviewSendView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SendProvider>();
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendFlowReviewTitle),
        elevation: 0,
        leading: const CommonBackButton(),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    l10n.youAreSending,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.amountController.text} ${provider.selectedCoin?.localizedCoinTicker(context) ?? ''}',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    l10n.transferToLabel,
                    provider.selectedContact?.name ??
                        provider.recipientController.text,
                  ),
                  Divider(color: colorScheme.outlineVariant, height: 30),
                  _buildDetailRow(context, l10n.network, provider.network),
                  Divider(color: colorScheme.outlineVariant, height: 30),
                  _buildDetailRow(
                    context,
                    l10n.networkFeeLabel,
                    '1.00 USDT',
                  ), // Mock fee
                  Divider(color: colorScheme.outlineVariant, height: 30),
                  _buildDetailRow(
                    context,
                    l10n.total,
                    '${(double.tryParse(provider.amountController.text) ?? 0) + 1} ${provider.selectedCoin?.localizedCoinTicker(context) ?? ''}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  context.push(Routes.sendSuccess, extra: provider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealColor,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.confirmSecurely,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
