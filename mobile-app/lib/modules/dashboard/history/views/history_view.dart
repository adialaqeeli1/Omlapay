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
import '../widgets/coin_filter_tabs.dart';
import '../widgets/history_filter_bottom_sheet.dart';
import '../widgets/transaction_item.dart';
import '../widgets/transaction_section_header.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final screenWidth = context.width;
    final horizontalPadding = screenWidth * 0.05;

    return ChangeNotifierProvider(
      create: (context) => HistoryProvider(context.read<CoinsPricesProvider>()),
      child: Builder(
        builder: (providerContext) => Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            leading: const CommonBackButton(),
            title: Text(
              l10n.transactionHistory,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.white
                    : AppColors.textBlack,
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
                  final provider = providerContext.read<HistoryProvider>();
                  HistoryFilterBottomSheet.show(
                    providerContext,
                    selectedType: provider.selectedTypeFilter,
                    dateStart: provider.dateStart,
                    dateEnd: provider.dateEnd,
                    onApply: ({type, dateStart, dateEnd}) {
                      provider.setTypeFilter(type);
                      provider.setDateRange(dateStart, dateEnd);
                    },
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Consumer<HistoryProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    CoinFilterTabs(
                      selectedCoin: provider.selectedCoinFilter,
                      onCoinSelected: (coin) {
                        provider.setCoinFilter(coin);
                      },
                    ),
                    Expanded(
                      child: _buildHistoryBody(
                        context,
                        provider: provider,
                        horizontalPadding: horizontalPadding,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryBody(
    BuildContext context, {
    required HistoryProvider provider,
    required double horizontalPadding,
  }) {
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
