import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_back_button.dart';
import '../provider/transaction_details_provider.dart';

class TransactionDetailsView extends StatelessWidget {
  const TransactionDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<TransactionDetailsProvider>();
    final transaction = provider.transaction;
    final isDark = context.isDarkMode;

    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.receive),
          centerTitle: true,
          leading: const CommonBackButton(),
        ),
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const CommonBackButton(),
        title: Text(l10n.receive),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: isDark
                        ? BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.balanceCardGradientStart,
                                AppColors.balanceCardGradientEnd,
                              ],
                              stops: [0.3091, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          )
                        : BoxDecoration(
                            color: AppColors.lightCardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                    child: Column(
                      children: [
                        Text(
                          l10n.total,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textLightGrey
                                : colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '+${double.parse(transaction.amount).toStringAsFixed(3).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")} ${transaction.coinSymbol}',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.white
                                : colorScheme.onSurface,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildDetailRow(
                    context,
                    l10n.date,
                    DateFormat(
                      'yyyy-MM-dd HH:mm:ss',
                      l10n.localeName,
                    ).format(transaction.date),
                  ),
                  Divider(
                    color: colorScheme.outlineVariant,
                    height: 30,
                    thickness: 0.5,
                  ),
                  _buildDetailRow(
                    context,
                    l10n.sender,
                    transaction.fromAddress ?? l10n.valueNotAvailable,
                  ),
                  Divider(
                    color: colorScheme.outlineVariant,
                    height: 30,
                    thickness: 0.5,
                  ),
                  _buildDetailRow(
                    context,
                    l10n.address,
                    transaction.toAddress ??
                        transaction.fromAddress ??
                        l10n.valueNotAvailable,
                    isMultiLine: true,
                  ),
                  Divider(
                    color: colorScheme.outlineVariant,
                    height: 30,
                    thickness: 0.5,
                  ),
                  _buildNetworkRow(
                    context,
                    l10n.network,
                    l10n.sendDefaultNetworkCode,
                  ),

                  const Spacer(),
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
                          icon: SvgPicture.asset(
                            'assets/icons/share.svg',
                            width: 22,
                            height: 22,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
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
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              l10n.saveAs,
                              style: const TextStyle(
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
    BuildContext context,
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: isMultiLine ? 4 : 1,
              overflow: isMultiLine
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
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
