import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../widgets/common_attachment_field.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/common_button.dart';
import '../../../widgets/common_form_label.dart';
import '../../../widgets/common_loading_indicator.dart';
import '../providers/send_request_provider.dart';

class SendRequestView extends StatelessWidget {
  const SendRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    final provider = context.watch<SendRequestProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(onPressed: () => GoRouter.of(context).pop()),
        title: Text(
          l10n.sendRequest,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ReactiveForm(
        formGroup: provider.form,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              CommonFormLabel(label: l10n.title),
              const SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'title',
                maxLength: 50,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onEditingComplete: (control) =>
                    provider.form.control('description').focus(),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: l10n.titlePlaceholder,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.35),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.35),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => l10n.pleaseEnterATitle,
                  ValidationMessage.maxLength: (_) =>
                      l10n.titleMustNotExceedCharacters(50),
                },
              ),
              const SizedBox(height: 24),
              CommonFormLabel(label: l10n.description),
              const SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'description',
                maxLines: 5,
                maxLength: 200,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onEditingComplete: (control) =>
                    FocusScope.of(context).unfocus(),
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: l10n.descriptionPlaceholder,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.35),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.35),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) =>
                      l10n.pleaseEnterADescription,
                  ValidationMessage.maxLength: (_) =>
                      l10n.descriptionMustNotExceedCharacters(200),
                },
              ),
              // Attachments require the authenticated upload endpoint, so
              // hide the picker for guests — they can still submit the
              // request via the guest endpoint without a file.
              if (!provider.isGuest) ...[
                const SizedBox(height: 24),
                CommonFormLabel(label: l10n.attachment),
                const SizedBox(height: 8),
                CommonAttachmentField(
                  onTap: () async {
                    try {
                      await provider.pickFile();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.errorPickingFile('$e'))),
                        );
                      }
                    }
                  },
                  selectedFile: provider.selectedFile,
                  allowedExtensions: SendRequestProvider.allowedExtensions,
                  placeholder: l10n.attachFileDescription(
                    SendRequestProvider.allowedExtensions
                        .map((e) => e.toUpperCase())
                        .join(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? ' أو '
                              : ', ',
                        ),
                  ),
                ),
              ],
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              CommonButton(
                onPressed: () {
                  if (provider.isSending) return;
                  FocusScope.of(context).unfocus();

                  final navigator = Navigator.of(context, rootNavigator: true);
                  final barrierColor = theme.colorScheme.scrim.withValues(
                    alpha: 0.45,
                  );

                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: barrierColor,
                    useRootNavigator: true,
                    builder: (_) => PopScope(
                      canPop: false,
                      child: Center(
                        child: Material(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const SizedBox.square(
                            dimension: 60,
                            child: CommonLoadingIndicator(),
                          ),
                        ),
                      ),
                    ),
                  );

                  provider.send().then((success) {
                    if (navigator.mounted) navigator.pop();
                    if (!context.mounted) return;
                    if (success) {
                      SnackbarHelper.showSuccess(
                        context,
                        l10n.helpRequestSentSuccess,
                      );
                      GoRouter.of(context).pop();
                    } else if (provider.errorKey != null) {
                      SnackbarHelper.showError(
                        context,
                        AppException.resolveErrorKey(
                              l10n,
                              provider.errorKey!,
                            ) ??
                            l10n.unknownError,
                      );
                    }
                  });
                },
                title: l10n.send,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
