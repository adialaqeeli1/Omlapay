part of '../dashboard_view.dart';

// Breakpoint for tablets (typically 600dp or more)
const double _tabletBreakpoint = 600;

class _BottomNavbar extends StatelessWidget {
  const _BottomNavbar();

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFF2F2F2);
    final l10n = context.l10n!;

    // Responsive sizing based on screen width - use MediaQuery to avoid rebuilds
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= _tabletBreakpoint;

    // Responsive dimensions
    final height = isTablet ? 90.0 : 70.0;
    final iconSize = isTablet ? 28.0 : 24.0;
    final fontSize = isTablet ? 14.0 : 12.0;
    final spacing = isTablet ? 6.0 : 4.0;
    final padding = isTablet
        ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
        : EdgeInsets.zero;

    return SizedBox(
      height: height,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              key: const ValueKey('home_nav'),
              iconPath: 'assets/icons/home_icon.svg',
              label: l10n.home,
              route: Routes.home,
              isActive: currentLocation == Routes.home,
              iconSize: iconSize,
              fontSize: fontSize,
              spacing: spacing,
            ),
            _NavItem(
              key: const ValueKey('history_nav'),
              iconPath: 'assets/icons/history_icon.svg',
              label: l10n.history,
              route: Routes.history,
              isActive: currentLocation == Routes.history,
              iconSize: iconSize,
              fontSize: fontSize,
              spacing: spacing,
              requiresAuth: true,
            ),
            _NavItem(
              key: const ValueKey('profile_nav'),
              iconPath: 'assets/icons/profile_icon.svg',
              label: l10n.profile,
              route: Routes.profile,
              isActive: currentLocation == Routes.profile,
              iconSize: iconSize,
              fontSize: fontSize,
              spacing: spacing,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final String route;
  final bool isActive;
  final double iconSize;
  final double fontSize;
  final double spacing;
  final bool requiresAuth;

  const _NavItem({
    super.key,
    required this.iconPath,
    required this.label,
    required this.route,
    required this.isActive,
    required this.iconSize,
    required this.fontSize,
    required this.spacing,
    this.requiresAuth = false,
  });

  void _handleTap(BuildContext context) {
    if (requiresAuth) {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.state.isAuthenticated) {
        _showLoginDialog(context);
        return;
      }
    }
    GoRouter.of(context).push(route);
  }

  void _showLoginDialog(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.loginRequired,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Text(
            l10n.pleaseLoginToContinue,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(Routes.loginOrRegister);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.login),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primaryColor : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () => _handleTap(context),
        mouseCursor: SystemMouseCursors.click,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              child: SvgPicture.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
              ),
            ),
            SizedBox(height: spacing),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
