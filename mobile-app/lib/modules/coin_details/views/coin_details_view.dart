import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/coin_model/coin_model.dart';
import '../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../core/models/transaction_model/transaction_model.dart';
import '../../../core/theme/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/coins_prices_provider.dart';
import '../../../providers/global_provider.dart';
import '../../../providers/wallets_provider.dart';
import '../providers/coin_details_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/common_coin_icon.dart';
import '../../../widgets/common_loading_indicator.dart';
import '../../../widgets/no_transactions_found.dart';
import '../../../widgets/receive_send_swap_actions.dart';
import '../../dashboard/history/providers/history_provider.dart';
import '../../dashboard/history/widgets/transaction_item.dart';
import '../../dashboard/history/widgets/transaction_section_header.dart';

class CoinDetailsView extends StatelessWidget {
  const CoinDetailsView({super.key, required this.coinModel});

  final CoinModel? coinModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final selectedCurrency = context.watch<GlobalProvider>().selectedCurrency;
    final coinsPrices = context.watch<CoinsPricesProvider>();
    final walletsProvider = context.watch<WalletsProvider>();
    final historyProvider = context.watch<HistoryProvider>();
    final liveCoin = coinsPrices.coinForSymbol(coinModel?.symbol ?? '');
    final coinSymbol = coinModel?.symbol ?? '';
    final totalBalanceInCurrency = coinSymbol.isEmpty
        ? '0.00'
        : walletsProvider.balanceForCoinConverted(coinSymbol);
    final bool isWalletsLoading = walletsProvider.isLoading;

    /// SSE clears coins and sets loading when currency changes; avoid showing
    /// stale [coinModel] price/% until the new stream payload arrives.
    final bool showPriceQuoteLoading =
        coinsPrices.isLoading && liveCoin == null;
    final CoinModel? headerCoin = liveCoin ?? coinModel;
    final priceQuoteLabel =
        liveCoin?.quoteCurrencyLabel(context, selectedCurrency) ??
        coinModel?.quoteCurrencyLabel(context, selectedCurrency) ??
        selectedCurrency.toUpperCase();
    final priceValue = liveCoin?.valueInUsd ?? coinModel?.valueInUsd;
    final double change24h = liveCoin?.change24h ?? coinModel?.change24h ?? 0;
    final hasPrice =
        priceValue != null && priceValue.isNotEmpty && priceValue != '--';
    final bool isChangePositive = change24h >= 0;
    final String changeSign = isChangePositive ? '+' : '';
    final Color changeColor = isChangePositive
        ? AppColors.greenColor
        : AppColors.redColor;

