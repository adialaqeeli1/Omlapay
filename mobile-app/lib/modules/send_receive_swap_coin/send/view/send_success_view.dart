import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../core/theme/theme.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_back_button.dart';
import '../provider/send_provider.dart';

class SendSuccessView extends StatelessWidget {
  const SendSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SendProvider>();
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: l10n.successScreenTitle,
          child: const SizedBox.shrink(),
        ),
        elevation: 0,
        leading: CommonBackButton(onPressed: () => context.go(Routes.home)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Success Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [
                          AppColors.successGradientStart,
                          AppColors.successGradientEnd,
                        ]
                      : [
                          AppColors.lightCardColor,
                          AppColors.primaryColor.withValues(alpha: 0.18),
                        ],
                  stops: const [0.3, 1.0],
                ),
                borderRadius: BorderRadius.circular(24),
                border: isDark
                    ? null
                    : Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  // Icon
                  SvgPicture.asset(
                    'assets/icons/swap-confirmed.svg',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.sendSuccessMessage,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textLightGrey
                          : colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${provider.amountController.text} ${provider.selectedCoin?.localizedCoinTicker(context) ?? ''}',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textWhite
                          : colorScheme.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2E2C)
                          : AppColors.tealColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l10n.sendSuccessRecipientLine(
                        provider.selectedContact?.name ??
                            provider.recipientController.text,
                      ),
                      style: const TextStyle(
                        color: AppColors.tealColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Back Home Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  context.go(Routes.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  foregroundColor: colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.backHome,
                  style: TextStyle(
                    color: colorScheme.onSurface,
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
}
