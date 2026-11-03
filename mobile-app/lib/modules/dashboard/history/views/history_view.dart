import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../providers/coins_prices_provider.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/common_loading_indicator.dart';
import '../../../../widgets/no_transactions_found.dart';
import '../providers/history_provider.dart';
import '../widgets/history_filter_bottom_sheet.dart';
import '../widgets/transaction_item.dart';
import '../widgets/transaction_section_header.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HistoryProvider(context.read<CoinsPricesProvider>()),
      child: const _HistoryViewBody(),
    );
  }
}

class _HistoryViewBody extends StatefulWidget {
  const _HistoryViewBody();

  @override
  State<_HistoryViewBody> createState() => _HistoryViewBodyState();
}

class _HistoryViewBodyState extends State<_HistoryViewBody>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = context.read<HistoryProvider>().uniqueCoinSymbols;
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (!mounted) return;
    final coin = _tabs[_tabController.index];
    context.read<HistoryProvider>().setCoinFilter(
      coin == HistoryProvider.allCoinsTab ? null : coin,
    );
  }

  /// Rebuilds the [TabController] when the SSE coin list changes at runtime,
  /// preserving the currently selected coin where possible.
  void _syncTabsIfNeeded(List<String> newTabs) {
    if (_tabsEqual(_tabs, newTabs)) return;
    final currentCoin = _tabs.isNotEmpty && _tabController.index < _tabs.length
        ? _tabs[_tabController.index]
        : HistoryProvider.allCoinsTab;
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
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<HistoryProvider>();
    _syncTabsIfNeeded(provider.uniqueCoinSymbols);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: const CommonBackButton(),
        title: Text(
          l10n.transactionHistory,
          style: theme.textTheme.titleMedium?.copyWith(
            color: context.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/filter-icon.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                theme.brightness == Brightness.dark
                    ? AppColors.white
                    : AppColors.textBlack,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              final historyProvider = context.read<HistoryProvider>();
              HistoryFilterBottomSheet.show(
                context,
                selectedType: historyProvider.selectedTypeFilter,
                dateStart: historyProvider.dateStart,
                dateEnd: historyProvider.dateEnd,
                onApply: ({type, dateStart, dateEnd}) {
                  historyProvider.setTypeFilter(type);
                  historyProvider.setDateRange(dateStart, dateEnd);
                },
              );
            },
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
          tabs: _tabs
              .map(
                (e) =>
                    Tab(text: e == HistoryProvider.allCoinsTab ? l10n.all : e),
              )
              .toList(),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: _tabs.map((_) => const _HistoryTransactionList()).toList(),
        ),
      ),
    );
  }
}

/// One page of the [TabBarView] — the date-grouped transaction list with
/// pull-to-refresh and infinite-scroll pagination. Every page reads the same
/// [HistoryProvider], so all pages render the active coin filter's data.
class _HistoryTransactionList extends StatelessWidget {
  const _HistoryTransactionList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final horizontalPadding = context.width * 0.05;

    if (provider.isLoading && provider.transactions.isEmpty) {
      return const Center(child: CommonLoadingIndicator());
    }

    if (provider.transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.refresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const Center(child: NoTransactionsFound()),
            ),
          ),
        ),
      );
    }

    final groupedTransactions = _groupTransactionsByDate(provider.transactions);
    final isLoadingMore = provider.isLoadingMore;
    final hasMore = provider.hasMore;

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis != Axis.vertical) return false;
          if (!hasMore || isLoadingMore) return false;
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            provider.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          itemCount: groupedTransactions.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == groupedTransactions.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CommonLoadingIndicator()),
              );
            }
            final group = groupedTransactions[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TransactionSectionHeader(
                  date: group['date'] as DateTime,
                  isFirst: index == 0,
                ),
                ...(group['transactions'] as List<TransactionModel>).map(
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
    );
  }

  List<Map<String, dynamic>> _groupTransactionsByDate(
    List<TransactionModel> transactions,
  ) {
    // Sort transactions by date (newest first)
    final sorted = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Separate recent transactions (today/yesterday) from older ones
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

    // Add "Recently" section if there are recent transactions
    if (recentTransactions.isNotEmpty) {
      result.add({
        'date': today, // Use today's date for "Recently" section
        'transactions': recentTransactions,
        'isRecently': true,
      });
    }

    // Add older transactions grouped by month
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
