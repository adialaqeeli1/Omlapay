import 'package:flutter/material.dart';
import 'package:omlapay_mobile_app/core/extentions/context_extensions.dart';
import 'package:omlapay_mobile_app/core/theme/theme.dart';

import 'common_coin_icon.dart';

class AssetCard extends StatelessWidget {
  const AssetCard({
    super.key,
    required this.symbol,
    required this.name,
    required this.amount,
    required this.valueInUsd,
    this.icon,
    this.iconBackgroundColor,
    required this.onTap,
  });

  final String symbol;
  final String name;
  final String amount;
  final String valueInUsd;
  final Widget? icon;
  final Color? iconBackgroundColor;
  final VoidCallback onTap;

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
            spacing: 16.0,
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
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      mainAxisAlignment: .center,
                      mainAxisSize: .min,
                      children: [
                        Text(
                          symbol,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          name,
                          overflow: TextOverflow.visible,
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
                  mainAxisSize: .min,
                  mainAxisAlignment: .center,
                  spacing: 4,
                  children: [
                    Text(
                      amount,
                      overflow: TextOverflow.visible,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      valueInUsd,
                      overflow: TextOverflow.visible,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLightGrey,
                        fontSize: 14,
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
