import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../providers/coins_prices_provider.dart';
import '../../../../providers/kyc_status_provider.dart';
import '../../../kyc_verification/utils/kyc_verification_entry_source.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/common_coin_icon.dart';
import '../../../../widgets/kyc_verification_required_banner.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/no_transactions_found.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../widgets/theme_aware_icon.dart';
import '../../../../routes/app_router.dart';
import '../provider/receive_coins_history_provider.dart';

class ReceiveCoinsHistoryView extends StatefulWidget {
  const ReceiveCoinsHistoryView({super.key});

  @override
  State<ReceiveCoinsHistoryView> createState() =>
      _ReceiveCoinsHistoryViewState();
}

class _ReceiveCoinsHistoryViewState extends State<ReceiveCoinsHistoryView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = context.read<ReceiveCoinsHistoryProvider>().uniqueCoinSymbols;
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (!mounted) return;
    final coin = _tabs[_tabController.index];
    context.read<ReceiveCoinsHistoryProvider>().setCoinFilter(coin);
  }

  void _syncTabsIfNeeded(List<String> newTabs) {
    if (_tabsEqual(_tabs, newTabs)) return;
    final currentCoin = _tabs.isNotEmpty && _tabController.index < _tabs.length
        ? _tabs[_tabController.index]
        : 'All';
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _tabs = newTabs;
    final newIndex = _tabs.indexOf(currentCoin);
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: newIndex >= 0 ? newIndex : 0,
    );
    _tabController.addListener(_onTabChanged);
  }

  bool _tabsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<ReceiveCoinsHistoryProvider>();
    final kycProvider = context.watch<KycStatusProvider>();
    _syncTabsIfNeeded(provider.uniqueCoinSymbols);

    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.receive,
          style: theme.textTheme.titleMedium?.copyWith(
            color: context.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: const CommonBackButton(),
        actions: [
          IconButton(
            icon: ThemeAwareIcon(
              assetPath: "assets/icons/notifications-icon.svg",
              width: 24,
              height: 24,
            ),
            onPressed: () => context.pushNamed('notifications'),
            constraints: BoxConstraints.loose(const Size(24, 24)),
            padding: EdgeInsets.zero,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: _tabs.length > 4,
          tabAlignment: _tabs.length > 4
              ? TabAlignment.start
              : TabAlignment.fill,
          indicatorWeight: 0.1,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
          indicatorAnimation: TabIndicatorAnimation.linear,
          automaticIndicatorColorAdjustment: true,
          indicatorColor: colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          dividerColor: Colors.transparent,
          tabs: _tabs.map((e) => Tab(text: e)).toList(),
        ),
      ),
      body: Column(
        children: [
          if (kycProvider.showBanner)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: KycVerificationRequiredBanner(
                kycStatus: kycProvider.kycStatus,
                entrySource: KycVerificationEntrySource.receiveHistory,
                rejectionReason: kycProvider.rejectionReason,
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((_) => const _TransactionList()).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReceiveCoinsHistoryProvider>();
    final transactions = provider.transactions;

    if (provider.isLoading && transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty) {
      return const Center(child: NoTransactionsFound());
    }

    final l10n = AppLocalizations.of(context)!;
    final grouped = _groupTransactions(transactions, l10n);

    final colorScheme = Theme.of(context).colorScheme;
    final isLoadingMore = provider.isLoadingMore;
    final hasMore = provider.hasMore;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis != Axis.vertical) return false;
        if (!hasMore || isLoadingMore) return false;
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
          context.read<ReceiveCoinsHistoryProvider>().loadMore();
        }
        return false;
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        slivers: [
          ...grouped.entries.expand((entry) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final tx = entry.value[index];
                  return _TransactionItem(transaction: tx);
                }, childCount: entry.value.length),
              ),
            ];
          }),
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, List<TransactionModel>> _groupTransactions(
    List<TransactionModel> transactions,
    AppLocalizations l10n,
  ) {
    final grouped = <String, List<TransactionModel>>{};
    for (var tx in transactions) {
      final key = _getDateLabel(tx.createdAt, l10n);
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    return grouped;
  }

  String _getDateLabel(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate.isAtSameMomentAs(today)) {
      return l10n.recently;
    }

    // Check if it's this month? Or just Month Year.
    // Design "July, 2024"
    return DateFormat('MMMM, yyyy', l10n.localeName).format(date);
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final coins = context.watch<CoinsPricesProvider>().coins;
    final matchingCoin = coins
        .where((c) => c.symbol == transaction.assetSymbol)
        .firstOrNull;
    final fallbackIcon = matchingCoin?.iconUrl ?? matchingCoin?.networkIconUrl;

    return ListTile(
      onTap: () {
        context.push(
          '${Routes.transactionDetail}?showType=true',
          extra: transaction,
        );
      },
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _getCoinColor(transaction.assetSymbol).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CommonCoinIcon(
            symbol: transaction.assetSymbol,
            radius: 20,
            iconBackgroundColor: _getCoinColor(transaction.assetSymbol),
            networkIconUrl:
                transaction.networkIconUrl ??
                transaction.assetIconUrl ??
                fallbackIcon,
          ),
        ),
      ),
      title: Text(
        transaction.assetSymbol,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        DateFormat(
          'yyyy-MM-dd h:mm a',
          AppLocalizations.of(context)!.localeName,
        ).format(transaction.createdAt.toLocal()),
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
      ),
      trailing: Text(
        '+${double.parse(transaction.amount).toStringAsFixed(5)} ${transaction.assetSymbol}',
        style: TextStyle(
          color: AppColors.greenColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCoinColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'USDT':
        return AppColors.usdtColor;
      case 'BTC':
        return AppColors.bitcoinColor;
      case 'ETH':
        return AppColors.textWhite;
      case 'SOL':
        return const Color(0xFF9945FF);
      default:
        return AppColors.primaryColor;
    }
  }
}
