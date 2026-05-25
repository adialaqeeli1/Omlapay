import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/extentions/context_extensions.dart';
import '../../core/utils/content_link_launcher.dart';
import '../../widgets/common_back_button.dart';
import '../../widgets/common_loading_indicator.dart';
import '../../widgets/markdown_html_view.dart';
import 'providers/privacy_policy_provider.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return ChangeNotifierProvider(
      key: ValueKey('privacy-$language'),
      create: (_) => PrivacyPolicyProvider(language: language),
      child: const _PrivacyPolicyBody(),
    );
  }
}

class _PrivacyPolicyBody extends StatelessWidget {
  const _PrivacyPolicyBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    final provider = context.watch<PrivacyPolicyProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(onPressed: () => GoRouter.of(context).pop()),
        title: Text(
          l10n.privacyPolicy,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(context, provider, horizontalPadding),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PrivacyPolicyProvider provider,
    double horizontalPadding,
  ) {
    if (provider.isLoading && !provider.hasContent) {
      return const Center(
        child: SizedBox.square(dimension: 48, child: CommonLoadingIndicator()),
      );
    }

    if (provider.hasError && !provider.hasContent) {
      return _PrivacyError(
        message: provider.errorMessage,
        onRetry: provider.retry,
        horizontalPadding: horizontalPadding,
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ).add(EdgeInsets.only(bottom: context.mediaQuery.viewPadding.bottom)),
      child: MarkdownHtmlView(
        data: provider.content ?? '',
        textScale: 0.85,
        headingScale: 0.75,
        onLinkTap: (url) => launchContentLink(context, url),
      ),
    );
  }
}

class _PrivacyError extends StatelessWidget {
  const _PrivacyError({
    required this.message,
    required this.onRetry,
    required this.horizontalPadding,
  });

  final String? message;
  final VoidCallback onRetry;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final displayMessage = (message != null && message!.trim().isNotEmpty)
        ? message!
        : l10n.requestFailed;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ],
        ),
      ),
    );
  }
}
