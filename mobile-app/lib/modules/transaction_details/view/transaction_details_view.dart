import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/models/transaction_model/transaction_model.dart';
import '../../../core/theme/theme.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/theme_aware_icon.dart';
import '../../dashboard/history/widgets/save_as_bottom_sheet.dart';
import '../provider/transaction_details_provider.dart';

class TransactionDetailsView extends StatefulWidget {
  const TransactionDetailsView({super.key, this.showTransactionType = false});

  final bool showTransactionType;

  @override
  State<TransactionDetailsView> createState() => _TransactionDetailsViewState();
}

class _TransactionDetailsViewState extends State<TransactionDetailsView> {
  String? _successMessage;
  bool _showSuccessBanner = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDarkMode = context.isDarkMode;
    final provider = context.watch<TransactionDetailsProvider>();
    final transaction = provider.transaction;

    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: const CommonBackButton(),
          title: Text(
            l10n.transactionDetails,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.textBlack,
            ),
          ),
          backgroundColor: isDarkMode
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const CommonBackButton(),
          title: Text(
            l10n.transactionDetails,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.textBlack,
            ),
          ),
          backgroundColor: isDarkMode
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.requestFailed,
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: provider.refresh,
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    final isSent = transaction.isSent;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final amountValue = double.tryParse(transaction.amount) ?? 0;
    final amountSign = isSent ? '-' : '+';
    final amountText =
        '$amountSign${NumberFormat('#,##0.########').format(amountValue.abs())} ${transaction.assetSymbol}';
    final approxAmount = _approxAmountText(context, transaction, isArabic);
    final localizedError = isArabic
        ? (transaction.errorMessageAr?.trim().isNotEmpty == true
              ? transaction.errorMessageAr
              : transaction.errorMessage)
        : (transaction.errorMessage?.trim().isNotEmpty == true
              ? transaction.errorMessage
              : transaction.errorMessageAr);
    final counterparty = transaction.counterpartyPhone?.trim();
    final senderValue = counterparty != null && counterparty.isNotEmpty
        ? counterparty
        : transaction.senderAddress;
    final addressValue = isSent
        ? transaction.receiverAddress
        : transaction.senderAddress;

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          widget.showTransactionType
              ? (isSent ? l10n.sent : l10n.receive)
              : l10n.transactionDetails,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.textBlack,
          ),
        ),
        backgroundColor: isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Amount Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: isDarkMode
                            ? const LinearGradient(
                                begin: Alignment(0.75, -0.66),
                                end: Alignment(-0.75, 0.66),
                                colors: [
                                  Color(0x991C1C1E),
                                  Color(0x991C1C1E),
                                  Color(0x991B3232),
                                ],
                                stops: [0.0, 0.3091, 1.0],
                              )
                            : null,
                        color: isDarkMode ? null : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Total Label
                          Text(
                            l10n.total,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Amount
                          Text(
                            amountText,
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? AppColors.white
                                  : AppColors.textBlack,
                              fontSize: 24,
                            ),
                          ),
                          // Approx fiat amount
                          if (approxAmount != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              approxAmount,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          // Status
                          if (isSent) ...[
                            const SizedBox(height: 8),
                            Text(
                              transaction.isFailed
                                  ? l10n.failed
                                  : transaction.isCompleted
                                  ? l10n.completed
                                  : l10n.pending,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: transaction.isFailed
                                    ? Colors.red
                                    : transaction.isCompleted
                                    ? AppColors.greenColor
                                    : AppColors.textGrey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Transaction Details
                    _buildDetailRow(
                      context,
                      l10n.date,
                      DateFormat(
                        'yyyy-MM-dd hh:mm:ss a',
                      ).format(transaction.createdAt),
                    ),
                    _buildDetailRow(
                      context,
                      l10n.network,
                      transaction.network ?? 'N/A',
                      isNetwork: true,
                    ),
                    if (senderValue != null && senderValue.isNotEmpty)
                      _buildDetailRow(
                        context,
                        l10n.sender,
                        senderValue,
                        isAddress: true,
                      ),
                    if (addressValue != null && addressValue.isNotEmpty)
                      _buildDetailRow(
                        context,
                        l10n.address,
                        addressValue,
                        isAddress: true,
                      ),
                    if (transaction.isFailed &&
                        localizedError != null &&
                        localizedError.isNotEmpty)
                      _buildDetailRow(
                        context,
                        l10n.failureReason,
                        localizedError,
                        isError: true,
                      ),
                  ],
                ),
              ),
            ),
            // Success Banner
            if (_showSuccessBanner) _buildSuccessBanner(context),
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                border: Border(
                  top: BorderSide(
                    color: isDarkMode
                        ? AppColors.darkCardColor
                        : const Color(0xFFE8E8E8),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Small square button with icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.darkCardColor
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: ThemeAwareIcon(
                        assetPath: 'assets/icons/share.svg',
                        width: 24,
                        height: 24,
                        colorToInvert: isDarkMode
                            ? AppColors.iconBlack
                            : AppColors.white,
                      ),
                      onPressed: () => _shareTransaction(transaction),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save As button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showSaveAsBottomSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.saveAs,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isNetwork = false,
    bool isAddress = false,
    bool isError = false,
  }) {
    final isDarkMode = context.isDarkMode;
    return Column(
      crossAxisAlignment: .center,
      mainAxisAlignment: .center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: isNetwork
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Text(
                          isAddress && value.length > 20
                              ? '${value.substring(0, 20)}...'
                              : value,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: isError
                                ? Colors.red
                                : isDarkMode
                                ? AppColors.white
                                : AppColors.textBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.end,
                        ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: isDarkMode ? AppColors.darkCardColor : const Color(0xFFE8E8E8),
        ),
      ],
    );
  }

  String? _approxAmountText(
    BuildContext context,
    TransactionModel tx,
    bool isArabic,
  ) {
    final l10n = context.l10n!;
    final usd = tx.amountUsd;
    if (usd != null && usd.trim().isNotEmpty) {
      final value = double.tryParse(usd);
      final formatted = value != null
          ? NumberFormat('#,##0.00').format(value)
          : usd;
      return l10n.approximateAmount(formatted, 'USD');
    }
    final sar = tx.amountSar;
    if (sar != null && sar.trim().isNotEmpty) {
      final value = double.tryParse(sar);
      final formatted = value != null
          ? NumberFormat('#,##0.00').format(value)
          : sar;
      return l10n.approximateAmount(formatted, 'SAR');
    }
    return null;
  }

  String _formatAmount(String amount) {
    try {
      // Remove +/- prefix for formatting
      final cleanAmount = amount.replaceAll(RegExp(r'^[+-]'), '');
      final numValue = double.parse(cleanAmount);
      return NumberFormat('#,##0.000').format(numValue);
    } catch (e) {
      return amount;
    }
  }

  void _shareTransaction(TransactionModel tx) {
    final amountText = '${_formatAmount(tx.amount)} ${tx.assetSymbol}';
    final dateText = DateFormat('MMMM, yyyy').format(tx.createdAt);
    final hashText = tx.txHash ?? '';
    final shareText = [
      amountText,
      dateText,
      if (hashText.isNotEmpty) hashText,
    ].join('\n');
    SharePlus.instance.share(ShareParams(text: shareText));
  }

  void _showSaveAsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveAsBottomSheet(
        onSave: (format) {
          _handleSave(format);
        },
      ),
    );
  }

  void _handleSave(SaveFormat format) {
    final l10n = context.l10n!;
    final formatName = format == SaveFormat.png ? l10n.png : l10n.pdf;

    setState(() {
      _successMessage = l10n.transactionSavedSuccessfully(formatName);
      _showSuccessBanner = true;
    });

    // Hide banner after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessBanner = false;
          _successMessage = null;
        });
      }
    });

    // TODO: Implement actual save functionality (PNG/PDF generation)
  }

  Widget _buildSuccessBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.greenColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Checkmark Icon
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              CupertinoIcons.checkmark,
              color: AppColors.greenColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          // Success Message
          Expanded(
            child: Text(
              _successMessage ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
