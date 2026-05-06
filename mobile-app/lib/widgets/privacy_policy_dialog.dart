import 'package:flutter/material.dart';

import '../core/extentions/context_extensions.dart';
import '../core/services/legal_service.dart';
import '../core/theme/theme.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/snackbar_helper.dart';
import 'common_loading_indicator.dart';
import 'markdown_html_view.dart';

/// Fetches privacy policy markdown from the API, shows a loading overlay, then
/// a centered dialog with rendered content, or a snackbar on failure.
Future<void> showPrivacyPolicyDialog(BuildContext context) async {
  final l10n = context.l10n!;
  final theme = context.theme;
  final navigator = Navigator.of(context, rootNavigator: true);
  final barrierColor = theme.colorScheme.scrim.withValues(alpha: 0.45);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: barrierColor,
    useRootNavigator: true,
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox.square(
              dimension: 60,
              child: CommonLoadingIndicator(),
            ),
          ),
        ),
      );
    },
  );

  await Future<void>.delayed(Duration.zero);
  if (!context.mounted) {
    if (navigator.mounted) navigator.pop();
    return;
  }
  final language = Localizations.localeOf(context).languageCode;

  try {
    final markdown = await LegalService.fetchPrivacyPolicy(language: language);

    if (!context.mounted) {
      if (navigator.mounted) navigator.pop();
      return;
    }
    navigator.pop();

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: barrierColor,
      useRootNavigator: true,
      builder: (dialogContext) {
        final dialogTheme = Theme.of(dialogContext);
        final size = MediaQuery.sizeOf(dialogContext);

        return Dialog(
          backgroundColor: dialogTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: size.width * 0.9,
            height: size.height * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 12, 8),
                  child: Text(
                    l10n.privacyPolicy,
                    textAlign: TextAlign.start,
                    style: dialogTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: dialogTheme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MarkdownHtmlView(
                        data: markdown,
                        selectable: true,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } catch (e) {
    if (navigator.mounted) {
      navigator.pop();
    }
    if (!context.mounted) return;

    final message = e is AppException ? e.localizedMessage(l10n) : l10n.unknownError;
    SnackbarHelper.showError(context, message);
  }
}
