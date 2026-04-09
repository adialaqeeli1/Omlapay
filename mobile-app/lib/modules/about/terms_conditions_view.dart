import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extentions/context_extensions.dart';
import '../../widgets/common_back_button.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

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
          l10n.termsAndConditions,
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
              l10n.termsAndConditionsContent,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
