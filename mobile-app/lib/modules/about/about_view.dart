import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extentions/context_extensions.dart';
import '../../core/theme/theme.dart';
import '../../routes/app_router.dart';
import '../../widgets/common_back_button.dart';
import '../../widgets/common_expandable_text.dart';
import 'widgets/about_menu_item.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final screenWidth = context.width;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(onPressed: () => GoRouter.of(context).pop()),
        title: Text(
          l10n.aboutOmlapay,
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
              l10n.whoIsOmlapay,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.textWhite
                    : AppColors.textGrey,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            CommonExpandableText(
              text: l10n.aboutOmlapayDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.textWhite
                    : AppColors.textGrey,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Divider(thickness: 1, color: AppColors.iconWhite),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            AboutMenuItem(
              title: l10n.faqs,
              onTap: () => GoRouter.of(context).push(Routes.faqs),
            ),
            AboutMenuItem(
              title: l10n.termsAndConditions,
              onTap: () => GoRouter.of(context).push(Routes.termsAndConditions),
            ),
            AboutMenuItem(
              title: l10n.privacyPolicy,
              onTap: () => GoRouter.of(context).push(Routes.privacyPolicy),
            ),
          ],
        ),
      ),
    );
  }
}
