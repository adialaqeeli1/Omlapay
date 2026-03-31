import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/extentions/context_extensions.dart';
import '../core/theme/theme.dart';
import '../routes/app_router.dart';
import '../modules/kyc_verification/utils/kyc_verification_entry_source.dart';

/// Shared warning banner when the user must complete KYC before using
/// send / receive / swap (or similar) flows.
class KycVerificationRequiredBanner extends StatelessWidget {
  const KycVerificationRequiredBanner({
    super.key,
    required this.messageBody,
    required this.entrySource,
  });

  /// Localized sentence before the “Verify now” action (includes trailing space if needed).
  final String messageBody;

  /// Screen that surfaced this banner (used for KYC flow analytics / return context).
  final KycVerificationEntrySource entrySource;

  static const TextStyle _baseStyle = TextStyle(
    color: AppColors.textWhite,
    fontSize: 13,
    height: 1.4,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kycVerificationBannerBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kycVerificationBannerBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.textWhite, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: _baseStyle,
                children: [
                  TextSpan(text: messageBody),
                  WidgetSpan(
                    child: InkWell(
                      onTap: () {
                        context.push(
                          Routes.kycVerification,
                          extra: entrySource,
                        );
                      },
                      child: Text(
                        l10n.verifyNowButton,
                        style: _baseStyle.copyWith(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
