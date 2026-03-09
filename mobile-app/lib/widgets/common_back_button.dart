import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';

class CommonBackButton extends StatelessWidget {
  const CommonBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => context.pop(),
      icon: SvgPicture.asset(
        context.textDirection == TextDirection.rtl
            ? 'assets/icons/arrow_forward.svg'
            : 'assets/icons/arrow_back.svg',
        colorFilter: ColorFilter.mode(
          context.isDarkMode ? AppColors.white : AppColors.darkSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
