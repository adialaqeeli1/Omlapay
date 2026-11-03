import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:omlapay_mobile_app/core/extentions/context_extensions.dart';
import 'package:omlapay_mobile_app/widgets/common_loading_indicator.dart';

import '../core/theme/theme.dart';
import '../core/utils/utility.dart';

class CommonCoinIcon extends StatelessWidget {
  const CommonCoinIcon({
    super.key,
    this.fallbackIcon,
    this.iconBackgroundColor,
    required this.symbol,
    this.radius,
    this.networkIconUrl,
    this.useEthLightBrandBg = true,
  });

  final Widget? fallbackIcon;
  final Color? iconBackgroundColor;
  final String symbol;
  final double? radius;
  final String? networkIconUrl;

  /// When true (default), light-mode ETH icons get the Ethereum brand blue
  /// (#627EEA) as a background instead of the icon image's near-white plate
  /// — which otherwise disappears into the white scaffold. Set to `false`
  /// on surfaces that already have their own contrast (e.g. the home
  /// `AssetCard`, which sits on a dark gradient).
  final bool useEthLightBrandBg;

  @override
  Widget build(BuildContext context) {
    final bool isUSDCORUSDT = symbol == 'USDT' || symbol == 'USDC';
    final bool showNetworkIcon = networkIconUrl != null && !isUSDCORUSDT;

    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final bool applyEthLightFix =
        useEthLightBrandBg && isLight && symbol.toUpperCase() == 'ETH';

    final avatar = CircleAvatar(
      backgroundColor: iconBackgroundColor,
      radius: radius,
      child: CachedNetworkImage(
        imageUrl: showNetworkIcon
            ? (networkIconUrl ?? Utility.getCryptoCoinIconFromSymbol(symbol))
            : Utility.getCryptoCoinIconFromSymbol(symbol),
        progressIndicatorBuilder: (context, url, progress) =>
            CommonLoadingIndicator(value: progress.progress),
        errorWidget: (context, url, error) => fallbackIcon ?? Icon(Icons.image),
      ),
    );

    if (!applyEthLightFix) return avatar;

    // The ETH icon image ships with an opaque white circular plate that
    // covers `CircleAvatar.backgroundColor`, so tinting the avatar itself
    // does nothing visible. Wrap it in a brand-blue padded circle so a
    // 2 px ring is painted *around* the plate instead — that's what
    // makes ETH legible on the white scaffold in light mode. Adds ~4 px
    // to the outer diameter only when the fix applies.
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.darkBackground, //Todo: Maybe need to update later
        shape: BoxShape.circle,
      ),
      child: avatar,
    );
  }
}
