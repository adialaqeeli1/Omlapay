import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omlapay_mobile_app/core/extentions/context_extensions.dart';
import 'package:omlapay_mobile_app/widgets/common_back_button.dart';
import 'package:provider/provider.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_coin_icon.dart';
import '../../../../widgets/theme_aware_icon.dart';
import '../provider/swap_provider.dart';

class ReviewOrderView extends StatelessWidget {
  const ReviewOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SwapProvider>();
    final fromCoin = provider.fromCoin;
    final toCoin = provider.toCoin;
    final quote = provider.swapQuote;
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: CommonBackButton(),
        title: Text(
          l10n.reviewOrderTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                                    _buildCoinIcon(fromCoin),
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
                                  double.parse(
                                    quote?.fromAmount ??
                                        provider.fromAmountController.text,
                                  ).toStringAsFixed(5),
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
                                '≈${quote?.fromAmountUsd ?? '0.00'} ${l10n.usd}',
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
                                    _buildCoinIcon(toCoin),
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
                                  double.parse(
                                    quote?.estimatedToAmount ??
                                        provider.toAmountController.text,
                                  ).toStringAsFixed(5),
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
                                '≈${quote?.estimatedToAmountUsd ?? '0.00'} ${l10n.usd}',
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

            // Exchange Rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.swapExchangeRate,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '1 ${fromCoin?.localizedCoinTicker(context) ?? ''} ≈ ${quote?.exchangeRate ?? '—'} ${toCoin?.localizedCoinTicker(context) ?? ''}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
                  '${quote?.totalFee ?? '0'} ${l10n.usd}',
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
                onPressed: provider.isSubmitting
                    ? null
                    : () => _onSwapNowPressed(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealColor,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor: AppColors.tealColor.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: provider.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        l10n.swapNowButton,
                        style: context.textTheme.titleMedium?.copyWith(
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

  Future<void> _onSwapNowPressed(
    BuildContext context,
    SwapProvider provider,
  ) async {
    final l10n = context.l10n!;
    try {
      final success = await provider.executeSwap();
      if (!context.mounted) return;
      if (success) {
        context.push(Routes.swapSuccess, extra: provider);
      }
    } on AppException catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, e.localizedMessage(context.l10n));
    } catch (_) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, l10n.unknownError);
    }
  }

  Widget _buildCoinIcon(CoinModel? coin) {
    final symbol = coin?.symbol ?? '';
    Color iconBackgroundColor;
    Widget? fallbackIcon;

    if (symbol == 'USDT') {
      iconBackgroundColor = AppColors.usdtColor;
      fallbackIcon = const Icon(
        CryptoFontIcons.USDT,
        color: Colors.white,
        size: 24,
      );
    } else if (symbol == 'ETH') {
      iconBackgroundColor = AppColors.textWhite;
      fallbackIcon = const Icon(
        CryptoFontIcons.ETH,
        color: Colors.black,
        size: 24,
      );
    } else if (symbol == 'BTC') {
      iconBackgroundColor = AppColors.bitcoinColor;
      fallbackIcon = const Icon(
        CryptoFontIcons.BTC,
        color: Colors.white,
        size: 24,
      );
    } else {
      iconBackgroundColor = Colors.grey;
    }

    return CommonCoinIcon(
      symbol: symbol,
      iconBackgroundColor: iconBackgroundColor,
      fallbackIcon: fallbackIcon,
      radius: 20,
      networkIconUrl: coin?.networkIconUrl,
    );
  }
}
