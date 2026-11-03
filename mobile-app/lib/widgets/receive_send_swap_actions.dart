import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../core/extentions/context_extensions.dart';
import '../core/l10n/app_localizations.dart';
import '../core/theme/theme.dart';
import '../modules/send_receive_swap_coin/send/view/send_coin_view.dart';
import '../modules/send_receive_swap_coin/swap/view/swap_coin_view.dart';
import '../routes/app_router.dart';

class ReceiveSendSwapActions extends StatelessWidget {
  const ReceiveSendSwapActions({
    super.key,
    this.coinSymbol,
    this.isDetailsPage = false,
  });

  /// When provided, the send/swap actions navigate with the symbol
  /// pre-selected (send: as the source coin; swap: as the `from` coin).
  final String? coinSymbol;

  final bool isDetailsPage;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n!;
    final String? preselected = coinSymbol?.trim().isEmpty ?? true
        ? null
        : coinSymbol!.trim();

    return Row(
      mainAxisAlignment: .spaceBetween,
      spacing: 8,
      children: [
        Flexible(
          child: _buildActionButton(
            context,
            icon: 'assets/icons/Receive.svg',
            label: l10n.receive,
            onTap: () => context.push(Routes.recieveCoins, extra: true),
          ),
        ),
        Flexible(
          child: _buildActionButton(
            context,
            icon: 'assets/icons/send.svg',
            label: l10n.send,
            onTap: () => context.push(
              Routes.sendCoin,
              extra: preselected == null
                  ? null
                  : SendCoinExtra(initialCoinSymbol: preselected),
            ),
          ),
        ),
        Flexible(
          child: _buildActionButton(
            context,
            icon: 'assets/icons/swap.svg',
            label: l10n.swap,
            onTap: () => context.push(
              Routes.swapCoin,
              extra: preselected == null
                  ? null
                  : SwapCoinExtra(initialFromCoinSymbol: preselected),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return MaterialButton(
      onPressed: onTap,
      color: context.isDarkMode
          ? AppColors.darkCardColor
          : AppColors.primaryColor,
      padding: EdgeInsets.zero,
      minWidth: 120,
      height: 48,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      disabledElevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Row(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            colorFilter: context.isDarkMode
                ? isDetailsPage
                      ? ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn)
                      : null
                : ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
