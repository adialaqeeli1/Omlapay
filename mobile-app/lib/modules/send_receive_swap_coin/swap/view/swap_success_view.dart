import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../routes/app_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_back_button.dart';
import '../provider/swap_provider.dart';

class SwapSuccessView extends StatelessWidget {
  const SwapSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SwapProvider>();
    final l10n = context.l10n!;
    final toCoin = provider.toCoin;
    // We display the To amount as the result
    final toAmount = provider.toAmountController.text;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CommonBackButton(
          onPressed: () {
            // context.pop(); // Standard back
            context.go(Routes.home); // Safety to go home
          },
        ),
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
                  colors: [
                    AppColors.successGradientStart,
                    AppColors.successGradientEnd,
                  ],
                  stops: [0.3, 1.0],
                ),
                borderRadius: BorderRadius.circular(24),
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
                    l10n.swapSuccessMessage,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$toAmount ${toCoin?.localizedCoinTicker(context) ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF1E2E2C,
                          ), // Dark green tint for value?
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '0,282 ${l10n.usd}', // Mock value matching screenshot style
                          style: const TextStyle(
                            color: AppColors.tealColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
                  backgroundColor: const Color(
                    0xFF2A2D35,
                  ), // Grey button in screenshot
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.backHome,
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
}