    return Scaffold(
      appBar: AppBar(
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
            CommonCoinIcon(
              symbol: headerCoin?.symbol ?? '',
              radius: 16,
              networkIconUrl: headerCoin?.networkIconUrl,
            ),
            Flexible(
              child: Text(
                headerCoin?.localizedCoinPrimaryName(context) ?? '',
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
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.axis != Axis.vertical) return false;
            if (!historyProvider.hasMore || historyProvider.isLoadingMore) {
              return false;
            }
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
              historyProvider.loadMore();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: historyProvider.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeaderSection(
                    context,
                    l10n: l10n,
                    selectedCurrency: selectedCurrency,
                    totalBalanceInCurrency: totalBalanceInCurrency,
                    isWalletsLoading: isWalletsLoading,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildHistoryHeader(
                    context,
                    l10n: l10n,
                    historyProvider: historyProvider,
                  ),
                ),
                ..._buildHistorySlivers(
                  context,
                  historyProvider: historyProvider,
                ),
              ],
            ),
          ),
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
          children: [
            Expanded(
              child: Column(
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
                  if (showPriceQuoteLoading)
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CommonLoadingIndicator(),
                    )
                  else
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: hasPrice
                                ? '$priceValue '
                                : l10n.coinDetailsPriceUnavailable,
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.isDarkMode
                                  ? AppColors.white
                                  : AppColors.textBlack,
                            ),
                          ),
                          if (hasPrice)
                            TextSpan(
                              text: priceQuoteLabel,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: context.isDarkMode
                                    ? AppColors.textLightGrey
                                    : AppColors.textGrey,
                              ),
                            ),
                        ],
                      ),
                      textDirection: TextDirection.ltr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (!showPriceQuoteLoading && hasPrice) ...[
              const SizedBox(width: 12),
              // Text(
              //   changePercentText,
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              //   style: context.textTheme.titleMedium?.copyWith(
              //     color: changeColor,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: changeSign),
                    WidgetSpan(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '${change24h.toStringAsFixed(2)}%',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(text: ' '),
                    TextSpan(text: l10n.today),
                  ],
                  style: context.textTheme.titleMedium?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context, {
    required AppLocalizations l10n,
    required String selectedCurrency,
    required String totalBalanceInCurrency,
    required bool isWalletsLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l10n.yourTotalBalance,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.isDarkMode
                      ? AppColors.white
                      : AppColors.textGrey,
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
                  context.read<GlobalProvider>().toggleBalanceVisibility();
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
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 32.0, top: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            textDirection: .ltr,
            children: [
              if (context.watch<CoinDetailsProvider>().isLoading ||
                  isWalletsLoading)
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
                  "${l10n.currencySymbol(selectedCurrency.toLowerCase())} ${context.watch<GlobalProvider>().isBalanceVisible
                      ? totalBalanceInCurrency
                      : context.watch<AuthProvider>().state.isAuthenticated
                      ? '****'
                      : 'X'}",
                  textDirection: .ltr,
                  style: context.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode
                        ? AppColors.white
                        : AppColors.textBlack,
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: context.watch<CoinDetailsProvider>().isLoading
                    ? null
                    : () => context.read<GlobalProvider>().toggleCurrency(),
                child: Row(
                  spacing: 4,
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .end,
                  children: [
                    Text(
                      selectedCurrency.toUpperCase(),
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.isDarkMode
                            ? AppColors.white
                            : AppColors.textBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_down,
                      size: 16,
                      color: context.isDarkMode
                          ? AppColors.white
                          : AppColors.textBlack,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ReceiveSendSwapActions(
            coinSymbol: coinModel?.symbol,
            isDetailsPage: true,
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildHistoryHeader(
    BuildContext context, {
    required AppLocalizations l10n,
    required HistoryProvider historyProvider,
  }) {
    final selectedType = historyProvider.selectedTypeFilter;
    final filterLabel = _typeFilterLabel(l10n, selectedType);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.coinHistory,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? AppColors.white : AppColors.textBlack,
              fontSize: 18.0,
            ),
          ),
          PopupMenuButton<String>(
            initialValue: selectedType ?? HistoryTxType.all,
            tooltip: filterLabel,
            position: PopupMenuPosition.under,
            padding: EdgeInsets.zero,
            elevation: 4,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: context.isDarkMode
                ? AppColors.darkCardColor
                : AppColors.white,
            splashRadius: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              final normalized = value == HistoryTxType.all ? null : value;
              historyProvider.setTypeFilter(normalized);
            },
            itemBuilder: (context) => [
              _buildFilterMenuItem(
                context,
                value: HistoryTxType.all,
                label: l10n.all,
                isSelected: selectedType == null,
              ),
              _buildFilterMenuItem(
                context,
                value: HistoryTxType.sent,
                label: l10n.sent,
                isSelected: selectedType == HistoryTxType.sent,
              ),
              _buildFilterMenuItem(
                context,
                value: HistoryTxType.receive,
                label: l10n.received,
                isSelected: selectedType == HistoryTxType.receive,
              ),
              _buildFilterMenuItem(
                context,
                value: HistoryTxType.swap,
                label: l10n.swap,
                isSelected: selectedType == HistoryTxType.swap,
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              // decoration: BoxDecoration(
              //   color: context.isDarkMode
              //       ? AppColors.darkCardColor
              //       : const Color(0xFFF5F5F5),
              //   borderRadius: BorderRadius.circular(12),
              // ),
              child: Row(
                spacing: 6,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filterLabel,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.isDarkMode
                          ? AppColors.white
                          : AppColors.textBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 16,
                    color: context.isDarkMode
                        ? AppColors.white
                        : AppColors.textBlack,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildFilterMenuItem(
    BuildContext context, {
    required String value,
    required String label,
    required bool isSelected,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? AppColors.primaryColor
                  : context.isDarkMode
                  ? AppColors.white
                  : AppColors.textBlack,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isSelected)
            Icon(
              CupertinoIcons.checkmark,
              size: 16,
              color: AppColors.primaryColor,
            ),
        ],
      ),
    );
  }

  String _typeFilterLabel(AppLocalizations l10n, String? type) {
    switch (type) {
      case HistoryTxType.sent:
        return l10n.sent;
      case HistoryTxType.receive:
        return l10n.receive;
      case HistoryTxType.swap:
        return l10n.swap;
      default:
        return l10n.all;
    }
  }

  List<Widget> _buildHistorySlivers(
    BuildContext context, {
    required HistoryProvider historyProvider,
  }) {
    if (historyProvider.isLoading && historyProvider.transactions.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CommonLoadingIndicator()),
          ),
        ),
      ];
    }

    if (historyProvider.transactions.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 32),
            child: NoTransactionsFound(),
          ),
        ),
      ];
    }

    final groups = _groupTransactionsByDate(historyProvider.transactions);
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final sectionDate = group['date'] as DateTime;
            final sectionTxs = group['transactions'] as List<TransactionModel>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TransactionSectionHeader(
                  date: sectionDate,
                  isFirst: index == 0,
                ),
                ...sectionTxs.map(
                  (transaction) => TransactionItem(
                    transaction: transaction,
                    onTap: () {
                      context.push(
                        Routes.transactionDetail,
                        extra: transaction,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      if (historyProvider.isLoadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CommonLoadingIndicator()),
          ),
        ),
    ];
  }

  List<Map<String, dynamic>> _groupTransactionsByDate(
    List<TransactionModel> transactions,
  ) {
    final sorted = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final recentTransactions = <TransactionModel>[];
    final olderTransactions = <DateTime, List<TransactionModel>>{};

    for (final tx in sorted) {
      final txDate = DateTime(
        tx.createdAt.year,
        tx.createdAt.month,
        tx.createdAt.day,
      );
      if (txDate == today || txDate == yesterday) {
        recentTransactions.add(tx);
      } else {
        final monthKey = DateTime(tx.createdAt.year, tx.createdAt.month);
        olderTransactions.putIfAbsent(monthKey, () => []).add(tx);
      }
    }

    final result = <Map<String, dynamic>>[];

    if (recentTransactions.isNotEmpty) {
      result.add({
        'date': today,
        'transactions': recentTransactions,
        'isRecently': true,
      });
    }

    final olderList =
        olderTransactions.entries
            .map(
              (entry) => {
                'date': entry.key,
                'transactions': entry.value,
                'isRecently': false,
              },
            )
            .toList()
          ..sort(
            (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
          );

    result.addAll(olderList);

    return result;
  }
}
