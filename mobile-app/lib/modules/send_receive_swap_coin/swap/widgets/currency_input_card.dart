import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_coin_icon.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';

class CurrencyInputCard extends StatelessWidget {
  final String title;

  /// Latin ticker (e.g. BTC) for icons and [CommonCoinIcon]; must stay English.
  final String coinSymbol;

  /// Optional display label (e.g. Arabic `symbol_ar`); defaults to [coinSymbol].
  final String? coinSymbolLabel;
  final String amount;
  final ValueChanged<String>? onAmountChanged;
  final VoidCallback? onMaxPressed;
  final VoidCallback? onCoinTap;
  final bool isFrom;
  final String? errorText;
  final TextEditingController? controller;
  final bool hasBorder;
  final String? networkIconUrl;

  const CurrencyInputCard({
    super.key,
    required this.title,
    required this.coinSymbol,
    this.coinSymbolLabel,
    this.amount = '',
    this.onAmountChanged,
    this.onMaxPressed,
    this.onCoinTap,
    this.isFrom = true,
    this.errorText,

    this.controller,
    this.hasBorder = false,
    this.readOnly = false,
    required this.networkIconUrl,
  });

  final bool readOnly;

  static const double _cardRadius = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displaySymbol = coinSymbol;

    final fieldFill = isDark
        ? colorScheme.surfaceContainerHighest
        : AppColors.swapFieldFillLight;

    final Border? fieldBorder = errorText != null
        ? Border.all(color: colorScheme.error, width: 1)
        : hasBorder
        ? Border.all(color: AppColors.tealColor, width: 1)
        : isDark
        ? Border.all(color: colorScheme.outlineVariant, width: 1)
        : null;
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
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            if (isFrom)
              Text(
                l10n.availableBalanceFormatted(amount, displaySymbol),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: fieldBorder,
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
                            networkIconUrl: networkIconUrl,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            displaySymbol,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      controller: controller,
                      onChanged: onAmountChanged,
                      readOnly: readOnly,
                      cursorColor: AppColors.tealColor,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: readOnly && !isDark
                            ? AppColors.textGrey
                            : colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: l10n.amountInputHint,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
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
                  if (isFrom && onMaxPressed != null) ...[
                    Container(
                      margin: const EdgeInsetsDirectional.only(start: 8),
                      width: 1,
                      height: 28,
                      color: colorScheme.outlineVariant,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: GestureDetector(
                        onTap: onMaxPressed,
                        child: Text(
                          l10n.swapMaxAction,
                          style: const TextStyle(
                            color: AppColors.tealColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
