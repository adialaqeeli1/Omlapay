import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/utility.dart';
import '../../../../providers/kyc_status_provider.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_coin_icon.dart';
import '../../../../widgets/common_loading_indicator.dart';
import '../../../../widgets/copied_toast.dart';
import '../../../kyc_verification/utils/kyc_verification_entry_source.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/kyc_verification_gate.dart';
import '../../../../core/models/wallet_model/wallet_model.dart';
import '../provider/receive_coin_provider.dart';

class ReceiveCoinView extends StatelessWidget {
  const ReceiveCoinView({super.key, this.fromReceive = false});

  final bool fromReceive;
  static const String _maskedAddress = 'XXXX XXXX XXXX';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReciveCoinProvider>();
    final kycProvider = context.watch<KycStatusProvider>();
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    final title = fromReceive ? l10n.receive : l10n.walletsTitle;
    final showVerificationBanner =
        provider.kycRequired || kycProvider.showBanner;

    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: context.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        leading: const CommonBackButton(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, size: 24),
            onPressed: () => context.push(Routes.receiveCoinsHistory),
            tooltip: l10n.history,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Text(
                  l10n.yourWalletsTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: provider.wallets.isEmpty && provider.isLoading
                    ? Center(child: CommonLoadingIndicator())
                    : _buildWalletsList(
                        context,
                        provider,
                        showVerificationBanner,
                      ),
              ),
              // KYC gate — blocks the screen until verification is complete.
              KycVerificationGate(
                entrySource: KycVerificationEntrySource.receive,
                forceShow: provider.kycRequired,
              ),
            ],
          ),

          // Loading overlay during refresh (when wallets already loaded)
          if (provider.isLoading && provider.wallets.isNotEmpty)
            Positioned.fill(
              child: ColoredBox(
                color: colorScheme.surface.withValues(alpha: 0.6),
                child: Center(child: CommonLoadingIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  /// [BackdropFilter] requires a non-trivial blur on some Flutter versions; when
  /// KYC is not required, skip it and show the list normally.
  Widget _buildWalletsList(
    BuildContext context,
    ReciveCoinProvider provider,
    bool showVerificationBanner,
  ) {
    final items = <({WalletNetworkModel wallet, WalletCoinModel coin})>[
      for (final wallet in provider.wallets)
        for (final coin in wallet.coins) (wallet: wallet, coin: coin),
    ];

    final listView = ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildWalletItem(
          context,
          item.wallet,
          item.coin,
          provider,
          showVerificationBanner,
        );
      },
    );

    if (!showVerificationBanner) {
      return listView;
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: showVerificationBanner ? 5 : 0,
          sigmaY: showVerificationBanner ? 5 : 0,
        ),
        child: Opacity(
          opacity: showVerificationBanner ? 0.55 : 1,
          child: listView,
        ),
      ),
    );
  }

  Widget _buildWalletItem(
    BuildContext context,
    WalletNetworkModel wallet,
    WalletCoinModel coin,
    ReciveCoinProvider provider,
    bool showVerificationBanner,
  ) {
    final hasAddress = _hasValidAddress(coin.address);
    final canUseActions = !showVerificationBanner && hasAddress;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final networkLabel = wallet.networkDisplayName.isNotEmpty
        ? wallet.networkDisplayName
        : wallet.network;
    final upperSymbol = coin.symbol.trim().toUpperCase();
    final preferSymbol = upperSymbol == 'SOL' || upperSymbol == 'USDT';
    final coinName = preferSymbol
        ? (coin.symbol.isNotEmpty ? coin.symbol : coin.name)
        : (coin.name.isNotEmpty ? coin.name : coin.symbol);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Network icon
          _buildWalletIcon(context, wallet, coin),
          const SizedBox(width: 12),

          // Coin info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coinName,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  networkLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _displayAddress(coin.address),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // QR Code button
          _buildIconButton(
            context,
            assetPath: 'assets/icons/qr-icon.svg',
            onTap: canUseActions
                ? () {
                    context.push(
                      Routes.qrCode,
                      extra: wallet.copyWith(coins: [coin]),
                    );
                  }
                : null,
          ),
          const SizedBox(width: 8),

          // Copy button
          _buildIconButton(
            context,
            icon: Icons.copy_rounded,
            onTap: canUseActions
                ? () => CopiedToast.copy(context, coin.address ?? '')
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletIcon(
    BuildContext context,
    WalletNetworkModel wallet,
    WalletCoinModel coin,
  ) {
    const tintColor = AppColors.tealColor;
    final network = wallet.network.trim().toUpperCase();
    final coinSymbol = coin.symbol.trim().toUpperCase();
    final useCoinIcon = coinSymbol == 'USDT' || coinSymbol == 'USDC';
    final iconUrl = useCoinIcon
        ? Utility.getCryptoCoinIconFromSymbol(coinSymbol)
        : wallet.networkIconUrl.trim();

    // Network → fallback SVG when the remote icon URL fails to load.
    final fallbackAsset = switch (network) {
      'TRX' => 'assets/icons/tron.svg',
      'BTC' => 'assets/icons/bitcoin.svg',
      'ETH' => 'assets/icons/evm.svg',
      'BNB' => 'assets/icons/evm.svg',
      'SOL' => 'assets/icons/solana.svg',
      _ => 'assets/icons/bitcoin.svg',
    };

    // For non-USDT/USDC rows the icon represents the network, so the
    // ETH light-mode brand-blue ring should kick in when network == ETH.
    // For USDT/USDC the icon represents the coin, so pass the coin
    // symbol — neither is `ETH`, so the fix stays inactive.
    final effectiveSymbol = useCoinIcon ? coinSymbol : network;

    return CommonCoinIcon(
      symbol: effectiveSymbol,
      radius: 15,
      networkIconUrl: iconUrl.isEmpty ? null : iconUrl,
      fallbackIcon: SvgPicture.asset(
        fallbackAsset,
        colorFilter: const ColorFilter.mode(tintColor, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    IconData? icon,
    String? assetPath,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: iconColor, size: 18)
              : SvgPicture.asset(
                  assetPath!,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
        ),
      ),
    );
  }

  String _displayAddress(String? address) {
    if (!_hasValidAddress(address)) return _maskedAddress;
    return _truncateAddress(address!.trim());
  }

  bool _hasValidAddress(String? address) {
    if (address == null) return false;
    final normalized = address.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'null' &&
        normalized != 'undefined';
  }

  String _truncateAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 12)}...${address.substring(address.length - 6)}';
  }

  // ignore: unused_element
  void _showCoinSelectionForCopy(
    BuildContext context, {
    required WalletNetworkModel wallet,
    required ReciveCoinProvider provider,
  }) {
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: IconButton(
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    l10n.selectCoinTitle,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: wallet.coins.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final coin = wallet.coins[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CommonCoinIcon(
                        symbol: coin.symbol,
                        networkIconUrl: coin.networkIconUrl,
                      ),
                      title: Text(
                        coin.name,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        coin.symbol,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      onTap: () {
                        CopiedToast.copy(context, coin.address ?? '');
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
