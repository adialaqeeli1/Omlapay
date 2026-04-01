import 'package:flutter/material.dart';
import 'package:omlapay_mobile_app/core/extentions/context_extensions.dart';
import 'package:omlapay_mobile_app/widgets/common_back_button.dart';
import 'package:provider/provider.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
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
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: CommonBackButton(),
        title: Text(
          l10n.reviewOrderTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
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
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outlineVariant),
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
                            Text(
                              l10n.swapDirectionFrom,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
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
                                      fromCoin?.localizedCoinTicker(context) ??
                                          '',
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Amount
                                Text(
                                  provider.fromAmountController.text,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
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
                                '≈100,15 ${l10n.usd}', // TODO: Calculate real USD value
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider line partial
                      Divider(color: colorScheme.outlineVariant, height: 1),

                      // To Section
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.swapDirectionTo,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
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
                                      toCoin?.localizedCoinTicker(context) ??
                                          '',
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Amount
                                Text(
                                  provider.toAmountController.text,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
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
                                '≈2,15 ${l10n.usd}', // TODO: Calculate real USD value
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
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
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.outlineVariant,
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
                Text(
                  l10n.network,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
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
                Text(
                  l10n.swapFeesTitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${provider.swapFee} ${fromCoin?.localizedCoinTicker(context) ?? ''}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
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
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.swapNowButton,
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
