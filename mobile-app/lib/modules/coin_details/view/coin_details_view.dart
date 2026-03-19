import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/models/coin_model/coin_model.dart';
import '../../../core/theme/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/global_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/common_coin_icon.dart';
import '../../../widgets/no_transactions_found.dart';
import '../../../widgets/receive_send_swap_actions.dart';
import '../../dashboard/home/widgets/currency_selection_dialog.dart';
import '../providers/coin_details_provider.dart';

class CoinDetailsView extends StatelessWidget {
  const CoinDetailsView({super.key, required this.coinModel});

  final CoinModel? coinModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final selectedCurrency = context.watch<GlobalProvider>().selectedCurrency;
    final provider = context.watch<CoinDetailsProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              leading: CommonBackButton(),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Row(
                spacing: 14,
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonCoinIcon(symbol: coinModel?.symbol ?? '', radius: 16),
                  Flexible(
                    child: Text(
                      coinModel?.name ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.isDarkMode
                            ? AppColors.white
                            : AppColors.textBlack,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: .min,
                children: [
                  // Balance Section
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: .center,
                      mainAxisSize: .min,
                      crossAxisAlignment: .center,
                      children: [
                        Text(
                          l10n.yourTotalBalance,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final isAuthenticated = context
                                .read<AuthProvider>()
                                .state
                                .isAuthenticated;

                            if (!isAuthenticated) {
                              context.push(Routes.loginOrRegister);
                              return;
                            }
                            context
                                .read<GlobalProvider>()
                                .toggleBalanceVisibility();
                          },
                          icon: SvgPicture.asset(
                            context.watch<GlobalProvider>().isBalanceVisible
                                ? 'assets/icons/eye.svg'
                                : 'assets/icons/eye-close.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              AppColors.primaryColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: 32.0,
                      top: 4.0,
                    ),
                    child: Row(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .center,
                      mainAxisSize: .min,
                      children: [
                        if (context.watch<GlobalProvider>().isBalanceLoading)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.isDarkMode
                                    ? AppColors.textWhite
                                    : AppColors.textBlack,
                              ),
                            ),
                          )
                        else
                          Text(
                            context.watch<GlobalProvider>().isBalanceVisible
                                ? (coinModel?.amount ?? '0.00')
                                : context
                                      .watch<AuthProvider>()
                                      .state
                                      .isAuthenticated
                                ? '****'
                                : 'X',
                            style: context.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.isDarkMode
                                  ? AppColors.white
                                  : AppColors.textBlack,
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Currency Selector
                        GestureDetector(
                          onTap:
                              context.watch<GlobalProvider>().isBalanceLoading
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => CurrencySelectionDialog(
                                      initialCurrency: selectedCurrency,
                                      onCurrencyChanged: (currency) {
                                        context
                                            .read<GlobalProvider>()
                                            .updateCurrency(currency);
                                      },
                                    ),
                                  );
                                },
                          child: Row(
                            children: [
                              Text(
                                selectedCurrency,
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: AppColors.textGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_down,
                                size: 16,
                                color: AppColors.textGrey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const ReceiveSendSwapActions(),
                  ),

                  const SizedBox(height: 48),

                  // History Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.coinHistory,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.isDarkMode
                                ? AppColors.white
                                : AppColors.textBlack,
                            fontSize: 18.0,
                          ),
                        ),

                        Row(
                          spacing: 4,
                          children: [
                            Text(
                              l10n.all,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                            Icon(
                              CupertinoIcons.chevron_down,
                              size: 16,
                              color: AppColors.textGrey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const NoTransactionsFound(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        height: 110,
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? const Color(0xFF1E1E1E) // Slightly lighter than black
              : AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.currentPrice,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${provider.currentPrice.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} ',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode
                              ? AppColors.white
                              : AppColors.textBlack,
                        ),
                      ),
                      TextSpan(
                        text: selectedCurrency,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              '+${provider.priceChange} (${provider.priceChangePercent}%) ${l10n.today}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.greenColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
