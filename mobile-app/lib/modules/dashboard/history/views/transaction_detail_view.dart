import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/transaction_model/transaction_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../providers/global_provider.dart';
import '../../../../widgets/common_back_button.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/theme_aware_icon.dart';
import '../widgets/save_as_bottom_sheet.dart';

class TransactionDetailView extends StatefulWidget {
  const TransactionDetailView({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  String? _successMessage;
  bool _showSuccessBanner = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDarkMode = context.isDarkMode;
    final selectedCurrency = context.watch<GlobalProvider>().selectedCurrency;
    final currencySymbol = l10n.currencySymbol(selectedCurrency.toLowerCase());
    final isSent = widget.transaction.type == TransactionType.sent;

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          isSent ? l10n.sent : l10n.receive,
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkCardColor
                            : const Color(0xFFF5F5F5),
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
                            '${_getTypePrefix(widget.transaction.type)}${_formatAmount(widget.transaction.amount)} ${widget.transaction.coinSymbol}',
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? AppColors.white
                                  : AppColors.textBlack,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // USD Equivalent
                          Text(
                            '≈$currencySymbol${widget.transaction.valueInCurrency}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                          // Status (only for sent transactions)
                          if (isSent) ...[
                            const SizedBox(height: 8),
                            Text(
                              widget.transaction.status ==
                                      TransactionStatus.failed
                                  ? l10n.failed
                                  : widget.transaction.status ==
                                        TransactionStatus.completed
                                  ? l10n.completed
                                  : l10n.pending,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color:
                                    widget.transaction.status ==
                                        TransactionStatus.failed
                                    ? Colors.red
                                    : widget.transaction.status ==
                                          TransactionStatus.completed
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
                        'yyyy-MM-dd HH:mm:ss',
                      ).format(widget.transaction.date),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      l10n.network,
                      'TRC20',
                      isNetwork: true,
                    ),
                    const SizedBox(height: 16),
                    if (isSent) ...[
                      _buildDetailRow(
                        context,
                        l10n.sendTo,
                        'M**** M*****d A*****', // Dummy masked name
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        l10n.phoneNumber,
                        '+966 83 872 9872', // Dummy phone number
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        l10n.transactionFees,
                        widget.transaction.fee != null &&
                                widget.transaction.fee! > 0
                            ? '${widget.transaction.fee} ${widget.transaction.coinSymbol}'
                            : 'Free',
                      ),
                    ] else ...[
                      _buildDetailRow(
                        context,
                        l10n.sender,
                        'M**** M*****d A*****', // Dummy masked name
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        l10n.address,
                        widget.transaction.toAddress ??
                            '09405093285dj9483cjxyg89y...',
                        isAddress: true,
                      ),
                      if (widget.transaction.note != null &&
                          widget.transaction.note!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          l10n.note,
                          widget.transaction.note!,
                        ),
                      ],
                    ],
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
                      onPressed: () => _shareTransaction(),
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
  }) {
    final isDarkMode = context.isDarkMode;
    return Column(
      children: [
        Row(
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
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
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
                          color: isDarkMode
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
        const SizedBox(height: 16),
        Divider(
          height: 1,
          thickness: 1,
          color: isDarkMode ? AppColors.darkCardColor : const Color(0xFFE8E8E8),
        ),
      ],
    );
  }

  String _getTypePrefix(TransactionType type) {
    switch (type) {
      case TransactionType.sent:
        return '-';
      case TransactionType.received:
        return '+';
      case TransactionType.swap:
        return '';
    }
  }

  String _formatAmount(String amount) {
    // Format amount with commas for thousands
    try {
      final numValue = double.parse(amount);
      return NumberFormat('#,##0.000').format(numValue);
    } catch (e) {
      return amount;
    }
  }

  void _shareTransaction() {
    final tx = widget.transaction;
    final amountText =
        '${_getTypePrefix(tx.type)}${_formatAmount(tx.amount)} ${tx.coinSymbol}';
    final dateText = DateFormat('MMMM, yyyy').format(tx.date);
    final hashText = tx.transactionHash ?? tx.toAddress ?? tx.fromAddress ?? '';
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
