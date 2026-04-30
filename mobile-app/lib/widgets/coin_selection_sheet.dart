import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/extentions/context_extensions.dart';
import '../core/models/coin_model/coin_model.dart';
import '../core/models/coin_model/coin_model_quote_display.dart';
import '../core/theme/theme.dart';
import '../providers/global_provider.dart';
import '../providers/wallets_provider.dart';
import 'common_coin_icon.dart';

class CoinSelectionSheet extends StatefulWidget {
  final String title;
  final List<CoinModel> coins;
  final CoinModel? selectedCoin;
  final ValueChanged<CoinModel> onCoinSelected;

  const CoinSelectionSheet({
    super.key,
    required this.title,
    required this.coins,
    this.selectedCoin,
    required this.onCoinSelected,
  });

  @override
  State<CoinSelectionSheet> createState() => _CoinSelectionSheetState();
}

class _CoinSelectionSheetState extends State<CoinSelectionSheet> {
  late List<CoinModel> _filteredCoins;
  final TextEditingController _searchController = TextEditingController();
  bool _hideZeroBalance = false;

  @override
  void initState() {
    super.initState();
    _filteredCoins = widget.coins;
    _searchController.addListener(_filterCoins);
  }

  @override
  void didUpdateWidget(CoinSelectionSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coins != widget.coins) {
      _filterCoins();
    }
  }

  void _filterCoins() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCoins = widget.coins.where((coin) {
        // Search filter
        final localizedPrimaryName = coin
            .localizedCoinPrimaryName(context)
            .toLowerCase();
        final arLabel = coin.coinSymbolAr?.toLowerCase() ?? '';
        final matchesSearch =
            coin.name.toLowerCase().contains(query) ||
            localizedPrimaryName.contains(query) ||
            coin.symbol.toLowerCase().contains(query) ||
            (arLabel.isNotEmpty && arLabel.contains(query));

        // Balance filter
        if (_hideZeroBalance) {
          final walletBalance = context.read<WalletsProvider>().balanceForCoin(
            coin.symbol,
          );
          final amountStr = walletBalance.replaceAll(',', '');
          final amount = double.tryParse(amountStr) ?? 0.0;
          return matchesSearch && amount > 0;
        }

        return matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _coinBalance(WalletsProvider walletsProvider, CoinModel coin) {
    final raw = walletsProvider.balanceForCoin(coin.symbol).replaceAll(',', '');
    return double.tryParse(raw) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCurrency = context.watch<GlobalProvider>().selectedCurrency;
    final walletsProvider = context.watch<WalletsProvider>();
    final sortedCoins = [..._filteredCoins]..sort(
      (a, b) => _coinBalance(
        walletsProvider,
        b,
      ).compareTo(_coinBalance(walletsProvider, a)),
    );
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: _hideZeroBalance,
                    activeColor: AppColors.tealColor,
                    checkColor: Colors.white,
                    side: BorderSide(color: colorScheme.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _hideZeroBalance = value ?? false;
                        _filterCoins();
                      });
                    },
                  ),
                ),
                Text(
                  l10n.hideZeroBalance,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: sortedCoins.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final coin = sortedCoins[index];
                final isSelected = coin == widget.selectedCoin;
                final theme = context.theme;
                final itemColorScheme = theme.colorScheme;
                Color? iconBackgroundColor;
                Widget? fallbackIcon;

                final bool hasPrice =
                    (double.tryParse(
                          walletsProvider.balanceForCoinConverted(coin.symbol),
                        ) ??
                        0) >
                    0;

                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: isSelected
                        ? Border.all(color: AppColors.tealColor)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CommonCoinIcon(
                      symbol: coin.symbol,
                      iconBackgroundColor: iconBackgroundColor,
                      fallbackIcon: fallbackIcon,
                      networkIconUrl: coin.networkIconUrl,
                    ),
                    title: Text(
                      coin.localizedCoinPrimaryName(context),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: itemColorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      coin.localizedCoinTicker(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: itemColorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          walletsProvider.balanceForCoin(coin.symbol),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: hasPrice
                                ? itemColorScheme.onSurface
                                : AppColors.redColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasPrice)
                          Text(
                            '≈ ${walletsProvider.balanceForCoinConverted(coin.symbol)} ${coin.quoteCurrencyLabel(context, selectedCurrency)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: itemColorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      widget.onCoinSelected(coin);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
