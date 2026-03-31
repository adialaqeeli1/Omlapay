import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/theme.dart';
import '../providers/login_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common_back_button.dart';
import '../../../widgets/privacy_policy_dialog.dart';
import '../../../widgets/terms_of_services_dialog.dart';

class LoginOrRegisterScreen extends StatelessWidget {
  const LoginOrRegisterScreen({super.key});

  static bool _isRegisterMode(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    if (extra is! Map<String, dynamic>) return false;
    return extra[LoginProvider.extraModeKey] == LoginProvider.modeRegister;
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = _isRegisterMode(context);
    final loginProvider = context.watch<LoginProvider>();
    final l10n = context.l10n!;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    final subtitleColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.58 : 0.45,
    );
    final mutedTextColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.48 : 0.58,
    );
    final indicatorInactiveColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.16 : 0.20,
    );
    final phoneGroupBackground = isDark
        ? AppColors.darkCardColor.withValues(alpha: 0.92)
        : theme.colorScheme.onSurface.withValues(alpha: 0.05);
    final phoneFieldBorderColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.16 : 0.10,
    );
    final continueDisabledColor = AppColors.primaryColor.withValues(
      alpha: isDark ? 0.45 : 0.50,
    );
    final continueTextColor = loginProvider.canContinue
        ? AppColors.white
        : theme.colorScheme.onSurface.withValues(alpha: 0.48);

    return Scaffold(
      appBar: AppBar(
        leading: context.canPop() ? CommonBackButton() : null,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (context.canPop()) const SizedBox(height: 20),
                    if (!context.canPop()) const SizedBox(height: 44),
                    Row(
                      children: [
                        ...List.generate(isRegister ? 4 : 2, (index) {
                          final isActive = index == 0;
                          final count = isRegister ? 4 : 2;
                          return Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: index < count - 1 ? 4 : 0,
                            ),
                            child: Container(
                              width: isActive ? 44 : 14,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primaryColor
                                    : indicatorInactiveColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      isRegister
                          ? l10n.welcomeToOmlapayLetsGetStarted
                          : l10n.welcomeBackToOmlapay,
                      style: GoogleFonts.poppinsTextTheme().displaySmall
                          ?.copyWith(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            height: 1.24,
                            color: theme.colorScheme.onSurface,
                          ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isRegister
                          ? l10n.pleaseEnterYourDataToReceiveVerificationCodes
                          : l10n.pleaseEnterYourNumberAndPasscodeToLogin,
                      style: GoogleFonts.poppinsTextTheme().titleMedium
                          ?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: subtitleColor,
                            height: 1.35,
                          ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode: true,
                              onSelect: (Country country) {
                                loginProvider.updateCountry(country);
                              },
                              countryListTheme: CountryListThemeData(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                backgroundColor: theme.scaffoldBackgroundColor,
                                textStyle: theme.textTheme.titleMedium,
                                searchTextStyle: theme.textTheme.bodyLarge,
                              ),
                            );
                          },
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: phoneGroupBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  loginProvider.currentFlagEmoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  loginProvider.currentPhoneCode,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: phoneFieldBorderColor,
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: TextField(
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              maxLength: 15,
                              onChanged: loginProvider.onPhoneChanged,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(15),
                              ],
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 25 / 1.35,
                                fontWeight: FontWeight.w400,
                                color: theme.colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                hintText: l10n.phoneNumber,
                                hintStyle: theme.textTheme.titleMedium
                                    ?.copyWith(
                                      fontSize: 25 / 1.35,
                                      fontWeight: FontWeight.w400,
                                      color: mutedTextColor,
                                    ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loginProvider.canContinue
                            ? () => loginProvider.onContinuePressed(
                                context,
                                isRegister: isRegister,
                              )
                            : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primaryColor,
                          disabledBackgroundColor: continueDisabledColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          l10n.continueAction,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: continueTextColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          context.push(
                            Routes.loginOrRegister,
                            extra: <String, String>{
                              LoginProvider.extraModeKey: isRegister
                                  ? LoginProvider.modeHardLogin
                                  : LoginProvider.modeRegister,
                            },
                          );
                        },
                        child: Text(
                          isRegister
                              ? l10n.alreadyHaveAccountLogin
                              : l10n.dontHaveAccountSignUp,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _LoginFooterAgreementText(
                          l10n: l10n,
                          theme: theme,
                          mutedTextColor: mutedTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginFooterAgreementText extends StatefulWidget {
  const _LoginFooterAgreementText({
    required this.l10n,
    required this.theme,
    required this.mutedTextColor,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final Color mutedTextColor;

  @override
  State<_LoginFooterAgreementText> createState() =>
      _LoginFooterAgreementTextState();
}

class _LoginFooterAgreementTextState extends State<_LoginFooterAgreementText> {
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
    final l10n = widget.l10n;
    final theme = widget.theme;
    _termsTap.onTap = () => showTermsOfServicesDialog(context);
    _privacyTap.onTap = () => showPrivacyPolicyDialog(context);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: widget.mutedTextColor,
          height: 1.4,
        ),
        children: [
          TextSpan(text: '${l10n.byCreatingAnAccountIAgreeToMushafars} '),
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
