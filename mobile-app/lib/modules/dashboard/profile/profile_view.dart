import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/theme/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../kyc_verification/utils/kyc_verification_entry_source.dart';
import '../../../widgets/common_grid_bg_wrapper.dart';
import '../../../widgets/theme_aware_icon.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding =
        screenWidth * 0.05; // 5% padding for responsiveness
    final authState = context.watch<AuthProvider>().state;
    final bool isAuthenticated = authState.isAuthenticated;
    final user = authState.user;

    return CommonGridBgWrapper(
      horizontalPadding: horizontalPadding,
      headerSubTitle: l10n.fundsSafeSecure,
      headerTitle: l10n.hello,
      bottomWidget: isAuthenticated && user != null
          ? _buildAuthenticatedHeader(
              context: context,
              phoneNumber: user.fullPhoneNumber,
              screenWidth: screenWidth,
              horizontalPadding: horizontalPadding,
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(thickness: 1),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                if (isAuthenticated) ...[
                  _buildKycMenuItem(
                    context: context,
                    horizontalPadding: horizontalPadding,
                  ),
                ],
                if (!isAuthenticated)
                  _buildMenuItem(
                    context: context,
                    iconPath: 'assets/icons/general_settings_icon.svg',
                    title: l10n.generalSettings,
                    horizontalPadding: horizontalPadding,
                    onTap: () => GoRouter.of(context).push(Routes.settings),
                  ),
                _buildMenuItem(
                  context: context,
                  iconPath: 'assets/icons/about_icon.svg',
                  title: l10n.aboutOmlapay,
                  horizontalPadding: horizontalPadding,
                  onTap: () => GoRouter.of(context).push(Routes.about),
                ),
                _buildMenuItem(
                  context: context,
                  iconPath: 'assets/icons/help_center_icon.svg',
                  title: l10n.helpCenter,
                  horizontalPadding: horizontalPadding,
                  onTap: () => GoRouter.of(context).push(Routes.helpCenter),
                ),
                if (isAuthenticated)
                  _buildLogoutMenuItem(
                    context: context,
                    horizontalPadding: horizontalPadding,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    required double horizontalPadding,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 0.14; // Big circle size
    final iconSize = screenWidth * 0.06; // Smaller icon size
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final circleColor = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFE8E8E8);
    final iconColor = theme.iconTheme.color ?? Colors.black;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return ListTile(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      splashColor: AppColors.primaryColor.withAlpha(40),
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      leading: Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 6.0),
        child: SizedBox(
          width: circleSize,
          height: circleSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 18,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildKycMenuItem({
    required BuildContext context,
    required double horizontalPadding,
  }) {
    final l10n = context.l10n!;
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 0.14;
    final iconSize = screenWidth * 0.06;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final circleColor = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFE8E8E8);
    final iconColor = theme.iconTheme.color ?? Colors.black;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return ListTile(
      onTap: () => context.push(
        Routes.kycVerification,
        extra: KycVerificationEntrySource.profile,
      ),
      mouseCursor: SystemMouseCursors.click,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      splashColor: AppColors.primaryColor.withAlpha(40),
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      leading: Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 6.0),
        child: SizedBox(
          width: circleSize,
          height: circleSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.verified_user,
                size: iconSize,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Text(
            l10n.kycVerification,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 18,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      trailing: Icon(Icons.open_in_new, size: 18, color: iconColor),
    );
  }

  Widget _buildLogoutMenuItem({
    required BuildContext context,
    required double horizontalPadding,
  }) {
    final l10n = context.l10n!;
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 0.14;
    final iconSize = screenWidth * 0.06;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final circleColor = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFE8E8E8);

    return ListTile(
      onTap: () async {
        await context.read<AuthProvider>().logout();
        if (context.mounted) {
          GoRouter.of(context).push(Routes.loginOrRegister);
        }
      },
      mouseCursor: SystemMouseCursors.click,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      splashColor: Colors.red.withAlpha(40),
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      leading: Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 6.0),
        child: SizedBox(
          width: circleSize,
          height: circleSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.logout, size: iconSize, color: Colors.red),
            ),
          ),
        ),
      ),
      title: Text(
        l10n.logout,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 18,
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAuthenticatedHeader({
    required BuildContext context,
    required String phoneNumber,
    required double screenWidth,
    required double horizontalPadding,
  }) {
    final iconSize = screenWidth * 0.08;
    final iconPadding = screenWidth * 0.02;

    return Row(
      children: [
        Expanded(
          child: Text(
            phoneNumber,
            textDirection: TextDirection.ltr,
            style: context.textTheme.headlineLarge?.copyWith(
              color: context.isDarkMode ? AppColors.white : AppColors.textBlack,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => GoRouter.of(context).push(Routes.settings),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.all(iconPadding),
              child: ThemeAwareIcon(
                assetPath: 'assets/icons/general_settings_icon.svg',
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
