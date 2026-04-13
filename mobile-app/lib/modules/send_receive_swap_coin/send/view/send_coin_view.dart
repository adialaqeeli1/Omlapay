import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/utility.dart';
import '../../../../routes/app_router.dart';
import '../../../../providers/kyc_status_provider.dart';
import '../../../kyc_verification/utils/kyc_verification_entry_source.dart';
import '../../../scan/view/qr_scanner_view.dart';
import '../../../../widgets/permission_dialog.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/common_coin_icon.dart';
import '../../../../widgets/kyc_verification_required_banner.dart';
import '../../../../widgets/coin_selection_sheet.dart';
import '../provider/send_provider.dart';
import '../widgets/contact_selection_sheet.dart';

class SendCoinView extends StatelessWidget {
  const SendCoinView({super.key});

  static const double _fieldRadius = 12;

  /// Light: white fill + #666 stroke. Dark: elevated surface + outline variant.
  BoxDecoration _sendFieldBoxDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (context.isDarkMode) {
      return BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(_fieldRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      );
    }
    return BoxDecoration(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(_fieldRadius),
      border: Border.all(color: AppColors.sendFormFieldBorderLight),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SendProvider>();
    final kycProvider = context.watch<KycStatusProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.sendFlowSendingTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: context.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        leading: const CommonBackButton(),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(context, l10n.sendFormCoinLabel),
                  const SizedBox(height: 8),
                  _buildCoinSelector(context, provider),
                  const SizedBox(height: 20),

                  _buildLabel(context, l10n.network),
                  const SizedBox(height: 8),
                  _buildNetworkField(context, provider),
                  const SizedBox(height: 20),

                  _buildLabel(context, l10n.sendFormPhoneOrAddressLabel),
                  const SizedBox(height: 8),
                  _buildRecipientField(context, provider),
                  const SizedBox(height: 20),

                  _buildLabel(context, l10n.sendFormAmountLabel),
                  const SizedBox(height: 8),
                  _buildAmountField(context, provider),

                  // Available Balance
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.availableShortLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${provider.selectedCoin?.amount ?? '0'} ${provider.selectedCoin?.localizedCoinTicker(context) ?? ''}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  // Verification Warning
                  if (kycProvider.showBanner) ...[
                    const SizedBox(height: 30),
                    KycVerificationRequiredBanner(
                      kycStatus: kycProvider.kycStatus,
                      entrySource: KycVerificationEntrySource.send,
                      rejectionReason: kycProvider.rejectionReason,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Footer
          _buildFooter(context, provider, l10n),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        color: context.isDarkMode ? colorScheme.onSurface : AppColors.textGrey,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCoinSelector(BuildContext context, SendProvider provider) {
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    final coin = provider.selectedCoin;
    return GestureDetector(
      onTap: () => _showCoinSelection(context, provider),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _sendFieldBoxDecoration(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (coin != null) ...[
                  CommonCoinIcon(
                    symbol: coin.symbol,
                    iconBackgroundColor: _getCoinColor(coin.symbol),
                    radius: 20,
                    networkIconUrl: coin.networkIconUrl,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.localizedCoinPrimaryName(context),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        coin.localizedCoinTicker(context),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Text(
                    l10n.selectCoinTitle,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkField(BuildContext context, SendProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: _sendFieldBoxDecoration(context),
      child: TextField(
        controller: provider.networkController,
        readOnly: true,
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildRecipientField(BuildContext context, SendProvider provider) {
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: _sendFieldBoxDecoration(context),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: provider.recipientController,
              style: TextStyle(color: colorScheme.onSurface),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: l10n.pasteHintLongPress,
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          // Icons
          Row(
            children: [
              _buildIconButton(
                context,
                icon: Icons.person_outline,
                onTap: () => _showContactSelection(context, provider),
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                context,
                svgPath: 'assets/icons/scan-icon.svg',
                onTap: () => _openQrScanner(context, provider),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    IconData? icon,
    String? svgPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.iconBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: icon != null
            ? Icon(icon, color: AppColors.white, size: 20)
            : SvgPicture.asset(
                svgPath!,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
                width: 20,
                height: 20,
              ),
      ),
    );
  }

  Widget _buildAmountField(BuildContext context, SendProvider provider) {
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: _sendFieldBoxDecoration(context),
      child: TextField(
        controller: provider.amountController,
        style: TextStyle(color: colorScheme.onSurface),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          hintText: l10n.minAmountHint,
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    SendProvider provider,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Transaction Fees Row - Full Width
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.sendTransactionFeesColon,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Text(
                l10n.feeFree,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sent Amount and Send Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.sendSentAmountLabel,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.amountController.text.isEmpty ? '0' : provider.amountController.text} ${provider.selectedCoin?.localizedCoinTicker(context) ?? ''}',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 140,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.canSend
                      ? () {
                          context.push(Routes.sendReview, extra: provider);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.canSend
                        ? AppColors.tealColor
                        : colorScheme.surfaceContainerHighest,
                    foregroundColor: provider.canSend
                        ? AppColors.white
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                    disabledBackgroundColor:
                        colorScheme.surfaceContainerHighest,
                    disabledForegroundColor: colorScheme.onSurface.withValues(
                      alpha: 0.38,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(l10n.send, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCoinSelection(BuildContext context, SendProvider provider) {
    final l10n = context.l10n!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: CoinSelectionSheet(
          title: l10n.selectCoinTitle,
          coins: provider.coins,
          selectedCoin: provider.selectedCoin,
          onCoinSelected: (coin) {
            provider.setSelectedCoin(coin);
          },
        ),
      ),
    );
  }

  Future<void> _openQrScanner(
    BuildContext context,
    SendProvider provider,
  ) async {
    final result = await context.push<String>(
      Routes.qrScanner,
      extra: QrScannerExtra(validator: Utility.isValidWalletAddress),
    );
    if (result != null && context.mounted) {
      provider.recipientController.text = result;
    }
  }

  Future<void> _showContactSelection(
    BuildContext context,
    SendProvider provider,
  ) async {
    final l10n = context.l10n!;
    final status = await Permission.contacts.status;

    if (!context.mounted) return;

    if (status.isPermanentlyDenied) {
      // Already denied permanently — show dialog with "Open Settings".
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PermissionDialog(
          title: l10n.contactsPermissionDialogTitle(l10n.appTitle),
          message: l10n.contactsPermissionDialogMessage,
          onDoNotAllow: () => Navigator.of(ctx).pop(),
          onOpenSettings: () {
            Navigator.of(ctx).pop();
            openAppSettings();
          },
        ),
      );
      return;
    }

    if (!status.isGranted) {
      // Show rationale dialog, then request system permission.
      final allowed = await PermissionDialog.show(
        context,
        title: l10n.contactsPermissionDialogTitle(l10n.appTitle),
        message: l10n.contactsPermissionDialogMessage,
        allowLabel: l10n.allowContacts,
      );
      if (allowed != true || !context.mounted) return;

      final result = await Permission.contacts.request();
      if (!result.isGranted || !context.mounted) return;
    }

    // Permission granted — open the contacts sheet.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: ContactSelectionSheet(
          onContactSelected: (contact) {
            provider.setSelectedContact(contact);
          },
        ),
      ),
    );
  }

  Color _getCoinColor(String symbol) {
    if (symbol == 'USDT') return AppColors.usdtColor;
    if (symbol == 'BTC') return AppColors.bitcoinColor;
    if (symbol == 'ETH') return AppColors.textWhite;
    return Colors.grey;
  }
}
