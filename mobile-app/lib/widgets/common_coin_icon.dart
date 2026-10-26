import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:omlapay_mobile_app/widgets/common_loading_indicator.dart';

import '../core/utils/utility.dart';

class CommonCoinIcon extends StatelessWidget {
  const CommonCoinIcon({
    super.key,
    this.fallbackIcon,
    this.iconBackgroundColor,
    required this.symbol,
    this.radius,
  });

  final Widget? fallbackIcon;
  final Color? iconBackgroundColor;
  final String symbol;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: iconBackgroundColor,
      radius: radius,
      child: CachedNetworkImage(
        imageUrl: Utility.getCryptoCoinIconFromSymbol(symbol),
        progressIndicatorBuilder: (context, url, progress) =>
            CommonLoadingIndicator(value: progress.progress),
        errorWidget: (context, url, error) => fallbackIcon ?? Icon(Icons.image),
      ),
    );
  }
}
