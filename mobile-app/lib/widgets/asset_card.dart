import 'package:flutter/material.dart';
import 'package:omlapay_mobile_app/core/extentions/context_extensions.dart';
import 'package:omlapay_mobile_app/core/theme/theme.dart';

import 'common_coin_icon.dart';

class AssetCard extends StatelessWidget {
  const AssetCard({
    super.key,
    required this.symbol,

    /// Shown next to the icon; defaults to [symbol]. Use [CoinModel.localizedCoinTicker] for Arabic.
    this.symbolLabel,
    required this.name,
    required this.amount,
    this.selectedCurrency,
    required this.currentPrice,
    this.icon,
    this.iconBackgroundColor,
    required this.onTap,
    this.networkIconUrl,
  });

  final String symbol;
  final String? symbolLabel;
  final String name;
  final String amount;
  final String? selectedCurrency;
  final String currentPrice;
  final Widget? icon;
  final Color? iconBackgroundColor;
  final VoidCallback onTap;
  final String? networkIconUrl;

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: 146,
      height: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(
            137.66 * 3.14159 / 180,
          ), // Convert deg to rad
          stops: const [0.0592, 1.9335],
          colors: const [Color(0xFF1C1C1E), Color(0xFF1A605B)],
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        mouseCursor: SystemMouseCursors.click,
        splashColor: AppColors.primaryColor.withAlpha(30),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            spacing: 12.0,
            children: [
              Row(
                spacing: 12,
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                mainAxisSize: .min,
                children: [
                  CommonCoinIcon(
                    symbol: symbol,
                    iconBackgroundColor: iconBackgroundColor,
                    fallbackIcon: icon,
                    networkIconUrl: networkIconUrl,
                    // Home assets card sits on a dark gradient regardless of
                    // theme, so the ETH icon image's near-white plate already
                    // has plenty of contrast — skip the brand-blue treatment
                    // we apply elsewhere in light mode.
                    useEthLightBrandBg: false,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      mainAxisAlignment: .center,
                      mainAxisSize: .min,
                      children: [
                        Text(
                          symbolLabel ?? symbol,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .center,
                  mainAxisSize: .max,
                  spacing: 2,
                  children: [
                    Text(
                      amount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      '≈ ${selectedCurrency ?? ''} $currentPrice',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLightGrey,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
