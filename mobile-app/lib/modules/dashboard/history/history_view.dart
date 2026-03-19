import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/extentions/context_extensions.dart';
import '../../../core/models/transaction_model/transaction_model.dart';
import '../../../core/theme/theme.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/common_loading_indicator.dart';
import 'providers/history_provider.dart';
import 'widgets/coin_filter_tabs.dart';
import 'widgets/transaction_item.dart';
import 'widgets/transaction_section_header.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final screenWidth = context.width;
    final horizontalPadding = screenWidth * 0.05;

    return ChangeNotifierProvider(
      create: (_) => HistoryProvider(),
      child: Scaffold(
        appBar: AppBar(
          leading: context.canPop()
              ? CommonBackButton(onPressed: () => GoRouter.of(context).pop())
              : null,
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
                // TODO: Open filter bottom sheet for transaction type (Sent/Received/Swap)
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<HistoryProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CommonLoadingIndicator());
              }

              if (provider.transactions.isEmpty) {
                return Center(
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      -MediaQuery.of(context).size.height * 0.1,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          theme.brightness == Brightness.dark
                              ? 'assets/icons/empty-state-dark.svg'
                              : 'assets/icons/empty-state.svg',
                          width: 250,
                          height: 200,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Text(
                          l10n.noTransactionsFound,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? AppColors.textWhite
                                : AppColors.textBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Text(
                          l10n.allIncomingTransactionsListed,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLightGrey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Group transactions by date
              final groupedTransactions = _groupTransactionsByDate(
                provider.transactions,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spacing after heading
                  const SizedBox(height: 16),
                  // Coin Filter Tabs
                  CoinFilterTabs(
                    selectedCoin: provider.selectedCoinFilter,
                    onCoinSelected: (coin) {
                      provider.setCoinFilter(coin);
                    },
                  ),
                  // Transactions List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      itemCount: groupedTransactions.length,
                      itemBuilder: (context, index) {
                        final group = groupedTransactions[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TransactionSectionHeader(
                              date: group['date'] as DateTime,
                              isFirst: index == 0,
                            ),
                            ...(group['transactions'] as List<TransactionModel>)
                                .map(
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupTransactionsByDate(
    List<TransactionModel> transactions,
  ) {
    // Sort transactions by date (newest first)
    final sorted = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Separate recent transactions (today/yesterday) from older ones
    final recentTransactions = <TransactionModel>[];
    final olderTransactions = <DateTime, List<TransactionModel>>{};

    for (final tx in sorted) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (txDate == today || txDate == yesterday) {
        recentTransactions.add(tx);
      } else {
        final monthKey = DateTime(tx.date.year, tx.date.month);
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
