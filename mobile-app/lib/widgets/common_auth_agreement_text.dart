import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';
import '../routes/app_router.dart';

/// Centered, two-line "By creating an account I agree to Mushafar's
/// Terms of Service and Privacy Policy" line shown on the login/register
/// screen and the phone verification screens. The Terms and Privacy spans
/// are tappable and push to their respective routes.
class CommonAuthAgreementText extends StatefulWidget {
  const CommonAuthAgreementText({super.key});

  @override
  State<CommonAuthAgreementText> createState() =>
      _CommonAuthAgreementTextState();
}

class _CommonAuthAgreementTextState extends State<CommonAuthAgreementText> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer();
    _privacyTap = TapGestureRecognizer();
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;
    final mutedTextColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.48 : 0.58,
    );

    _termsTap.onTap = () => context.push(Routes.termsAndConditions);
    _privacyTap.onTap = () => context.push(Routes.privacyPolicy);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: mutedTextColor,
          height: 1.4,
        ),
        children: [
          TextSpan(text: '${l10n.byCreatingAnAccountIAgreeToMushafars}\n'),
          TextSpan(
            text: l10n.termsOfService,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
            recognizer: _termsTap,
          ),
          TextSpan(text: ' ${l10n.andWord} '),
          TextSpan(
            text: l10n.privacyPolicy,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
            recognizer: _privacyTap,
          ),
        ],
      ),
    );
  }
}
