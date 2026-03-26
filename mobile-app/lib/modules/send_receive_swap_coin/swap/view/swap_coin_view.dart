import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_back_button.dart';
import '../provider/swap_provider.dart';
import '../widgets/currency_input_card.dart';
import '../../../../widgets/theme_aware_icon.dart';
import 'coin_selection_sheet.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_router.dart';

class SwapCoinView extends StatelessWidget {
  const SwapCoinView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SwapProvider>();
    final l10n = context.l10n!;

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CommonBackButton(),
          title: Text(l10n.swap, style: const TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CommonBackButton(),
        title: Text(l10n.swap, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 6,
                    children: [
                      // From Card
                      CurrencyInputCard(
                        title: l10n.swapDirectionFrom,
                        coinSymbol: provider.fromCoin?.symbol ?? '',
                        coinSymbolLabel:
                            provider.fromCoin?.localizedCoinTicker(context) ??
                            l10n.selectCoinPlaceholder,
                        amount: provider.fromCoin?.amount ?? '0',
                        controller: provider.fromAmountController,
                        isFrom: true,
                        errorText: provider.error,
                        onMaxPressed: provider.setMaxAmount,
                        hasBorder: true,
                        onCoinTap: () =>
                            _showCoinSelection(context, provider, true),
                      ),

                      // Swap Icon
                      Center(
                        child: GestureDetector(
                          onTap: provider.swapCoins,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: const ThemeAwareIcon(
                              assetPath: 'assets/icons/swap.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),

                      // To Card
                      CurrencyInputCard(
                        title: l10n.swapDirectionTo,
                        coinSymbol: provider.toCoin?.symbol ?? '',
                        coinSymbolLabel:
                            provider.toCoin?.localizedCoinTicker(context) ??
                            l10n.selectCoinPlaceholder,
                        amount: provider.toCoin?.amount ?? '0',
                        controller: provider.toAmountController,
                        isFrom: false,
                        readOnly: true,
                        onCoinTap: () =>
                            _showCoinSelection(context, provider, false),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .center,
                    children: [
                      // Swap Fees
                      if (provider.fromCoin != null && provider.toCoin != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.swapFeesColon,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '1.3 USDT', // Mock value
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 4),
                      // Exchange rate info (mock)
                      if (provider.fromCoin != null && provider.toCoin != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '1 ${provider.fromCoin!.localizedCoinTicker(context)} ≈ 0.00032 ${provider.toCoin!.localizedCoinTicker(context)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  if (provider.showVerificationWarning)
                    _buildVerificationBanner(context, provider),

                  const SizedBox(height: 32.0),

                  // Preview Conversion Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: provider.canSwap
                          ? () {
                              context.push(Routes.swapReview, extra: provider);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.canSwap
                            ? AppColors.tealColor
                            : const Color(0xFF1A2221),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF1A2221),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.confirmSwapButton,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCoinSelection(
    BuildContext context,
    SwapProvider provider,
    bool isFrom,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: CoinSelectionSheet(
          title: isFrom
              ? context.l10n!.swapDirectionFrom
              : context.l10n!.swapDirectionTo,
          coins: provider.coins,
          selectedCoin: isFrom ? provider.fromCoin : provider.toCoin,
          onCoinSelected: (coin) {
            if (isFrom) {
              provider.setFromCoin(coin);
            } else {
              provider.setToCoin(coin);
            }
          },
        ),
      ),
    );
  }

  Widget _buildVerificationBanner(BuildContext context, SwapProvider provider) {
    final l10n = context.l10n!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3F1519), // Dark Red background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B252C)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: l10n.swapKycVerificationRequiredBody),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await context.push(
                          Routes.sendVerification,
                        );
                        if (result == true) {
                          // ignore: use_build_context_synchronously
                          provider.completeVerification();
                        }
                      },
                      child: Text(
                        l10n.verifyNowButton,
                        style: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
