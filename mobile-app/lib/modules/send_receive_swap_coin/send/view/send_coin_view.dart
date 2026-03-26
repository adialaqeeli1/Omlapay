import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/utility.dart';
import '../../../../routes/app_router.dart';
import '../../../scan/view/qr_scanner_view.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/common_coin_icon.dart';
import '../../swap/view/coin_selection_sheet.dart';
import '../provider/send_provider.dart';
import '../widgets/contact_selection_sheet.dart';

class SendCoinView extends StatelessWidget {
  const SendCoinView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SendProvider>();
    final l10n = context.l10n!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          l10n.sendFlowSendingTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
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
                  _buildLabel(l10n.sendFormCoinLabel),
                  const SizedBox(height: 8),
                  _buildCoinSelector(context, provider),
                  const SizedBox(height: 20),

                  _buildLabel(l10n.network),
                  const SizedBox(height: 8),
                  _buildNetworkField(provider),
                  const SizedBox(height: 20),

                  _buildLabel(l10n.sendFormPhoneOrAddressLabel),
                  const SizedBox(height: 8),
                  _buildRecipientField(context, provider),
                  const SizedBox(height: 20),

                  _buildLabel(l10n.sendFormAmountLabel),
                  const SizedBox(height: 8),
                  _buildAmountField(context, provider),

                  // Available Balance
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.availableShortLabel,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${provider.selectedCoin?.amount ?? '0'} ${provider.selectedCoin?.localizedCoinTicker(context) ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  // Verification Warning
                  if (provider.showVerificationWarning) ...[
                    const SizedBox(height: 30),
                    _buildVerificationBanner(context, provider, l10n),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCoinSelector(BuildContext context, SendProvider provider) {
    final l10n = context.l10n!;
    final coin = provider.selectedCoin;
    return GestureDetector(
      onTap: () => _showCoinSelection(context, provider),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2025),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2D35)),
        ),
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
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.localizedCoinTicker(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        coin.localizedCoinPrimaryName(context),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Text(
                    l10n.selectCoinTitle,
                    style: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkField(SendProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF131416), // Darker background for input fields
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2D35)),
      ),
      child: TextField(
        controller: provider.networkController,
        readOnly: true,
        style: const TextStyle(color: Colors.grey, fontSize: 16),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildRecipientField(BuildContext context, SendProvider provider) {
    final l10n = context.l10n!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131416),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2D35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: provider.recipientController,
              style: const TextStyle(color: Colors.white),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: l10n.pasteHintLongPress,
                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
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
                icon: Icons.person_outline,
                onTap: () => _showContactSelection(context, provider),
              ),
              const SizedBox(width: 8),
              _buildIconButton(
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

  Widget _buildIconButton({
    IconData? icon,
    String? svgPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D35),
          borderRadius: BorderRadius.circular(8),
        ),
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 20)
            : SvgPicture.asset(
                svgPath!,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131416),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2D35)),
      ),
      child: TextField(
        controller: provider.amountController,
        style: const TextStyle(color: Colors.white),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          hintText: l10n.minAmountHint,
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildVerificationBanner(
    BuildContext context,
    SendProvider provider,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3F1519), // Dark Red background
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
                  TextSpan(text: l10n.sendKycVerificationRequiredBody),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await context.push(
                          Routes.sendVerification,
                        );
                        if (result == true) {
                          // ignore: use_build_context_synchronously
                          provider.completeVerification();
                        }
                      },
                      child: Text(
                        l10n.verifyNowButton,
                        style: const TextStyle(
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

  Widget _buildFooter(
    BuildContext context,
    SendProvider provider,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.black, // Or same as background
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
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                l10n.feeFree,
                style: const TextStyle(color: Colors.white, fontSize: 12),
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
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.amountController.text.isEmpty ? '0' : provider.amountController.text} ${provider.selectedCoin?.localizedCoinTicker(context) ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
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
                        ? const Color(0xFF26A69A) // Bright Teal when enabled
                        : const Color(0xFF1A2221), // Dark grey when disabled
                    foregroundColor: Colors.white,
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

  void _showContactSelection(BuildContext context, SendProvider provider) {
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
