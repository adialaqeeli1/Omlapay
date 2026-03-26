import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme.dart';
import '../../../widgets/theme_aware_icon.dart';
import '../provider/transaction_details_provider.dart';

class TransactionDetailsView extends StatelessWidget {
  const TransactionDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<TransactionDetailsProvider>();
    final transaction = provider.transaction;

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground, // Dark theme background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.receive, // Or just "Receive" as per screenshot?
          style: const TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Amount Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.balanceCardGradientStart,
                          AppColors.balanceCardGradientEnd,
                        ],
                        stops: [0.3091, 2.402],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.total,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '+${double.parse(transaction.amount).toStringAsFixed(3).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")} ${transaction.coinSymbol}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // details
                  _buildDetailRow(
                    l10n.date,
                    DateFormat(
                      'yyyy-MM-dd hh:mm a',
                    ).format(transaction.date).toLowerCase(),
                  ),
                  const Divider(
                    color: AppColors.divider,
                    height: 30,
                    thickness: 0.5,
                  ),
                  _buildDetailRow(
                    l10n.sender,
                    transaction.fromAddress ?? l10n.valueNotAvailable,
                  ),
                  const Divider(
                    color: AppColors.divider,
                    height: 30,
                    thickness: 0.5,
                  ),
                  _buildDetailRow(
                    l10n.address,
                    transaction.toAddress ??
                        transaction.fromAddress ??
                        l10n.valueNotAvailable,
                    isMultiLine: true,
                  ),
                  const Divider(
                    color: AppColors.divider,
                    height: 30,
                    thickness: 0.5,
                  ),
                  _buildNetworkRow(l10n.network, 'TRC20'),

                  const Spacer(),
                  // Save As Button
                  // Assuming the icon button in bottom left is for sharing or something separate
                  // If "Save As" is the main action, maybe the icon button on left is "Share"?
                  // The screenshot shows an icon button on left and a large "Save As" button.
                  // Structure for bottom buttons:
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.iconBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: ThemeAwareIcon(
                            assetPath: 'assets/icons/share.svg',
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: provider.saveAs,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tealColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              l10n.saveAs,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: .center,
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: isMultiLine ? 2 : 1,
              overflow: isMultiLine
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tealColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
