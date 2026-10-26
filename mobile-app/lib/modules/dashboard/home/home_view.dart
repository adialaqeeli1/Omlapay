import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:omlapay_mobile_app/core/constants/constants.dart';

import '../../../core/extentions/context_extensions.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/coin_model/coin_model.dart';
import '../../../core/theme/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_grid_bg_wrapper.dart';
import '../../../widgets/common_icon_button.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';
import 'package:omlapay_mobile_app/widgets/asset_card.dart';
import 'package:omlapay_mobile_app/widgets/no_transactions_found.dart';
import 'package:provider/provider.dart';

import '../../../widgets/receive_send_swap_actions.dart';
import '../../../../providers/global_provider.dart';
import 'provider/home_provider.dart';
import 'widgets/currency_selection_dialog.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;

    final screenWidth = context.width;

    // Responsive icon size based on screen width
    final iconSize = context.responsiveValue<double>(
      mobile: screenWidth * 0.08, // ~32px on 400px screen
      tablet: screenWidth * 0.06, // ~36px on 600px screen
      desktop: 40.0,
    );

    // Responsive icon padding
    final iconPadding = context.responsiveValue<double>(
      mobile: screenWidth * 0.02, // ~8px on 400px screen
      tablet: screenWidth * 0.015, // ~9px on 600px screen
      desktop: 10.0,
    );

    final horizontalPadding =
        screenWidth * 0.05; // 5% padding for responsiveness

    final String selectedCurrency = context
        .watch<GlobalProvider>()
        .selectedCurrency;
    final bool isAuthenticated = context
        .watch<AuthProvider>()
        .state
        .isAuthenticated;

    return CommonGridBgWrapper(
      headerTitle: l10n.seamlessCryptoPayments,
      headerSubTitle: l10n.instantSecureAnytime,
      horizontalPadding: horizontalPadding,
      applyHorizontalPaddingToHeaderButtonsOnly: true,
      appBarButtons: [
        // Notifications Icon
        CommonIconButton(
          iconPath: 'assets/icons/notifications-icon.svg',
          iconSize: iconSize,
          iconPadding: iconPadding,
          onTap: () => context.push(Routes.notifications),
        ),
        // Scan Icon
        CommonIconButton(
          iconPath: 'assets/icons/scan-icon.svg',
          iconSize: iconSize,
          iconPadding: iconPadding,
          onTap: () => context.push(Routes.qrScanner),
        ),
      ],
      headerChild: _totalBalanceDropdown(
        context,
        l10n,
        selectedCurrency: selectedCurrency,
        onCurrencyChanged: (currency) {
          context.read<GlobalProvider>().updateCurrency(currency);
        },
        isAuthenticated: isAuthenticated,
      ),
      bottomWidget: isAuthenticated ? ReceiveSendSwapActions() : null,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: .start,
        mainAxisSize: .min,
        textDirection: context.textDirection,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding,
            ),
            child: _buildCurrencyDropdown(
              context,
              l10n,
              selectedCurrency: selectedCurrency,
              onCurrencyChanged: (currency) {
                if ((currency ?? '').isEmpty) return;
                context.read<GlobalProvider>().updateCurrency(currency!);
              },
            ),
          ),
          SizedBox(
            height: 196,
            child: Column(
              spacing: 12.0,
              crossAxisAlignment: .start,
              mainAxisAlignment: .start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: Text(
                    l10n.assets,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.isDarkMode
                          ? AppColors.white
                          : AppColors.textBlack,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                _buildAssetsSection(
                  context,
                  l10n,
                  selectedCurrency: selectedCurrency,
                  horizontalPadding: horizontalPadding,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .center,
              mainAxisSize: .max,
              children: [
                Text(
                  l10n.transactions,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.isDarkMode
                        ? AppColors.white
                        : AppColors.textBlack,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: const NoTransactionsFound()),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAssetsSection(
    BuildContext context,
    AppLocalizations l10n, {
    required String selectedCurrency,
    required double horizontalPadding,
  }) {
    final currencyName = l10n.currencyName(selectedCurrency.toLowerCase());

    final homeProvider = context.watch<HomeProvider>();
    if (homeProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final List<CoinModel> coins = homeProvider.coins;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
      padding: EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding),
      child: Row(
        spacing: 12,
        children: coins.map((coin) {
          // Determine color and icon based on symbol for now
          Color? iconBgColor;
          Widget? iconWidget;

          if (coin.symbol == 'USDT') {
            iconBgColor = AppColors.usdtColor;
            iconWidget = DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.usdtColor,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  CryptoFontIcons.USDT,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          } else if (coin.symbol == 'ETH') {
            iconBgColor = AppColors.textWhite;
            iconWidget = DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.textWhite,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(CryptoFontIcons.ETH, color: Colors.black, size: 24),
              ),
            );
          } else if (coin.symbol == 'BTC') {
            iconBgColor = AppColors.bitcoinColor;
            iconWidget = DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.bitcoinColor,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(CryptoFontIcons.BTC, color: Colors.white, size: 24),
              ),
            );
          }

          return AssetCard(
            symbol: coin.symbol,
            name: coin.name,
            amount: coin.amount,
            valueInUsd: '${coin.valueInUsd} $currencyName',
            iconBackgroundColor: iconBgColor,
            icon: iconWidget,
            onTap: () => context.push(Routes.coinDetails, extra: coin),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrencyDropdown(
    BuildContext context,
    AppLocalizations l10n, {
    required String selectedCurrency,
    required ValueChanged<String?> onCurrencyChanged,
  }) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 8.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            value: selectedCurrency,
            onChanged: context.watch<GlobalProvider>().isBalanceLoading
                ? null
                : onCurrencyChanged,
            items: AppConstants.supportedCurrencies
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      l10n.currencyName(e.toLowerCase()),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: selectedCurrency.toLowerCase() == e.toLowerCase()
                            ? AppColors.textLightGrey
                            : context.isDarkMode
                            ? AppColors.textWhite
                            : AppColors.textBlack,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                )
                .toList(),
            dropdownStyleData: DropdownStyleData(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: context.isDarkMode
                    ? AppColors.textBlack
                    : AppColors.textWhite,
              ),
              elevation: 10,
            ),
            buttonStyleData: ButtonStyleData(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            ),
            customButton: SizedBox(
              width: 80,
              height: 40,
              child: Row(
                mainAxisSize: .min,
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                spacing: 4,
                children: [
                  Text(
                    selectedCurrency,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.isDarkMode
                          ? AppColors.textWhite
                          : AppColors.textBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(top: 4.0),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: context.isDarkMode
                          ? AppColors.textWhite
                          : AppColors.textBlack,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalBalanceDropdown(
    BuildContext context,
    AppLocalizations l10n, {
    required String selectedCurrency,
    required ValueChanged<String> onCurrencyChanged,
    required bool isAuthenticated,
  }) => Stack(
    fit: .expand,
    children: [
      Positioned.directional(
        textDirection: context.textDirection,
        start: 0,
        end: 0,
        top: 0,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .center,
          mainAxisAlignment: .center,
          children: [
            Text(
              l10n.yourTotalBalance,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: .min,
              mainAxisAlignment: .end,
              crossAxisAlignment: .end,
              spacing: 4,
              children: [
                if (context.watch<GlobalProvider>().isBalanceLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
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
                    "${l10n.currencySymbol(selectedCurrency.toLowerCase())} ${(isAuthenticated && context.watch<GlobalProvider>().isBalanceVisible)
                        ? '0'
                        : isAuthenticated
                        ? '****'
                        : 'X'}",
                    style: context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode
                          ? AppColors.white
                          : AppColors.textBlack,
                    ),
                  ),
                InkWell(
                  onTap:
                      (isAuthenticated &&
                          !context.watch<GlobalProvider>().isBalanceLoading)
                      ? () {
                          showDialog(
                            context: context,
                            builder: (_) => CurrencySelectionDialog(
                              initialCurrency: selectedCurrency,
                              onCurrencyChanged: onCurrencyChanged,
                            ),
                          );
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: 4.0,
                      start: 4.0,
                    ),
                    child: Row(
                      spacing: 4,
                      crossAxisAlignment: .end,
                      mainAxisAlignment: .end,
                      mainAxisSize: .min,
                      children: [
                        Text(
                          selectedCurrency,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.isDarkMode
                                ? AppColors.textLightGrey
                                : AppColors.textBlack,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          CupertinoIcons.chevron_down,
                          size: 18,
                          color: context.isDarkMode
                              ? AppColors.textLightGrey
                              : AppColors.textBlack,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // if (isAuthenticated)
      Positioned.directional(
        textDirection: context.textDirection,
        end: 16,
        bottom: 0,
        child: IconButton(
          onPressed: () {
            if (isAuthenticated) {
              if (context.read<GlobalProvider>().isBalanceLoading) return;
              context.read<GlobalProvider>().toggleBalanceVisibility();
              return;
            } else {
              context.push(Routes.loginOrRegister);
              return;
            }
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
      ),
    ],
  );
}
