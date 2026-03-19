import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/common_back_button.dart';
import 'widgets/help_center_menu_item.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(onPressed: () => GoRouter.of(context).pop()),
        title: Text(
          l10n.helpCenter,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Text(
              l10n.howCanWeHelpYouToday,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.textWhite
                    : AppColors.textBlack,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            _buildMenuGroup(
              context,
              title: l10n.supportRequests,
              children: [
                HelpCenterMenuItem(
                  title: l10n.sendRequest,
                  onTap: () => GoRouter.of(context).push(Routes.sendRequest),
                ),
                HelpCenterMenuItem(
                  title: l10n.pastRequests,
                  onTap: () => GoRouter.of(context).push(Routes.pastRequests),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textLightGrey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
