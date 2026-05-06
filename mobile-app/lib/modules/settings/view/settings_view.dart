import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/extentions/context_extensions.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/user_model/user_model.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../widgets/common_loading_indicator.dart';
import '../../../modules/auth/providers/login_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/common_back_button.dart';
import '../widgets/appearance_selection_widget.dart';
import '../widgets/language_selection_widget.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    // Re-fetch the notification setting every time Settings opens so the
    // toggle reflects the latest server state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationProvider>().refreshFromServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n!;
    final ThemeData theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(),
        title: Text(
          l10n.settings,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final bool isLoggedIn = authProvider.state.isAuthenticated;
          final UserModel? user = authProvider.state.user;
          final bool isKycVerified = user?.isVerified == true;

          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isLoggedIn) ...[
                  SizedBox(height: 16),
                  _buildMenuGroup(
                    context,
                    title: l10n.account,
                    childrens: [
                      _buildSimpleSettingOption(
                        context: context,
                        label: l10n.accountDetails,
                        screenWidth: screenWidth,
                        onTap: () {
                          GoRouter.of(context).push(Routes.accountDetails);
                        },
                      ),
                      if (isKycVerified) ...[
                        _buildSimpleSettingOption(
                          context: context,
                          label: l10n.changePhoneNumber,
                          screenWidth: screenWidth,
                          onTap: () {
                            GoRouter.of(context).push(Routes.changePhoneIntro);
                          },
                        ),

                        _buildSimpleSettingOption(
                          context: context,
                          label: l10n.changeEmail,
                          screenWidth: screenWidth,
                          onTap: () {
                            GoRouter.of(context).push(Routes.changeEmailIntro);
                          },
                        ),
                      ],
                      _buildSimpleSettingOption(
                        context: context,
                        label: l10n.changePasscode,
                        screenWidth: screenWidth,
                        onTap: () {
                          final user = authProvider.state.user;
                          if (user == null) return;
                          GoRouter.of(context).push(
                            Routes.enterOrSetPasscode,
                            extra: {
                              LoginProvider.extraModeKey:
                                  LoginProvider.modeChangePasscodeCurrent,
                              LoginProvider.extraCountryCodeKey:
                                  user.countryCode,
                              LoginProvider.extraPhoneNumberKey:
                                  user.mobileNumber,
                            },
                          );
                        },
                      ),
                      if (isKycVerified)
                        _buildNotificationToggle(
                          context: context,
                          label: l10n.twoFactorAuthentication,
                          screenWidth: screenWidth,
                          value: user?.twoFactorEnabled ?? false,
                          onChanged: (value) async {
                            // When enabling 2FA, check if user has an email first
                            if (value) {
                              final hasEmail =
                                  (user?.email?.trim() ?? '').isNotEmpty;
                              if (!hasEmail) {
                                final emailVerified = await GoRouter.of(
                                  context,
                                ).push<bool>(Routes.emailEntry);
                                if (!context.mounted || emailVerified != true) {
                                  return;
                                }
                              }
                            }

                            if (!context.mounted) return;

                            final navigator = Navigator.of(
                              context,
                              rootNavigator: true,
                            );
                            final barrierColor = theme.colorScheme.scrim
                                .withValues(alpha: 0.45);

                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: barrierColor,
                              useRootNavigator: true,
                              builder: (_) => PopScope(
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
                              ),
                            );

                            try {
                              final message = await authProvider
                                  .toggleTwoFactor(value);
                              if (navigator.mounted) navigator.pop();
                              if (context.mounted) {
                                SnackbarHelper.showSuccess(context, message);
                              }
                            } catch (e) {
                              if (navigator.mounted) navigator.pop();
                              if (context.mounted) {
                                SnackbarHelper.showError(
                                  context,
                                  e.toString().replaceAll('Exception: ', ''),
                                );
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ],
                SizedBox(height: 16),
                _buildMenuGroup(
                  context,
                  title: l10n.preferences,
                  childrens: [
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        String appearanceValue;
                        switch (themeProvider.themeMode) {
                          case ThemeMode.light:
                            appearanceValue = l10n.light;
                            break;
                          case ThemeMode.dark:
                            appearanceValue = l10n.dark;
                            break;
                          case ThemeMode.system:
                            appearanceValue = l10n.system;
                            break;
                        }
                        return _buildSettingOption(
                          context: context,
                          label: l10n.appearance,
                          value: appearanceValue,
                          screenWidth: screenWidth,
                          onTap: () => AppearanceSelectionWidget.show(context),
                        );
                      },
                    ),
                    Consumer<LocaleProvider>(
                      builder: (context, localeProvider, child) {
                        String languageValue;
                        if (localeProvider.locale.languageCode == 'ar') {
                          languageValue = l10n.arabic;
                        } else {
                          languageValue = l10n.english;
                        }
                        return _buildSettingOption(
                          context: context,
                          label: l10n.language,
                          value: languageValue,
                          screenWidth: screenWidth,
                          onTap: () => LanguageSelectionWidget.show(context),
                        );
                      },
                    ),
                    if (isLoggedIn)
                      Consumer<NotificationProvider>(
                        builder: (context, notificationProvider, child) {
                          return _buildNotificationToggle(
                            context: context,
                            label: l10n.notification,
                            screenWidth: screenWidth,
                            value: notificationProvider.notificationsEnabled,
                            onChanged: (value) async {
                              try {
                                await notificationProvider.toggleNotifications(
                                  value,
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  SnackbarHelper.showError(
                                    context,
                                    e.toString().replaceAll('Exception: ', ''),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingOption({
    required BuildContext context,
    required String label,
    required String value,
    required double screenWidth,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final iconColor = theme.iconTheme.color ?? theme.colorScheme.onSurface;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontStyle: FontStyle.normal,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppColors.textLightGrey,
              fontSize: 14,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: iconColor,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
      // title: Padding(
      //   padding: EdgeInsets.symmetric(vertical: verticalPadding),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Text(
      //         label,
      //         style: TextStyle(
      //           color: textColor,
      //           fontSize: screenWidth * 0.042,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //       Row(
      //         children: [
      //           Text(
      //             value,
      //             style: TextStyle(
      //               color: theme.colorScheme.onSurface.withOpacity(0.6),
      //               fontSize: screenWidth * 0.040,
      //               fontFamily: GoogleFonts.poppins().fontFamily,
      //               fontWeight: FontWeight.w400,
      //             ),
      //           ),
      //           const SizedBox(width: 8),
      //           Icon(
      //             Icons.arrow_forward_ios,
      //             size: 16,
      //             color: iconColor,
      //             fontWeight: FontWeight.bold,
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildSimpleSettingOption({
    required BuildContext context,
    required String label,
    required double screenWidth,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final iconColor = theme.iconTheme.color ?? theme.colorScheme.onSurface;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontStyle: FontStyle.normal,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: iconColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNotificationToggle({
    required BuildContext context,
    required String label,
    required double screenWidth,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontStyle: FontStyle.normal,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildMenuGroup(
    BuildContext context, {
    required String title,
    required List<Widget> childrens,
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
            padding: EdgeInsets.only(bottom: 6),
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
        ...childrens,
      ],
    );
  }
}
