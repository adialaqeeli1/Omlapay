import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/extentions/number_extensions.dart';
import '../../../../core/models/coin_model/coin_model_quote_display.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_back_button.dart';
import '../provider/send_provider.dart';

class ReviewSendView extends StatelessWidget {
  const ReviewSendView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SendProvider>();
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final quote = provider.quote;

    final ticker =
        quote?.coin ??
        provider.selectedCoin?.localizedCoinTicker(context) ??
        '';
    // Format the send amount to the standard coin precision (truncated to
    // [AppConstants.coinAmountDecimals]) like the fee row and success screen,
    // so the hero card never shows a raw, full-precision value. Falls back to
    // the raw string if it can't be parsed.
    final rawAmount = quote?.amount ?? provider.amountController.text;
    final parsedAmount = double.tryParse(rawAmount.trim());
    final displayAmount = parsedAmount != null
        ? parsedAmount.toFormattedAmount()
        : rawAmount;
    final rawAmountUsd = quote?.amountUsd ?? '';
    final parsedAmountUsd = double.tryParse(rawAmountUsd.trim());
    final displayAmountUsd = parsedAmountUsd != null
        ? parsedAmountUsd.toFormattedAmount(
            decimals: AppConstants.fiatValueDecimals,
          )
        : rawAmountUsd;
    final displayNetwork = (quote?.network.isNotEmpty ?? false)
        ? quote!.network
        : provider.network;
    final feeAmount = double.tryParse((quote?.fee ?? '').trim());
    final displayFee = (feeAmount == null || feeAmount <= 0)
        ? l10n.feeFree
        : '${feeAmount.toFormattedAmount()} $ticker';
    final selectedCoin = provider.selectedCoin;
    final senderAddress = selectedCoin == null
        ? null
        : provider.walletsProvider.addressForCoin(
            selectedCoin.symbol,
            network: provider.network,
          );
    final recipientName = quote?.recipientName?.trim() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendFlowReviewTitle),
        elevation: 0,
        leading: const CommonBackButton(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              _AmountHeroCard(
                label: l10n.youWillSend,
                amount: displayAmount,
                ticker: ticker,
                amountUsd: displayAmountUsd,
              ),
              const SizedBox(height: 32),
              _DetailsList(
                rows: [
                  _DetailRowData(
                    label: l10n.network,
                    trailing: _NetworkPill(network: displayNetwork),
                  ),
                  if (senderAddress != null && senderAddress.isNotEmpty)
                    _DetailRowData(
                      label: l10n.walletAddress,
                      valueText: senderAddress,
                    ),
                  if (recipientName.isNotEmpty)
                    _DetailRowData(
                      label: l10n.sendTo,
                      valueText: recipientName,
                      emphasized: true,
                    ),
                  _DetailRowData(
                    label: l10n.transactionFees,
                    valueText: displayFee,
                  ),
                ],
              ),
              const Spacer(),
              _ConfirmationWarning(text: l10n.confirmationWarning),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: provider.isSubmitting
                      ? null
                      : () => _onConfirmPressed(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealColor,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor: AppColors.tealColor.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: provider.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          l10n.confirm,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirmPressed(
    BuildContext context,
    SendProvider provider,
  ) async {
    final l10n = context.l10n!;
    try {
      final message = await provider.initiateSend();
      if (!context.mounted) return;
      if (message == null) return; // pre-flight validation blocked the call
      if (message.isNotEmpty) {
        SnackbarHelper.showSuccess(context, message);
      }
      context.push(Routes.sendVerification, extra: provider);
    } on AppException catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, e.localizedMessage(context.l10n));
    } catch (_) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, l10n.unknownError);
    }
  }
}

class _AmountHeroCard extends StatelessWidget {
  const _AmountHeroCard({
    required this.label,
    required this.amount,
    required this.ticker,
    required this.amountUsd,
  });

  final String label;
  final String amount;
  final String ticker;
  final String amountUsd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    const gradientStart = Color(0x991C1C1E);
    const gradientEnd = Color(0x991A605B);
    final gradientEndVisible =
        Color.lerp(gradientStart, gradientEnd, 0.3301) ?? gradientStart;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: const Alignment(0.75, -0.66),
          end: const Alignment(-0.75, 0.66),
          colors: [gradientStart, gradientEndVisible],
          stops: const [0.3091, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$amount${ticker.isNotEmpty ? ' $ticker' : ''}',
              style: textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (amountUsd.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '≈$amountUsd USD',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailsList extends StatelessWidget {
  const _DetailsList({required this.rows});

  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(_DetailRow(data: rows[i]));
      if (i != rows.length - 1) {
        children.add(
          Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            height: 1,
            thickness: 1,
          ),
        );
      }
    }
    return Column(children: children);
  }
}

class _DetailRowData {
  const _DetailRowData({
    required this.label,
    this.valueText,
    this.trailing,
    this.emphasized = false,
  });

  final String label;
  final String? valueText;
  final Widget? trailing;
  final bool emphasized;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.data});

  final _DetailRowData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            data.label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child:
                  data.trailing ??
                  Text(
                    data.valueText ?? '',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: data.emphasized
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkPill extends StatelessWidget {
  const _NetworkPill({required this.network});

  final String network;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tealColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        network,
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.tealColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ConfirmationWarning extends StatelessWidget {
  const _ConfirmationWarning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
