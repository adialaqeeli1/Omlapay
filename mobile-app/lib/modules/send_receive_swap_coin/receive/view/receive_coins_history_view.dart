import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../kyc_verification/utils/kyc_verification_entry_source.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/kyc_verification_required_banner.dart';
import 'package:intl/intl.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_coin_icon.dart';
import '../../../../widgets/no_transactions_found.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../widgets/theme_aware_icon.dart';
import '../provider/receive_coins_history_provider.dart';

class ReceiveCoinsHistoryView extends StatelessWidget {
  const ReceiveCoinsHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<ReceiveCoinsHistoryProvider>();
    final tabs = provider.uniqueCoinSymbols;

    final theme = context.theme;

    if (provider.isLoading) {
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
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
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
            isScrollable: tabs.length > 4,
            tabAlignment: tabs.length > 4
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
            tabs: tabs.map((e) => Tab(text: e)).toList(),
          ),
        ),
        body: Column(
          children: [
            if (provider.showVerificationWarning)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: KycVerificationRequiredBanner(
                  messageBody: l10n.receiveKycVerificationRequiredBody,
                  entrySource: KycVerificationEntrySource.receiveHistory,
                ),
              ),
            Expanded(
              child: TabBarView(
                // physics: const NeverScrollableScrollPhysics(),
                children: tabs
                    .map((e) => _TransactionList(coinSymbol: e))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final String coinSymbol;

  const _TransactionList({required this.coinSymbol});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReceiveCoinsHistoryProvider>();
    // Note: getTransactionsForCoin is not reactive if we don't watch the list,
    // but we watched the provider globally in parent.
    // However, clean logic is to watch here or select data.
    // Provider notifyListeners() rebuilds consumers.
    // Since we are inside Consumer (via watch above), it rebuilds this widget.

    final List<TransactionModel> transactions = provider.getTransactionsForCoin(
      coinSymbol,
    );

    if (transactions.isEmpty) {
      return const Center(child: NoTransactionsFound());
    }

    final l10n = AppLocalizations.of(context)!;
    final grouped = _groupTransactions(transactions, l10n);

    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      slivers: grouped.entries.expand((entry) {
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
      }).toList(),
    );
  }

  Map<String, List<TransactionModel>> _groupTransactions(
    List<TransactionModel> transactions,
    AppLocalizations l10n,
  ) {
    final grouped = <String, List<TransactionModel>>{};
    for (var tx in transactions) {
      final key = _getDateLabel(tx.date, l10n);
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
    Color? iconBackgroundColor;
    Widget? fallbackIcon;

    if (transaction.coinSymbol == 'USDT') {
      iconBackgroundColor = AppColors.usdtColor;
      fallbackIcon = DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.usdtColor,
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(CryptoFontIcons.USDT, color: Colors.white, size: 24),
        ),
      );
    } else if (transaction.coinSymbol == 'ETH') {
      iconBackgroundColor = AppColors.textWhite;
      fallbackIcon = DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.textWhite,
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(CryptoFontIcons.ETH, color: Colors.black, size: 24),
        ),
      );
    } else if (transaction.coinSymbol == 'BTC') {
      iconBackgroundColor = AppColors.bitcoinColor;
      fallbackIcon = DecoratedBox(
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

    return ListTile(
      onTap: () {
        context.pushNamed('transactionDetails', extra: transaction);
      },
      leading: CommonCoinIcon(
        symbol: transaction.coinSymbol,
        iconBackgroundColor: iconBackgroundColor,
        fallbackIcon: fallbackIcon,
      ),
      title: Text(
        transaction.coinSymbol,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        DateFormat(
          'yyyy-MM-dd HH:mm:ss',
          AppLocalizations.of(context)!.localeName,
        ).format(transaction.date),
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
      ),
      trailing: Text(
        '+${double.parse(transaction.amount).toStringAsFixed(2)} ${transaction.coinSymbol}',
        style: TextStyle(
          color: AppColors.greenColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
