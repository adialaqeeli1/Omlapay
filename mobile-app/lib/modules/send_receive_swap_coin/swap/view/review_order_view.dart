import 'package:flutter/material.dart';
import 'package:omlapay_mobile_app/widgets/common_back_button.dart';
import 'package:provider/provider.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_coin_icon.dart';
import '../../../../widgets/theme_aware_icon.dart';
import '../provider/swap_provider.dart';
import '../../../../routes/app_router.dart';
import 'package:go_router/go_router.dart';

class ReviewOrderView extends StatelessWidget {
  const ReviewOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SwapProvider>();
    final fromCoin = provider.fromCoin;
    final toCoin = provider.toCoin;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CommonBackButton(),
        title: const Text(
          'Review Order',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Main Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16171D), // Dark card background
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      // From Section
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'From',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Coin Info
                                Row(
                                  children: [
                                    _buildCoinIcon(fromCoin?.symbol ?? ''),
                                    const SizedBox(width: 12),
                                    Text(
                                      fromCoin?.symbol ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Amount
                                Text(
                                  provider.fromAmountController.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // USD Value
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '≈100,15 USD', // TODO: Calculate real USD value
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider line partial
                      const Divider(color: Color(0xFF2A2D35), height: 1),

                      // To Section
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'To',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Coin Info
                                Row(
                                  children: [
                                    _buildCoinIcon(toCoin?.symbol ?? ''),
                                    const SizedBox(width: 12),
                                    Text(
                                      toCoin?.symbol ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Amount
                                Text(
                                  provider.toAmountController.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // USD Value
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '≈2,15 USD', // TODO: Calculate real USD value
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Center Swap Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF1E2025,
                      ), // Inner card color or slightly lighter?
                      // The design usually has a darker circle background matching parent or app bg
                      // Let's use a subtle dark color or transparency if needed
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2A2D35),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: ThemeAwareIcon(
                        assetPath: 'assets/icons/swap.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Network Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Network',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2D35),
                    borderRadius: BorderRadius.circular(6),

                    // If active/selected, typically teal. Screenshot showed TRC20 teal?
                    // Let's assume generic teal chip for "TRC20" as per prompt description
                  ),
                  child: const Text(
                    'TRC20',
                    style: TextStyle(
                      color: AppColors.tealColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Swap Fees
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Swap Fees',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  '${provider.swapFee} ${fromCoin?.symbol ?? ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Swap Now Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  context.push(Routes.swapSuccess, extra: provider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Swap Now',
                  style: TextStyle(
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

  Widget _buildCoinIcon(String symbol) {
    Color? backgroundColor;
    Widget? fallbackIcon;

    if (symbol == 'USDT') {
      backgroundColor = AppColors.usdtColor;
      fallbackIcon = const Icon(
        CryptoFontIcons.USDT,
        color: Colors.white,
        size: 24,
      );
    } else if (symbol == 'ETH') {
      backgroundColor = AppColors.textWhite;
      fallbackIcon = const Icon(
        CryptoFontIcons.ETH,
        color: Colors.black,
        size: 24,
      );
    } else if (symbol == 'BTC') {
      backgroundColor = AppColors.bitcoinColor;
      fallbackIcon = const Icon(
        CryptoFontIcons.BTC,
        color: Colors.white,
        size: 24,
      );
    }

    return CommonCoinIcon(
      symbol: symbol,
      iconBackgroundColor: backgroundColor,
      fallbackIcon: fallbackIcon,
      radius: 20, // Slightly larger for review screen? or same 20 rad = 40 dia
    );
  }
}
