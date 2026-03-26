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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          l10n.sendFlowReviewTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
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
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.amountController.text} ${provider.selectedCoin?.localizedCoinTicker(context) ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
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
                color: const Color(0xFF1E2025),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    l10n.transferToLabel,
                    provider.selectedContact?.name ??
                        provider.recipientController.text,
                  ),
                  const Divider(color: Color(0xFF2A2D35), height: 30),
                  _buildDetailRow(l10n.network, 'TRC20'), // Mock
                  const Divider(color: Color(0xFF2A2D35), height: 30),
                  _buildDetailRow(l10n.networkFeeLabel, '1.00 USDT'), // Mock fee
                  const Divider(color: Color(0xFF2A2D35), height: 30),
                  _buildDetailRow(
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.confirmSecurely,
                  style: const TextStyle(
                    color: Colors.white,
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

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
