import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../routes/app_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common_back_button.dart';
import '../provider/wallets_provider.dart';

class WalletsView extends StatelessWidget {
  const WalletsView({super.key, this.fromReceive = false});

  final bool fromReceive;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    final title = fromReceive ? l10n.receive : 'Wallets';
    final showVerificationBanner = authProvider.state.user?.isVerified != true;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CommonBackButton(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () => context.push(Routes.receiveCoin),
            tooltip: l10n.history,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Text(
                  'Your wallets',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.tealColor,
                        ),
                      )
                    : Stack(
                        children: [
                          ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Opacity(
                                opacity: 0.55,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  itemCount: provider.wallets.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final wallet = provider.wallets[index];
                                    return _buildWalletItem(
                                      context,
                                      wallet,
                                      provider,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Dark overlay so list feels partially hidden
                          IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.15),
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              if (showVerificationBanner)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: _buildVerificationBanner(context, authProvider),
                ),
            ],
          ),

          // Copied message overlay
          if (provider.copiedMessage != null)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.tealColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.tealColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.copiedMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerificationBanner(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3F1519),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B252C)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Identity verification is required to receive coins. Please complete your KYC profile to enable transfers. ',
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      // onTap: () async {
                      //   final result = await context.push(
                      //     Routes.sendVerification,
                      //   );
                      //   if (result == true) {
                      //     // ignore: use_build_context_synchronously
                      //     await authProvider.verifyUser();
                      //   }
                      // },
                      child: const Text(
                        'Verify Now',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletItem(
    BuildContext context,
    wallet,
    WalletsProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Wallet Icon
          _buildWalletIcon(wallet.symbol),
          const SizedBox(width: 12),

          // Wallet info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _truncateAddress(wallet.address),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // QR Code button
          _buildIconButton(
            assetPath: 'assets/icons/qr-icon.svg',
            onTap: () {
              context.push(Routes.qrCode, extra: wallet);
            },
          ),
          const SizedBox(width: 8),

          // Copy button
          _buildIconButton(
            icon: Icons.copy_rounded,
            onTap: () {
              Clipboard.setData(ClipboardData(text: wallet.address));
              provider.copyAddress(wallet.address);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWalletIcon(String symbol) {
    String assetPath;
    Color backgroundColor;

    switch (symbol) {
      case 'TRX':
        assetPath = 'assets/icons/tron.svg';
        backgroundColor = const Color(0xFF26A69A);
        break;
      case 'BTC':
        assetPath = 'assets/icons/bitcoin.svg';
        backgroundColor = const Color(0xFF26A69A);
        break;
      case 'ETH':
        assetPath = 'assets/icons/evm.svg';
        backgroundColor = const Color(0xFF26A69A);
        break;
      case 'SOL':
        assetPath = 'assets/icons/solana.svg';
        backgroundColor = const Color(0xFF26A69A);
        break;
      default:
        assetPath = 'assets/icons/bitcoin.svg';
        backgroundColor = const Color(0xFF26A69A);
    }

    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SvgPicture.asset(
        assetPath,
        colorFilter: ColorFilter.mode(backgroundColor, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildIconButton({
    IconData? icon,
    String? assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 18)
              : SvgPicture.asset(
                  assetPath!,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
        ),
      ),
    );
  }

  String _truncateAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 12)}...${address.substring(address.length - 6)}';
  }
}
