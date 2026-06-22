import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/utils/block_explorer.dart';
import '../../../core/utils/date_time_format.dart';
import '../../../core/models/transaction_model/transaction_model.dart';
import '../../../core/models/transaction_model/transaction_swap_asset.dart';
import '../../../core/theme/theme.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/copied_toast.dart';
import '../../../widgets/theme_aware_icon.dart';
import '../../dashboard/history/widgets/save_as_bottom_sheet.dart';
import '../provider/transaction_details_provider.dart';
import '../services/transaction_export_service.dart';

class TransactionDetailsView extends StatefulWidget {
  const TransactionDetailsView({super.key});

  @override
  State<TransactionDetailsView> createState() => _TransactionDetailsViewState();
}

class _TransactionDetailsViewState extends State<TransactionDetailsView> {
  String? _successMessage;
  bool _showSuccessBanner = false;
  bool _isExporting = false;

  /// Anchors the off-screen render that the export service rasterizes into
  /// a PNG / PDF. Kept on State so the same boundary survives rebuilds and
  /// the saved file always reflects the latest transaction snapshot.
  final GlobalKey _receiptBoundaryKey = GlobalKey();

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
          // title: Text(
          //   l10n.transactionDetails,
          //   style: context.textTheme.titleLarge?.copyWith(
          //     fontWeight: FontWeight.bold,
          //     color: isDarkMode ? AppColors.white : AppColors.textBlack,
          //   ),
          // ),
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
    final isSwap = transaction.isSwap;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final txTypeLabel = _txTypeLabel(context, transaction);
    final amountValue = double.tryParse(transaction.amount) ?? 0;
    final amountSign = isSent ? '-' : '+';
    final amountText =
        '$amountSign${NumberFormat('#,##0.########').format(amountValue.abs())} ${transaction.assetSymbol}';
    final pairLabel = transaction.pairLabel?.trim();
    final approxAmount = _approxAmountText(context, transaction, isArabic);
    final localizedError = isArabic
        ? (transaction.errorMessageAr?.trim().isNotEmpty == true
              ? transaction.errorMessageAr
              : transaction.errorMessage)
        : (transaction.errorMessage?.trim().isNotEmpty == true
              ? transaction.errorMessage
              : transaction.errorMessageAr);
    // Transaction parties, surfaced as two explicit rows so the direction of
    // the transfer is always unambiguous:
    //   Sender   → wallet the coins were sent FROM
    //   Receiver → wallet the coins were sent TO
    // The counterparty (the *other* party) may be identified by a phone number;
    // when present, prefer it over the raw wallet address for that side. The
    // counterparty is the receiver on outgoing transfers and the sender on
    // incoming ones. Each row renders only when it has a value.
    final counterpartyPhone = transaction.counterpartyPhone?.trim();
    final hasCounterpartyPhone =
        counterpartyPhone != null && counterpartyPhone.isNotEmpty;
    final senderValue = !isSent && hasCounterpartyPhone
        ? counterpartyPhone
        : transaction.senderAddress?.trim();
    final receiverValue = isSent && hasCounterpartyPhone
        ? counterpartyPhone
        : transaction.receiverAddress?.trim();
    // Block-explorer link for the tx hash. Prefer the backend-provided
    // `blockchain_link`; fall back to a derived explorer URL when it's absent.
    // Null when neither is available — the row then renders as plain text.
    final backendLink = transaction.blockchainLink?.trim();
    final explorerUrl = backendLink != null && backendLink.isNotEmpty
        ? backendLink
        : blockExplorerTxUrl(
            network: transaction.network,
            txHash: transaction.txHash,
          );

