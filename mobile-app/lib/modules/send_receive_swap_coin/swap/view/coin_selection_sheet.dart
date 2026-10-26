import 'package:flutter/material.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_coin_icon.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';

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

  void _filterCoins() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCoins = widget.coins.where((coin) {
        // Search filter
        final matchesSearch =
            coin.name.toLowerCase().contains(query) ||
            coin.symbol.toLowerCase().contains(query);

        // Balance filter
        if (_hideZeroBalance) {
          final amountStr = coin.amount.replaceAll(',', '');
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.only(
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
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
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
                    side: const BorderSide(color: Colors.grey),
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
                const Text(
                  'Hide zero balance',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredCoins.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final coin = _filteredCoins[index];
                final isSelected = coin == widget.selectedCoin;
                Color? iconBackgroundColor;
                Widget? fallbackIcon;

                if (coin.symbol == 'USDT') {
                  iconBackgroundColor = AppColors.usdtColor;
                  fallbackIcon = const Icon(
                    CryptoFontIcons.USDT,
                    color: Colors.white,
                    size: 24,
                  );
                } else if (coin.symbol == 'ETH') {
                  iconBackgroundColor = AppColors.textWhite;
                  fallbackIcon = const Icon(
                    CryptoFontIcons.ETH,
                    color: Colors.black,
                    size: 24,
                  );
                } else if (coin.symbol == 'BTC') {
                  iconBackgroundColor = AppColors.bitcoinColor;
                  fallbackIcon = const Icon(
                    CryptoFontIcons.BTC,
                    color: Colors.white,
                    size: 24,
                  );
                }

                return Container(
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
                    ),
                    title: Text(
                      coin.symbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      coin.name,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          coin.amount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${coin.valueInUsd}',
                          style: TextStyle(
                            color: Colors.grey[600],
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
