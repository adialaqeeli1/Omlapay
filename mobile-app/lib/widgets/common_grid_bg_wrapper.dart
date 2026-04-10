import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:omlapay_mobile_app/widgets/common_transparent_card.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';
import '../modules/auth/providers/login_provider.dart';
import '../routes/app_router.dart';

class CommonGridBgWrapper extends StatelessWidget {
  const CommonGridBgWrapper({
    super.key,
    required this.child,
    required this.headerTitle,
    required this.headerSubTitle,
    required this.horizontalPadding,
    this.headerChild,
    this.bottomWidget,
    this.appBarButtons,
    this.appBarLeading,
    this.appBarLeadingWidth,
    this.applyHorizontalPaddingToHeaderButtonsOnly = false,
  });

  final Widget child;
  final String headerTitle;
  final String headerSubTitle;
  final double horizontalPadding;
  final Widget? headerChild;
  final Widget? bottomWidget;
  final List<Widget>? appBarButtons;
  final Widget? appBarLeading;
  final double? appBarLeadingWidth;
  final bool applyHorizontalPaddingToHeaderButtonsOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            SliverOffstage(
              offstage: (appBarButtons ?? []).isNotEmpty == false,
              sliver: SliverAppBar(
                leading: appBarLeading,
                leadingWidth: appBarLeadingWidth,
                automaticallyImplyLeading: false,
                actions: appBarButtons,
                iconTheme: context.theme.iconTheme,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: context.isDarkMode
                      ? Brightness.light
                      : Brightness.dark,
                ),
              ),
            ),
            SliverSafeArea(
              top: false,
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverPersistentHeader(
                    delegate: _CommonGridBgWrapperDelegate(
                      headerTitle: headerTitle,
                      headerSubTitle: headerSubTitle,
                      headerChild: headerChild,
                      bottomWidget: bottomWidget,
                      horizontalPadding: horizontalPadding,
                    ),
                  ),
                  SliverPadding(
                    padding: applyHorizontalPaddingToHeaderButtonsOnly
                        ? EdgeInsets.zero
                        : EdgeInsets.symmetric(horizontal: horizontalPadding),
                    sliver: SliverFillRemaining(
                      hasScrollBody: false,
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommonGridBgWrapperDelegate extends SliverPersistentHeaderDelegate {
  const _CommonGridBgWrapperDelegate({
    required this.headerTitle,
    required this.headerSubTitle,
    this.headerChild,
    this.bottomWidget,
    required this.horizontalPadding,
  });

  final String headerTitle;
  final String headerSubTitle;
  final Widget? headerChild;
  final Widget? bottomWidget;
  final double horizontalPadding;

  @override
  double get maxExtent => bottomWidget != null ? 200 : 250;

  @override
  double get minExtent => 200;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final l10n = context.l10n!;
    return Hero(
      tag: 'grid_bg',
      transitionOnUserGestures: true,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          Positioned.directional(
            top: 0,
            start: 0,
            end: 0,
            height: maxExtent / (bottomWidget != null ? 1.2 : 1.5),
            textDirection: context.textDirection,
            child: SvgPicture.asset(
              'assets/icons/grid_bg.svg',
              fit: BoxFit.fill,
              alignment: Alignment.topCenter,
            ),
          ),
          if (headerChild != null)
            Positioned(
              top: -5,
              left: 0,
              right: 0,
              height: maxExtent - (bottomWidget != null ? 100 : 150),
              child: Center(child: headerChild),
            ),

          Positioned.directional(
            bottom: 0,
            start: 0,
            end: 0,
            textDirection: context.textDirection,
            child: CommonTransparentCard(
              padding: EdgeInsets.zero,
              borderRadius: 0,
              glassColor: context.theme.scaffoldBackgroundColor,
              blurSigma: 0,
              opacity: context.isDarkMode ? 0.40 : 0.90,
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: horizontalPadding,
                ),
                child:
                    bottomWidget ??
                    Row(
                      mainAxisSize: .min,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6,
                            children: [
                              Text(
                                headerTitle,
                                style: context.textTheme.headlineLarge
                                    ?.copyWith(
                                      color: context.isDarkMode
                                          ? AppColors.white
                                          : AppColors.textBlack,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                              ),
                              Text(
                                headerSubTitle,
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.isDarkMode
                                      ? AppColors.textGrey
                                      : AppColors.textLightGrey,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 12,
                          children: [
                            _buildHeaderButton(
                              context,
                              label: l10n.login,
                              backgroundColor: const Color(0xFF333333),
                              textColor: Colors.white,
                              onTap: () => context.push(
                                Routes.loginOrRegister,
                                extra: <String, String>{
                                  LoginProvider.extraModeKey:
                                      LoginProvider.modeHardLogin,
                                },
                              ),
                            ),

                            _buildHeaderButton(
                              context,
                              label: l10n.register,
                              backgroundColor: AppColors.primaryColor,
                              textColor: Colors.white,
                              onTap: () => context.push(
                                Routes.loginOrRegister,
                                extra: <String, String>{
                                  LoginProvider.extraModeKey:
                                      LoginProvider.modeRegister,
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(
    BuildContext context, {
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16), // Rounded corners
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: MaterialButton(
        onPressed: onTap,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
        minWidth: 130,
        height: 45,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Text(
          label,
          style: context.textTheme.bodyLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