    return Scaffold(
      appBar: AppBar(
        leading: const CommonBackButton(),
        title: Text(
          txTypeLabel ?? l10n.transactionDetails,
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
                padding: const EdgeInsets.all(8),
                child: RepaintBoundary(
                  key: _receiptBoundaryKey,
                  child: Container(
                    color: isDarkMode
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                    padding: const EdgeInsets.all(16),
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
                                textDirection: TextDirection.ltr,
                                style: context.textTheme.headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? AppColors.white
                                          : AppColors.textBlack,
                                      fontSize: 24,
                                    ),
                              ),
                              // Swap pair label
                              if (isSwap &&
                                  pairLabel != null &&
                                  pairLabel.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  pairLabel,
                                  textDirection: TextDirection.ltr,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              // Approx fiat amount
                              if (approxAmount != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  approxAmount,
                                  textDirection: TextDirection.ltr,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              // Status
                              if (isSent || isSwap) ...[
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
                          transaction.createdAt.toAppDateTime(),
                          isDateTime: true,
                        ),
                        if (isSwap) ...[
                          if (_swapAssetText(transaction.fromAsset) != null)
                            _buildDetailRow(
                              context,
                              l10n.swapDirectionFrom,
                              _swapAssetText(transaction.fromAsset)!,
                            ),
                          if (_swapAssetText(transaction.toAsset) != null)
                            _buildDetailRow(
                              context,
                              l10n.swapDirectionTo,
                              _swapAssetText(transaction.toAsset)!,
                            ),
                          if ((transaction.exchangeRate ?? '')
                              .trim()
                              .isNotEmpty)
                            _buildDetailRow(
                              context,
                              l10n.exchangeRate,
                              _formatExchangeRate(transaction),
                            ),
                          if ((transaction.fee ?? '').trim().isNotEmpty)
                            _buildDetailRow(
                              context,
                              l10n.fee,
                              '${transaction.fee} ${transaction.assetSymbol}',
                            ),
                        ] else ...[
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
                              onCopy: () => _copyToClipboard(senderValue),
                            ),
                          if (receiverValue != null && receiverValue.isNotEmpty)
                            _buildDetailRow(
                              context,
                              l10n.receiver,
                              receiverValue,
                              isAddress: true,
                              onCopy: () => _copyToClipboard(receiverValue),
                            ),
                        ],
                        if (transaction.txHash != null &&
                            transaction.txHash!.trim().isNotEmpty)
                          _buildDetailRow(
                            context,
                            l10n.transactionHash,
                            transaction.txHash!,
                            isAddress: true,
                            onOpenLink: explorerUrl != null
                                ? () => _openExplorer(explorerUrl)
                                : null,
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
    bool isDateTime = false,
    VoidCallback? onCopy,
    VoidCallback? onOpenLink,
  }) {
    final isDarkMode = context.isDarkMode;
    final isLink = onOpenLink != null;
    final valueTextStyle = context.textTheme.bodyMedium?.copyWith(
      color: isError
          ? Colors.red
          : isDarkMode
          ? AppColors.white
          : AppColors.textBlack,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      overflow: isAddress ? TextOverflow.visible : TextOverflow.clip,
    );
    final valueText = Text(
      value,
      textDirection: isDateTime ? TextDirection.ltr : null,
      style: valueTextStyle,
      textAlign: TextAlign.end,
    );
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
              const SizedBox(width: 16),
              Expanded(
                child: isNetwork
                    ? Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Container(
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
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : isLink
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: onOpenLink,
                              behavior: HitTestBehavior.opaque,
                              child: valueText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onOpenLink,
                            behavior: HitTestBehavior.opaque,
                            child: Icon(
                              Icons.open_in_new_rounded,
                              size: 16,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      )
                    : onCopy != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(child: valueText),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onCopy,
                            behavior: HitTestBehavior.opaque,
                            child: Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: isDarkMode
                                  ? AppColors.textLightGrey
                                  : AppColors.textGrey,
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: valueText,
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

  void _copyToClipboard(String value) {
    CopiedToast.copy(context, value);
  }

  /// Opens [url] (a block-explorer transaction page) in the external browser.
  /// Surfaces a localized snackbar when the launch can't be handled.
  Future<void> _openExplorer(String url) async {
    final l10n = context.l10n!;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showError(l10n.couldNotOpenLink);
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      if (mounted) _showError(l10n.couldNotOpenLink);
    }
  }

  /// Formats a swap asset as `<amount> <symbol>` for the From / To detail
  /// rows. Prefers `amountDisplay` (already signed) and falls back to a
  /// formatted `amount` when the display string is missing.
  String? _swapAssetText(TransactionSwapAsset? asset) {
    if (asset == null) return null;
    final symbol = asset.symbol?.trim() ?? '';
    final display = asset.amountDisplay?.trim();
    if (display != null && display.isNotEmpty) {
      return symbol.isEmpty ? display : '$display $symbol';
    }
    final raw = asset.amount?.trim();
    if (raw == null || raw.isEmpty) return null;
    final value = double.tryParse(raw);
    final formatted = value != null
        ? NumberFormat('#,##0.########').format(value)
        : raw;
    return symbol.isEmpty ? formatted : '$formatted $symbol';
  }

  /// Renders the exchange rate as `1 <from> = <rate> <to>` so the direction
  /// of the quote is unambiguous. Falls back to the raw rate when the
  /// from/to symbols aren't available.
  String _formatExchangeRate(TransactionModel tx) {
    final rate = tx.exchangeRate?.trim() ?? '';
    final value = double.tryParse(rate);
    final formattedRate = value != null
        ? NumberFormat('#,##0.########').format(value)
        : rate;
    final fromSymbol = tx.fromAsset?.symbol?.trim() ?? '';
    final toSymbol = tx.toAsset?.symbol?.trim() ?? '';
    if (fromSymbol.isEmpty || toSymbol.isEmpty) return formattedRate;
    return '1 $fromSymbol = $formattedRate $toSymbol';
  }

  String? _txTypeLabel(BuildContext context, TransactionModel tx) {
    final l10n = context.l10n!;
    switch (tx.txType) {
      case 'SWAP':
        return l10n.swap;
      case 'SENT':
        return l10n.sent;
      case 'RECEIVE':
      case 'RECEIVED':
        return l10n.receive;
      default:
        return null;
    }
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
      return NumberFormat('#,##0.00000').format(numValue);
    } catch (e) {
      return amount;
    }
  }

  void _shareTransaction(TransactionModel tx) {
    final l10n = context.l10n!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final isSent = tx.isSent;
    final amountValue = double.tryParse(tx.amount) ?? 0;
    final amountSign = isSent ? '-' : '+';
    final amountLine =
        '$amountSign${_formatAmount(amountValue.abs().toString())} ${tx.assetSymbol}';
    final approxFiat = _approxAmountText(context, tx, isArabic);
    final amountWithFiat = approxFiat == null
        ? amountLine
        : '$amountLine ($approxFiat)';

    final typeLabel = _txTypeLabel(context, tx) ?? l10n.transactionDetails;
    final statusText = tx.isFailed
        ? l10n.failed
        : tx.isCompleted
        ? l10n.completed
        : l10n.pending;
    final dateText = tx.createdAt.toAppDateTime();

    // Matches the on-screen "Sender" / "Receiver" rows — prefer the
    // counterparty phone over the raw address on the counterparty's side.
    final counterpartyPhone = tx.counterpartyPhone?.trim();
    final hasCounterpartyPhone =
        counterpartyPhone != null && counterpartyPhone.isNotEmpty;
    final senderValue = !isSent && hasCounterpartyPhone
        ? counterpartyPhone
        : tx.senderAddress?.trim();
    final receiverValue = isSent && hasCounterpartyPhone
        ? counterpartyPhone
        : tx.receiverAddress?.trim();
    final localizedError = isArabic
        ? (tx.errorMessageAr?.trim().isNotEmpty == true
              ? tx.errorMessageAr
              : tx.errorMessage)
        : (tx.errorMessage?.trim().isNotEmpty == true
              ? tx.errorMessage
              : tx.errorMessageAr);

    final lines = <String>[
      l10n.transactionReceiptTitle,
      '',
      '${l10n.typeLabel}: $typeLabel',
      '${l10n.statusLabel}: $statusText',
      '${l10n.amountLabel}: $amountWithFiat',
      '${l10n.date}: $dateText',
    ];
    if (tx.isSwap) {
      final pair = tx.pairLabel?.trim();
      if (pair != null && pair.isNotEmpty) {
        lines.add('${l10n.pair}: $pair');
      }
      final fromText = _swapAssetText(tx.fromAsset);
      if (fromText != null) {
        lines.add('${l10n.swapDirectionFrom}: $fromText');
      }
      final toText = _swapAssetText(tx.toAsset);
      if (toText != null) {
        lines.add('${l10n.swapDirectionTo}: $toText');
      }
      if ((tx.exchangeRate ?? '').trim().isNotEmpty) {
        lines.add('${l10n.exchangeRate}: ${_formatExchangeRate(tx)}');
      }
      if ((tx.fee ?? '').trim().isNotEmpty) {
        lines.add('${l10n.fee}: ${tx.fee} ${tx.assetSymbol}');
      }
    } else {
      if ((tx.network ?? '').trim().isNotEmpty) {
        lines.add('${l10n.network}: ${tx.network}');
      }
      if ((tx.fee ?? '').trim().isNotEmpty) {
        lines.add('${l10n.fee}: ${tx.fee} ${tx.assetSymbol}');
      }
      if (senderValue != null && senderValue.isNotEmpty) {
        lines.add('${l10n.sender}: $senderValue');
      }
      if (receiverValue != null && receiverValue.isNotEmpty) {
        lines.add('${l10n.receiver}: $receiverValue');
      }
    }
    if ((tx.txHash ?? '').trim().isNotEmpty) {
      lines.add('${l10n.transactionHash}: ${tx.txHash}');
    }
    if (tx.id.trim().isNotEmpty) {
      lines.add('${l10n.transactionIdLabel}: ${tx.id}');
    }
    if (tx.isFailed && (localizedError ?? '').trim().isNotEmpty) {
      lines.add('${l10n.failureReason}: $localizedError');
    }

    SharePlus.instance.share(ShareParams(text: lines.join('\n')));
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

  Future<void> _handleSave(SaveFormat format) async {
    if (_isExporting) return;
    final l10n = context.l10n!;
    final transaction = context.read<TransactionDetailsProvider>().transaction;
    if (transaction == null) return;

    final formatName = format == SaveFormat.png ? l10n.png : l10n.pdf;
    setState(() => _isExporting = true);

    final result = format == SaveFormat.png
        ? await TransactionExportService.savePng(
            boundaryKey: _receiptBoundaryKey,
            transactionId: transaction.id,
          )
        : await TransactionExportService.savePdf(
            boundaryKey: _receiptBoundaryKey,
            transactionId: transaction.id,
          );

    if (!mounted) return;
    setState(() => _isExporting = false);

    if (result.success) {
      _showBanner(l10n.transactionSavedSuccessfully(formatName));
    } else if (result.cancelled) {
      // User dismissed the save dialog — stay silent.
      return;
    } else if (result.permissionDenied) {
      _showError(l10n.photoLibraryPermissionRequired);
    } else {
      _showError(l10n.transactionSaveFailedMessage);
    }
  }

  void _showBanner(String message) {
    setState(() {
      _successMessage = message;
      _showSuccessBanner = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showSuccessBanner = false;
        _successMessage = null;
      });
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
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
