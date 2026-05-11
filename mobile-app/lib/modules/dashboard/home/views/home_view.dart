import 'dart:convert';
import 'dart:developer';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/extentions/number_extensions.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../core/models/wallet_model/wallet_model.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/utility.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_grid_bg_wrapper.dart';
import '../../../../widgets/common_icon_button.dart';
import 'package:omlapay_mobile_app/widgets/asset_card.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:omlapay_mobile_app/widgets/common_coin_icon.dart';
import 'package:omlapay_mobile_app/widgets/no_transactions_found.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/receive_send_swap_actions.dart';
import '../../../../providers/coins_prices_provider.dart';
import '../../../../providers/global_provider.dart';
import '../../../../providers/wallets_provider.dart';
import '../../../scan/view/qr_scanner_view.dart';
import '../../../send_receive_swap_coin/send/view/send_coin_view.dart';
import '../providers/home_provider.dart';
import '../widgets/currency_selection_dialog.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Refresh wallets every time the home page is entered so balances
    // are always up-to-date.  The wallets API requires authentication.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isAuthenticated = context
          .read<AuthProvider>()
          .state
          .isAuthenticated;
      if (isAuthenticated) {
        context.read<WalletsProvider>().refreshWallets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final authState = context.watch<AuthProvider>().state;
    final currentUser = authState.user;
    final userPhone = _resolveDisplayPhone(
      countryCode: currentUser?.countryCode ?? '',
      mobileNumber: currentUser?.mobileNumber ?? '',
      fullMobileNumber: currentUser?.fullMobileNumber,
    );

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
    final bool isAuthenticated = authState.isAuthenticated;

    return CommonGridBgWrapper(
      headerTitle: l10n.seamlessCryptoPayments,
      headerSubTitle: l10n.instantSecureAnytime,
      horizontalPadding: horizontalPadding,
      applyHorizontalPaddingToHeaderButtonsOnly: true,
      appBarLeading: isAuthenticated && userPhone.isNotEmpty
          ? Padding(
              padding: EdgeInsetsDirectional.only(start: horizontalPadding),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.welcomeBack,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.isDarkMode
                            ? AppColors.textGrey
                            : AppColors.textLightGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            userPhone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.isDarkMode
                                  ? AppColors.textWhite
                                  : AppColors.textBlack,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (currentUser?.isVerified == true) ...[
                          const SizedBox(width: 6),
                          SvgPicture.asset(
                            'assets/icons/check.svg',
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
      appBarLeadingWidth: screenWidth * 0.62,
      appBarButtons: [
        // Notifications Icon
        badges.Badge(
          showBadge:
              (context.watch<HomeProvider>().homeData?.unreadNotifications ??
                  0) >
              0,
          badgeContent: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              '${context.watch<HomeProvider>().homeData?.unreadNotifications ?? 0}',
              style: TextStyle(color: AppColors.textWhite, fontSize: 10),
            ),
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: AppColors.redColor,
            padding: const EdgeInsets.all(4),
          ),
          position: badges.BadgePosition.topEnd(top: -5, end: 5),
          child: CommonIconButton(
            iconPath: 'assets/icons/notifications-icon.svg',
            iconSize: iconSize,
            iconPadding: iconPadding,
            onTap: () async {
              if (kDebugMode) {
                await PushNotificationService.instance
                    .showDemoNotification()
                    .onError((error, stackTrace) {
                      log("$error");
                      return false;
                    });
              }
              await context.push(Routes.notifications);
              if (context.mounted) {
                context.read<HomeProvider>().fetchHomeData();
              }
            },
          ),
        ),
        // Scan Icon
        CommonIconButton(
          iconPath: 'assets/icons/scan-icon.svg',
          iconSize: iconSize,
          iconPadding: iconPadding,
          onTap: () async {
            final scanned = await context.push<String>(
              Routes.qrScanner,
              extra: const QrScannerExtra(
                validator: Utility.isValidWalletAddress,
              ),
            );
            if (scanned == null || !context.mounted) return;
            final wallet = _parseScannedWallet(scanned);
            if (wallet == null) return;
            context.push(
              Routes.sendCoin,
              extra: SendCoinExtra(
                initialCoinSymbol: wallet.symbol.isEmpty ? null : wallet.symbol,
                initialRecipient: wallet.address,
              ),
            );
          },
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
          // Todo Uncomment when needed
          // Padding(
          //   padding: EdgeInsetsDirectional.symmetric(
          //     horizontal: horizontalPadding,
          //   ),
          //   child: _buildCurrencyDropdown(
          //     context,
          //     l10n,
          //     selectedCurrency: selectedCurrency,
          //     onCurrencyChanged: (currency) {
          //       if ((currency ?? '').isEmpty) return;
          //       context.read<GlobalProvider>().updateCurrency(currency!);
          //     },
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
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
                    selectedCurrency: selectedCurrency,
                    horizontalPadding: horizontalPadding,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
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
                _buildRecentTransactions(context),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAssetsSection(
    BuildContext context, {
    required String selectedCurrency,
    required double horizontalPadding,
  }) {
    final coinsPrices = context.watch<CoinsPricesProvider>();
    final walletsProvider = context.watch<WalletsProvider>();
    if (coinsPrices.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final List<CoinModel> coins = [...coinsPrices.coins]
      ..sort((a, b) {
        final aBalance = walletsProvider.rawBalanceForCoin(a.symbol);
        final bBalance = walletsProvider.rawBalanceForCoin(b.symbol);
        return bBalance.compareTo(aBalance);
      });
    final l10n = context.l10n!;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        padding: EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding),
        child: Row(
          spacing: 12,
          children: coins.map((coin) {
            // Determine color and icon based on symbol for now
            Color? iconBgColor;
            Widget? iconWidget;

            return AssetCard(
              symbol: coin.symbol,
              symbolLabel: coin.localizedCoinTicker(context),
              name: coin.name.isEmpty ? coin.symbol : coin.name,
              amount: walletsProvider.balanceForCoin(coin.symbol),
              networkIconUrl: coin.networkIconUrl,
              currentPrice: walletsProvider.balanceForCoinConverted(
                coin.symbol,
              ),
              // currentPrice:
              //     '${walletsProvider.balanceForCoinConverted(coin.symbol)} ${coin.quoteCurrencyLabel(context, selectedCurrency)}',
              // currentPrice: walletsProvider.balanceForCoinConverted(
              //   coin.symbol,
              // ),
              selectedCurrency: l10n.currencySymbol(
                selectedCurrency.toLowerCase(),
              ),
              iconBackgroundColor: iconBgColor,
              icon: iconWidget,
              onTap: () => context.push(Routes.coinDetails, extra: coin),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final coins = context.watch<CoinsPricesProvider>().coins;
    final transactions = homeProvider.homeData?.recentTransactions ?? [];

    if (transactions.isEmpty) {
      return const Center(child: NoTransactionsFound());
    }

    return Column(
      children: transactions.map((transaction) {
        final isDarkMode = context.isDarkMode;

        Color getAmountColor() {
          if (transaction.isFailed) return Colors.red;
          if (transaction.isSent) return Colors.red;
          if (transaction.isReceived) return AppColors.greenColor;
          return isDarkMode ? AppColors.white : AppColors.textBlack;
        }

        final matchingCoin = coins
            .where((c) => c.symbol == transaction.assetSymbol)
            .firstOrNull;
        final fallbackIcon =
            matchingCoin?.iconUrl ?? matchingCoin?.networkIconUrl;

        return InkWell(
          onTap: () =>
              context.push(Routes.transactionDetail, extra: transaction),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonCoinIcon(
                  symbol: transaction.assetSymbol,
                  networkIconUrl:
                      transaction.networkIconUrl ??
                      transaction.assetIconUrl ??
                      fallbackIcon,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.assetName ?? transaction.assetSymbol,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppColors.white
                              : AppColors.textBlack,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'yyyy-MM-dd h:mm a',
                        ).format(transaction.createdAt.toLocal()),
                        textDirection: TextDirection.ltr,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  transaction.isFailed
                      ? context.l10n!.failed
                      : '${double.tryParse(transaction.amount)?.toFormattedAmount() ?? transaction.amount} ${transaction.assetSymbol}',
                  textDirection: transaction.isFailed
                      ? null
                      : TextDirection.ltr,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: getAmountColor(),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Todo Uncomment when needed
  // Widget _buildCurrencyDropdown(
  //   BuildContext context,
  //   AppLocalizations l10n, {
  //   required String selectedCurrency,
  //   required ValueChanged<String?> onCurrencyChanged,
  // }) {
  //   return Align(
  //     alignment: AlignmentDirectional.centerEnd,
  //     child: Padding(
  //       padding: const EdgeInsetsDirectional.only(top: 8.0),
  //       child: DropdownButtonHideUnderline(
  //         child: DropdownButton2<String>(
  //           valueListenable: ValueNotifier(selectedCurrency),
  //           onChanged: context.watch<HomeProvider>().isLoading
  //               ? null
  //               : onCurrencyChanged,
  //           items: AppConstants.supportedCurrencies
  //               .map(
  //                 (e) => DropdownItem<String>(
  //                   value: e,
  //                   child: Text(
  //                     e.toUpperCase(),
  //                     style: context.textTheme.bodyMedium?.copyWith(
  //                       color: selectedCurrency.toLowerCase() == e.toLowerCase()
  //                           ? AppColors.textLightGrey
  //                           : context.isDarkMode
  //                           ? AppColors.textWhite
  //                           : AppColors.textBlack,
  //                       fontWeight: FontWeight.w500,
  //                       fontSize: 16.0,
  //                     ),
  //                   ),
  //                 ),
  //               )
  //               .toList(),
  //           dropdownStyleData: DropdownStyleData(
  //             width: 156,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(12),
  //               color: context.isDarkMode
  //                   ? AppColors.textBlack
  //                   : AppColors.textWhite,
  //             ),
  //             elevation: 10,
  //           ),
  //           buttonStyleData: ButtonStyleData(
  //             decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
  //           ),
  //           customButton: SizedBox(
  //             width: 124,
  //             height: 40,
  //             child: Row(
  //               mainAxisSize: .min,
  //               crossAxisAlignment: .center,
  //               mainAxisAlignment: .center,
  //               spacing: 4,
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     selectedCurrency.toUpperCase(),
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                     textAlign: TextAlign.end,
  //                     style: context.textTheme.bodyMedium?.copyWith(
  //                       color: context.isDarkMode
  //                           ? AppColors.textWhite
  //                           : AppColors.textBlack,
  //                       fontWeight: FontWeight.w500,
  //                       fontSize: 16.0,
  //                     ),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: EdgeInsetsDirectional.only(top: 4.0),
  //                   child: Icon(
  //                     Icons.keyboard_arrow_down,
  //                     color: context.isDarkMode
  //                         ? AppColors.textWhite
  //                         : AppColors.textBlack,
  //                     size: 20,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
        textDirection: TextDirection.ltr,
        start: 0,
        end: 0,
        top: 16,
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
              textDirection: TextDirection.ltr,
              children: [
                if (context.watch<HomeProvider>().isLoading)
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
                        ? (selectedCurrency.toLowerCase() == 'sar' ? (context.watch<HomeProvider>().homeData?.totalBalanceSar ?? '0.00') : (context.watch<HomeProvider>().homeData?.totalBalance ?? '0.00'))
                        : isAuthenticated
                        ? '****'
                        : 'X'}",
                    textDirection: TextDirection.ltr,
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
                          !context.watch<HomeProvider>().isLoading)
                      ? () {
                          showDialog(
                            context: context,
                            builder: (_) => CurrencySelectionDialog(
                              initialCurrency: selectedCurrency,
                              onCurrencyChanged: onCurrencyChanged,
                            ),
                          );
                        }
                      : () => context.push(Routes.loginOrRegister),
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
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 96),
                          child: Text(
                            selectedCurrency.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.isDarkMode
                                  ? AppColors.textLightGrey
                                  : AppColors.textBlack,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
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
        textDirection: TextDirection.ltr,

        end: 16,
        bottom: -10,
        child: IconButton(
          onPressed: () {
            if (isAuthenticated) {
              final homeProvider = context.read<HomeProvider>();
              if (homeProvider.isLoading) return;
              final globalProvider = context.read<GlobalProvider>();
              globalProvider.toggleBalanceVisibility();
              if (globalProvider.isBalanceVisible &&
                  !homeProvider.hasFetchedHome) {
                homeProvider.fetchHomeData();
              }
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

  String _resolveDisplayPhone({
    required String countryCode,
    required String mobileNumber,
    String? fullMobileNumber,
  }) {
    final fullPhone = (fullMobileNumber ?? '').trim();
    if (fullPhone.isNotEmpty) {
      return fullPhone.startsWith('+') ? fullPhone : '+$fullPhone';
    }

    final normalizedCountry = countryCode.trim();
    final normalizedMobile = mobileNumber.trim();
    if (normalizedCountry.isEmpty && normalizedMobile.isEmpty) {
      return '';
    }

    final countryWithPlus = normalizedCountry.startsWith('+')
        ? normalizedCountry
        : '+$normalizedCountry';
    return '$countryWithPlus $normalizedMobile'.trim();
  }

  /// Defensive parse of a scanned QR payload back into a [WalletCoinModel].
  ///
  /// The scanner's validator already accepted the value, so a parse failure
  /// here would mean someone bypassed validation; we just bail out silently.
  WalletCoinModel? _parseScannedWallet(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) return null;
      return WalletCoinModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
