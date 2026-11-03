import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/wallets_provider.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/copied_toast.dart';

class AccountDetailsView extends StatelessWidget {
  const AccountDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n!;
    final ThemeData theme = context.theme;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth * 0.05;

    return Scaffold(
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

          final hasWallets = user.walletsAvailable;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 24, bottom: 32),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          spacing: 24,
                          children: [
                            _buildInfoSection(
                              context: context,
                              label: l10n.phoneNumber,
                              value: user.fullPhoneNumber,
                            ),
                            if (email.isNotEmpty)
                              _buildInfoSection(
                                context: context,
                                label: l10n.email,
                                value: email,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (hasWallets)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _WalletsSection(l10n: l10n),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final theme = context.theme;
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
}

class _WalletsSection extends StatefulWidget {
  const _WalletsSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_WalletsSection> createState() => _WalletsSectionState();
}

class _WalletsSectionState extends State<_WalletsSection>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _networkCount = 0;

  void _syncTabController(int count) {
    if (count == _networkCount && _tabController != null) return;
    _tabController?.dispose();
    _networkCount = count;
    if (count > 0) {
      _tabController = TabController(length: count, vsync: this);
    } else {
      _tabController = null;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletsProvider = context.watch<WalletsProvider>();
    final networks = walletsProvider.wallets;

    if (walletsProvider.isLoading && networks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (networks.isEmpty) {
      return const SizedBox.shrink();
    }

    _syncTabController(networks.length);
    final tabController = _tabController!;

    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;

    return SizedBox(
      height: context.height - (context.height / 2),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Text(
            widget.l10n.walletsAddress,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textLightGrey,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textLightGrey,
            labelStyle: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
            unselectedLabelStyle: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textLightGrey,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
            indicatorColor: AppColors.primaryColor,
            indicatorWeight: 2,
            dividerHeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: networks.map((network) {
              final displayText = network.networkDisplayName.isNotEmpty
                  ? network.networkDisplayName
                  : network.network;
              return Tab(text: displayText);
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: networks.map((network) {
                if (network.coins.isEmpty) {
                  return const SizedBox.shrink();
                }
                final coin = network.coins.first;
                final hasAddress =
                    coin.address != null && coin.address!.isNotEmpty;
                final displayAddress = hasAddress
                    ? coin.address!
                    : widget.l10n.walletAddressMasked;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: .min,
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
                      spacing: 12,
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: Text(
                            displayAddress,
                            style: TextStyle(
                              color: hasAddress
                                  ? textColor
                                  : AppColors.textLightGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 16.0),
                          child: InkWell(
                            onTap: hasAddress
                                ? () => CopiedToast.copy(context, coin.address!)
                                : null,
                            child: Icon(
                              Icons.copy,
                              size: 20,
                              color: hasAddress
                                  ? textColor
                                  : AppColors.textLightGrey.withValues(
                                      alpha: 0.4,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
