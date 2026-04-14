import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/kyc_verification_required_banner.dart';
import '../provider/swap_provider.dart';
import '../widgets/currency_input_card.dart';
import '../../../../widgets/theme_aware_icon.dart';
import '../../../../widgets/coin_selection_sheet.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_router.dart';
import '../../../../providers/kyc_status_provider.dart';
import '../../../../providers/wallets_provider.dart';
import '../../../kyc_verification/utils/kyc_verification_entry_source.dart';

class SwapCoinView extends StatelessWidget {
  const SwapCoinView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SwapProvider>();
    final kycProvider = context.watch<KycStatusProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: CommonBackButton(),
          title: Text(
            l10n.swap,
            style: theme.textTheme.titleMedium?.copyWith(
              color: context.isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: CommonBackButton(),
        title: Text(
          l10n.swap,
          style: theme.textTheme.titleMedium?.copyWith(
            color: context.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  SizedBox(
                    height: 220,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // From Card
                        PositionedDirectional(
                          top: 0,
                          start: 0,
                          end: 0,
                          child: CurrencyInputCard(
                            title: l10n.swapDirectionFrom,
                            coinSymbol: provider.fromCoin?.symbol ?? '',
                            coinSymbolLabel:
                                provider.fromCoin?.localizedCoinPrimaryName(
                                  context,
                                ) ??
                                l10n.selectCoinPlaceholder,
                            amount: provider.fromCoin != null 
                                ? context.watch<WalletsProvider>().balanceForCoin(provider.fromCoin!.symbol) 
                                : '0',
                            controller: provider.fromAmountController,
                            isFrom: true,
                            errorText: provider.error,
                            onMaxPressed: provider.setMaxAmount,
                            hasBorder: true,
                            onCoinTap: () =>
                                _showCoinSelection(context, provider, true),
                            networkIconUrl: provider.fromCoin?.networkIconUrl,
                          ),
                        ),
                        // Swap Icon
                        PositionedDirectional(
                          start: 0,
                          end: 0,
                          bottom: (220 / 2) - 38,
                          child: Center(
                            child: IconButton(
                              onPressed: provider.swapCoins,
                              icon: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.isDarkMode
                                      ? colorScheme.surfaceContainerLow
                                      : Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: const ThemeAwareIcon(
                                    assetPath: 'assets/icons/swap.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // To Card
                        PositionedDirectional(
                          start: 0,
                          end: 0,
                          bottom: 0,
                          child: CurrencyInputCard(
                            title: l10n.swapDirectionTo,
                            coinSymbol: provider.toCoin?.symbol ?? '',
                            coinSymbolLabel:
                                provider.toCoin?.localizedCoinPrimaryName(
                                  context,
                                ) ??
                                l10n.selectCoinPlaceholder,
                            amount: provider.toCoin != null 
                                ? context.watch<WalletsProvider>().balanceForCoin(provider.toCoin!.symbol) 
                                : '0',
                            controller: provider.toAmountController,
                            isFrom: false,
                            readOnly: true,
                            onCoinTap: () =>
                                _showCoinSelection(context, provider, false),
                            networkIconUrl: provider.toCoin?.networkIconUrl,
                          ),
                        ),
                      ],
                    ),
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
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '1.3 USDT', // Mock value
                              style: TextStyle(
                                color: colorScheme.onSurface,
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
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  if (kycProvider.showBanner)
                    KycVerificationRequiredBanner(
                      kycStatus: kycProvider.kycStatus,
                      entrySource: KycVerificationEntrySource.swap,
                      rejectionReason: kycProvider.rejectionReason,
                    ),

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
                            : colorScheme.surfaceContainerHighest,
                        foregroundColor: provider.canSwap
                            ? AppColors.white
                            : colorScheme.onSurface.withValues(alpha: 0.38),
                        disabledBackgroundColor:
                            colorScheme.surfaceContainerHighest,
                        disabledForegroundColor: colorScheme.onSurface
                            .withValues(alpha: 0.38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.confirmSwapButton,
                        style: const TextStyle(
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
}
