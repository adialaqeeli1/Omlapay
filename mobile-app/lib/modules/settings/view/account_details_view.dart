import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common_back_button.dart';
// import '../../../widgets/theme_aware_icon.dart';
// import '../../../widgets/theme_aware_icon.dart';
import '../services/wallet_address_service.dart';

class AccountDetailsView extends StatefulWidget {
  const AccountDetailsView({super.key});

  @override
  State<AccountDetailsView> createState() => _AccountDetailsViewState();
}

class _AccountDetailsViewState extends State<AccountDetailsView> {
  String _selectedWalletType = 'EVM';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n!;
    final ThemeData theme = Theme.of(context);
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

          final email = WalletAddressService.getUserEmail(user);
          final walletAddresses = WalletAddressService.getWalletAddresses(user);
          final currentAddress = walletAddresses[_selectedWalletType] ?? '';

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
                  onEdit: () {
                    // TODO: Navigate to change phone number
                  },
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    context: context,
                    label: l10n.email,
                    value: email,
                    onEdit: () {
                      // TODO: Navigate to change email
                    },
                  ),
                ],
                const SizedBox(height: 32),
                _buildWalletsSection(
                  context: context,
                  l10n: l10n,
                  walletAddresses: walletAddresses,
                  currentAddress: currentAddress,
                  selectedType: _selectedWalletType,
                  onTypeChanged: (type) {
                    setState(() {
                      _selectedWalletType = type;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onEdit,
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
            // IconButton(
            //   icon: ThemeAwareIcon(assetPath: 'assets/icons/edit.svg'),
            //   onPressed: onEdit,
            //   padding: EdgeInsets.zero,
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletsSection({
    required BuildContext context,
    required AppLocalizations l10n,
    required Map<String, String> walletAddresses,
    required String currentAddress,
    required String selectedType,
    required ValueChanged<String> onTypeChanged,
  }) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;

    final walletTypes = ['EVM', 'Bitcoin', 'Tron', 'Solana'];

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
        _buildWalletTypeTabs(
          context: context,
          l10n: l10n,
          types: walletTypes,
          selectedType: selectedType,
          onTypeChanged: onTypeChanged,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableText(
                currentAddress,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(Icons.copy, size: 20, color: textColor),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: currentAddress));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.copyLabelValue(l10n.copy, currentAddress),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletTypeTabs({
    required BuildContext context,
    required AppLocalizations l10n,
    required List<String> types,
    required String selectedType,
    required ValueChanged<String> onTypeChanged,
  }) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((type) {
          final isSelected = type == selectedType;
          String displayText;
          switch (type) {
            case 'EVM':
              displayText = l10n.evm;
              break;
            case 'Bitcoin':
              displayText = l10n.bitcoin;
              break;
            case 'Tron':
              displayText = l10n.tron;
              break;
            case 'Solana':
              displayText = l10n.solana;
              break;
            default:
              displayText = type;
          }

          return GestureDetector(
            onTap: () => onTypeChanged(type),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              child: Column(
                children: [
                  Text(
                    displayText,
                    style: TextStyle(
                      color: isSelected ? textColor : AppColors.textLightGrey,
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
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
}
