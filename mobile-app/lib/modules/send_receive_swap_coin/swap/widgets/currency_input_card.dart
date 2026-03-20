import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_coin_icon.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';

class CurrencyInputCard extends StatelessWidget {
  final String title;
  final String coinSymbol;
  final String amount;
  final ValueChanged<String>? onAmountChanged;
  final VoidCallback? onMaxPressed;
  final VoidCallback? onCoinTap;
  final bool isFrom;
  final String? errorText;
  final TextEditingController? controller;
  final bool hasBorder;

  const CurrencyInputCard({
    super.key,
    required this.title,
    required this.coinSymbol,
    this.amount = '',
    this.onAmountChanged,
    this.onMaxPressed,
    this.onCoinTap,
    this.isFrom = true,
    this.errorText,

    this.controller,
    this.hasBorder = false,
    this.readOnly = false,
  });

  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    Color? iconBackgroundColor;
    Widget? fallbackIcon;

    if (coinSymbol == 'USDT') {
      iconBackgroundColor = AppColors.usdtColor;
      fallbackIcon = const Icon(
        CryptoFontIcons.USDT,
        color: Colors.white,
        size: 24,
      );
    } else if (coinSymbol == 'ETH') {
      iconBackgroundColor = AppColors.textWhite;
      fallbackIcon = const Icon(
        CryptoFontIcons.ETH,
        color: Colors.black,
        size: 24,
      );
    } else if (coinSymbol == 'BTC') {
      iconBackgroundColor = AppColors.bitcoinColor;
      fallbackIcon = const Icon(
        CryptoFontIcons.BTC,
        color: Colors.white,
        size: 24,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            if (isFrom)
              Text(
                'Available $amount $coinSymbol',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2025),
            borderRadius: BorderRadius.circular(16),
            border: hasBorder
                ? Border.all(color: AppColors.tealColor, width: 1)
                : errorText != null
                ? Border.all(color: Colors.red, width: 1)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onCoinTap,
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          CommonCoinIcon(
                            symbol: coinSymbol,
                            iconBackgroundColor: iconBackgroundColor,
                            fallbackIcon: fallbackIcon,
                            radius: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            coinSymbol,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onAmountChanged,
                      readOnly: readOnly,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),
                  ),
                  // if (isFrom && onMaxPressed != null)
                  //   Padding(
                  //     padding: const EdgeInsets.only(left: 8.0),
                  //     child: GestureDetector(
                  //       onTap: onMaxPressed,
                  //       child: const Text(
                  //         'Max',
                  //         style: TextStyle(
                  //           color: AppColors.tealColor,
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 16,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: .0),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
