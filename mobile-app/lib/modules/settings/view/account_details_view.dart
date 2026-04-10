import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/wallet_model/wallet_model.dart';
import '../../../core/theme/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/wallets_provider.dart';
import '../../../widgets/common_back_button.dart';
import '../providers/account_details_provider.dart';

class AccountDetailsView extends StatelessWidget {
  const AccountDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n!;
    final ThemeData theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth * 0.05;

    return ChangeNotifierProvider(
      create: (_) => AccountDetailsProvider(),
      child: Scaffold(
        appBar: AppBar(
          leading: CommonBackButton(onPressed: () => GoRouter.of(context).pop()),
          title: Text(
            l10n.accountDetails,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.state.user;
            final loc = context.l10n!;
            if (user == null) {
              return Center(child: Text(loc.accountNoUserDataAvailable));
            }

            final email = user.email ?? '';

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    context: context,
                    label: l10n.phoneNumber,
                    value: user.fullPhoneNumber,
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      context: context,
                      label: l10n.email,
                      value: email,
                    ),
                  ],
                  const SizedBox(height: 32),
                  _buildWalletsSection(context: context, l10n: l10n),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textLightGrey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                value,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletsSection({
    required BuildContext context,
    required AppLocalizations l10n,
  }) {
    final walletsProvider = context.watch<WalletsProvider>();
    final accountDetailsProvider = context.watch<AccountDetailsProvider>();
    final networks = walletsProvider.wallets;

    if (walletsProvider.isLoading && networks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (networks.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedIndex = accountDetailsProvider.selectedNetworkIndex
        .clamp(0, networks.length - 1);
    final selectedNetwork = networks[selectedIndex];

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.walletsAddress,
          style: TextStyle(
            color: AppColors.textLightGrey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        const SizedBox(height: 16),
        _buildNetworkTabs(
          context: context,
          networks: networks,
          selectedIndex: selectedIndex,
          onChanged: (index) =>
              context.read<AccountDetailsProvider>().selectNetwork(index),
        ),
        const SizedBox(height: 16),
        ...selectedNetwork.coins.map(
          (coin) => _buildCoinAddressRow(
            context: context,
            theme: theme,
            l10n: l10n,
            coin: coin,
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkTabs({
    required BuildContext context,
    required List<WalletNetworkModel> networks,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: networks.asMap().entries.map((entry) {
          final index = entry.key;
          final network = entry.value;
          final isSelected = index == selectedIndex;
          final displayText = network.networkDisplayName.isNotEmpty
              ? network.networkDisplayName
              : network.network;

          return GestureDetector(
            onTap: () => onChanged(index),
            child: Container(
              margin: const EdgeInsetsDirectional.only(end: 24),
              child: Column(
                children: [
                  Text(
                    displayText,
                    style: TextStyle(
                      color: isSelected ? textColor : AppColors.textLightGrey,
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    width: displayText.length * 10.0,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCoinAddressRow({
    required BuildContext context,
    required ThemeData theme,
    required AppLocalizations l10n,
    required WalletCoinModel coin,
  }) {
    final textColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final hasAddress = coin.address != null && coin.address!.isNotEmpty;
    final displayAddress =
        hasAddress ? coin.address! : l10n.walletAddressMasked;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${coin.name} (${coin.symbol})',
            style: TextStyle(
              color: AppColors.textLightGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(
                  displayAddress,
                  style: TextStyle(
                    color: hasAddress ? textColor : AppColors.textLightGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  Icons.copy,
                  size: 20,
                  color: hasAddress
                      ? textColor
                      : AppColors.textLightGrey.withValues(alpha: 0.4),
                ),
                onPressed: hasAddress
                    ? () {
                        Clipboard.setData(
                          ClipboardData(text: coin.address!),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.addressCopiedToast),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
