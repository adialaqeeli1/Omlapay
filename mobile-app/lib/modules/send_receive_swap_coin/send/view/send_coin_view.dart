import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/extentions/number_extensions.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/models/coin_model/coin_model.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/coin_brand_color.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/utility.dart';
import '../../../../routes/app_router.dart';
import '../../../kyc_verification/utils/kyc_verification_entry_source.dart';
import '../../../scan/view/qr_scanner_view.dart';
import '../../../../widgets/permission_dialog.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/common_coin_icon.dart';
import '../../../../widgets/kyc_verification_gate.dart';
import '../../../../widgets/coin_selection_sheet.dart';
import '../../../../providers/wallets_provider.dart';
import '../provider/send_provider.dart';
import '../widgets/contact_selection_sheet.dart';

/// Route extra for [Routes.sendCoin] used to pre-fill the send form.
///
/// All fields are optional; providing them causes [SendProvider] to
/// auto-select the matching coin (and therefore its network) and to
/// populate the recipient and amount fields on construction.
class SendCoinExtra {
  const SendCoinExtra({
    this.initialCoinSymbol,
    this.initialRecipient,
    this.initialAmount,
  });

  final String? initialCoinSymbol;
  final String? initialRecipient;
  final String? initialAmount;
}

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
                  if (provider.recipientError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      provider.recipientError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                  const SizedBox(height: 20),

                  _buildLabel(context, l10n.sendFormAmountLabel),
                  const SizedBox(height: 8),
                  _buildAmountField(context, provider),

                  if ((provider.error ?? provider.quoteError) != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      (provider.error ?? provider.quoteError)!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],

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
                        '${provider.selectedCoin != null ? context.watch<WalletsProvider>().balanceForCoin(provider.selectedCoin!.symbol) : '0'} ${provider.selectedCoin?.localizedCoinTicker(context) ?? ''}'
                            .trim(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  // KYC gate — blocks the screen until verification is complete.
                  const KycVerificationGate(
                    entrySource: KycVerificationEntrySource.send,
                  ),
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
                    iconBackgroundColor: coinBrandColor(
                      coin.symbol,
                      isDarkMode: context.isDarkMode,
                      fallback: Colors.grey,
                    ),
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
    final showMaxAction = provider.selectedCoin != null;
    // final max = provider.maxSendAmount;
    // final ticker = provider.selectedCoin?.localizedCoinTicker(context) ?? '';
    return Container(
      decoration: _sendFieldBoxDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: provider.amountController,
                  style: TextStyle(color: colorScheme.onSurface),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: l10n.minAmountHint(
                      provider.minSendAmount.toFormattedMinAmount(),
                    ),
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (showMaxAction) ...[
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 8),
                  width: 1,
                  height: 28,
                  color: colorScheme.outlineVariant,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
                  child: GestureDetector(
                    onTap: provider.setMaxAmount,
                    child: Text(
                      l10n.sendAmountMaxShortLabel,
                      style: const TextStyle(
                        color: AppColors.tealColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          // if (max > 0)
          //   Padding(
          //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           l10n.sendAmountMaxShortLabel,
          //           style: TextStyle(
          //             color: colorScheme.onSurfaceVariant,
          //             fontSize: 12,
          //           ),
          //         ),
          //         Text(
          //           '${max.toFormattedAmount(decimals: AppConstants.maxAmountDecimals)} $ticker'
          //               .trim(),
          //           style: TextStyle(
          //             color: colorScheme.onSurface,
          //             fontSize: 12,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }

  /// Renders the live transaction fee returned by the send-quote API.
  ///
  /// Shows a small spinner while the debounced quote call is in flight, the
  /// quote's fee once available, and falls back to the localized "Free"
  /// label when the form is incomplete or the API has not yet returned a fee.
  Widget _buildFeeValue(
    BuildContext context,
    SendProvider provider,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(color: colorScheme.onSurface, fontSize: 12);

    if (provider.isFetchingQuote) {
      return SizedBox(
        height: 12,
        width: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    final fee = provider.quote?.fee.trim() ?? '';
    final feeAmount = double.tryParse(fee);
    if (fee.isEmpty || (feeAmount != null && feeAmount == 0)) {
      return Text(l10n.feeFree, style: textStyle);
    }
    final display = feeAmount != null ? feeAmount.toFormattedAmount() : fee;
    return Text(display, style: textStyle);
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
          // Transaction Fees Row — only rendered while a quote is being
          // fetched or has just been fetched. Hidden entirely otherwise so
          // the footer doesn't claim a "Free" fee before the API confirms.
          if (provider.isFetchingQuote || provider.quote != null) ...[
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
                _buildFeeValue(context, provider, l10n),
              ],
            ),
            const SizedBox(height: 12),
          ],

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
                  onPressed: (provider.canSend && !provider.isSubmitting)
                      ? () => _onSendPressed(context, provider)
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
                  child: provider.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Text(l10n.send, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onSendPressed(
    BuildContext context,
    SendProvider provider,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ok = await provider.prepareSendReview();
    if (!context.mounted) return;
    if (ok) {
      context.push(Routes.sendReview, extra: provider);
      return;
    }
    final error = provider.submitError;
    if (error != null && error.isNotEmpty) {
      SnackbarHelper.showError(context, error);
      provider.clearSubmitError();
    }
  }

  void _showCoinSelection(BuildContext context, SendProvider provider) {
    final l10n = context.l10n!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: context.height * 0.7,
        child: CoinSelectionSheet(
          title: l10n.selectCoinTitle,
          coins: provider.coins,
          selectedCoin: provider.selectedCoin,
          candidateSymbols: provider.candidateSymbols,
          candidateCoinSymbol: provider.candidateCoinSymbol,
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
      extra: const QrScannerExtra(validator: Utility.isValidWalletAddress),
    );
    if (result == null || !context.mounted) return;

    // Resolves the chain for a bare address (no embedded coin) so the
    // matching coin/network can be auto-selected below.
    final payload = await Utility.parseScannedWalletResolved(result);
    if (payload == null || !context.mounted) return;

    final address = payload.address?.trim() ?? '';
    if (address.isNotEmpty) {
      provider.recipientController.text = address;
    }

    final amount = Utility.formatScannedAmount(payload.amount);
    if (amount != null) {
      provider.amountController.text = amount;
    }

    final symbol = payload.symbol.trim().toUpperCase();
    if (symbol.isEmpty) return;
    final match = _findCoinBySymbol(provider.coins, symbol);
    if (match != null) {
      provider.setSelectedCoin(match);
    }
  }

  CoinModel? _findCoinBySymbol(List<CoinModel> coins, String symbol) {
    for (final coin in coins) {
      if (coin.symbol.toUpperCase() == symbol) return coin;
    }
    return null;
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
}
