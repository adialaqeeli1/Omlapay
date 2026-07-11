import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/extentions/context_extensions.dart';
import '../../core/models/faq_model/faq_model.dart';
import '../../widgets/common_back_button.dart';
import '../../widgets/common_loading_indicator.dart';
import 'providers/faqs_provider.dart';

class FAQsView extends StatelessWidget {
  const FAQsView({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return ChangeNotifierProvider(
      key: ValueKey('faqs-$language'),
      create: (_) => FaqsProvider(language: language),
      child: const _FaqsBody(),
    );
  }
}

class _FaqsBody extends StatelessWidget {
  const _FaqsBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    final provider = context.watch<FaqsProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(onPressed: () => GoRouter.of(context).pop()),
        title: Text(
          l10n.faqs,
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
    FaqsProvider provider,
    double horizontalPadding,
  ) {
    if (provider.isLoading && !provider.hasContent) {
      return const Center(
        child: SizedBox.square(dimension: 48, child: CommonLoadingIndicator()),
      );
    }

    if (provider.hasError && !provider.hasContent) {
      return _FaqsError(
        message: provider.errorMessage,
        onRetry: provider.retry,
        horizontalPadding: horizontalPadding,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      itemCount: provider.faqs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _FaqTile(faq: provider.faqs[i]),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final FaqModel faq;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 12,
            top: 4,
            bottom: 4,
          ),
          childrenPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: scheme.onSurface,
          collapsedIconColor: scheme.onSurface,
          title: Text(
            faq.question,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          children: [
            Text(
              faq.answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqsError extends StatelessWidget {
  const _FaqsError({
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
