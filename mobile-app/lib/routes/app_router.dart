import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modules/send_receive_swap_coin/receive/provider/receive_coin_provider.dart';
import '../modules/send_receive_swap_coin/receive/view/receive_coins_history_view.dart';
import 'debug_route_observer.dart';
import '../core/extentions/string_extensions.dart';
import '../core/utils/snackbar_helper.dart';
import '../core/l10n/app_localizations.dart';
import '../core/utils/user_auth_phone.dart';
import '../../core/models/transaction_model/transaction_model.dart';
import 'package:omlapay_mobile_app/core/models/coin_model/coin_model.dart';
import '../core/models/wallet_model/wallet_model.dart';
import '../modules/auth/providers/forgot_passcode_provider.dart';
import '../modules/auth/providers/login_provider.dart';
import '../modules/auth/providers/passcode_provider.dart';
import '../modules/auth/views/enter_or_set_passcode.dart';
import '../modules/auth/views/forgot_passcode.dart';
import '../modules/auth/views/login_or_register_screen.dart';
import '../modules/auth/views/verification_screen.dart';
import '../modules/auth/providers/login_verification_provider.dart';
import '../modules/auth/views/login_verification_screen.dart';
import '../modules/auth/views/change_passcode_success_view.dart';
import '../modules/auth/providers/verification_provider.dart';
import '../modules/coin_details/views/coin_details_view.dart';
import '../modules/coin_details/providers/coin_details_provider.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/dashboard/history/providers/history_provider.dart';
import '../modules/dashboard/history/views/history_view.dart';
import '../modules/dashboard/home/views/home_view.dart';
import '../modules/dashboard/home/providers/home_provider.dart';
import '../modules/about/about_view.dart';
import '../modules/about/faqs_view.dart';
import '../modules/about/privacy_policy_view.dart';
import '../modules/about/terms_conditions_view.dart';
import '../modules/help_center/providers/help_center_provider.dart';
import '../modules/help_center/providers/send_request_provider.dart';
import '../modules/help_center/views/help_center_view.dart';
import '../modules/kyc_verification/views/kyc_verification_view.dart';
import '../modules/kyc_verification/providers/kyc_verification_provider.dart';
import '../modules/auth/providers/email_verification_provider.dart';
import '../modules/auth/views/email_entry_view.dart';
import '../modules/auth/views/email_otp_view.dart';
import '../modules/help_center/views/past_requests_view.dart';
import '../modules/help_center/views/send_request_view.dart';
import '../modules/help_center/providers/request_detail_provider.dart';
import '../modules/help_center/views/request_detail_view.dart';
import '../modules/dashboard/profile/profile_view.dart';
import '../modules/onboarding/onboarding_view.dart';
import 'package:provider/provider.dart';

import '../modules/onboarding/provider/onboarding_provider.dart';
import '../providers/wallets_provider.dart';
import '../modules/send_receive_swap_coin/receive/provider/receive_coins_history_provider.dart';
import '../modules/send_receive_swap_coin/receive/view/receive_coin_view.dart';
import '../modules/send_receive_swap_coin/send/view/send_coin_view.dart';
import '../modules/send_receive_swap_coin/send/view/review_send_view.dart';
import '../modules/send_receive_swap_coin/send/view/send_success_view.dart';
import '../modules/send_receive_swap_coin/send/view/send_verification_view.dart';
import '../modules/send_receive_swap_coin/send/provider/send_provider.dart';
import '../modules/send_receive_swap_coin/swap/view/swap_coin_view.dart';
import '../modules/send_receive_swap_coin/swap/provider/swap_provider.dart';
import '../modules/send_receive_swap_coin/swap/view/review_order_view.dart';
import '../modules/send_receive_swap_coin/swap/view/swap_success_view.dart';
import '../modules/transaction_details/provider/transaction_details_provider.dart';
import '../modules/transaction_details/view/transaction_details_view.dart';
import '../modules/send_receive_swap_coin/receive/provider/qr_code_provider.dart';
import '../modules/send_receive_swap_coin/receive/view/qr_code_view.dart';
import '../modules/scan/view/qr_scanner_view.dart';
import '../modules/settings/view/settings_view.dart';
import '../modules/settings/view/account_details_view.dart';
import '../modules/settings/view/change_email/change_email_enter_new_view.dart';
import '../modules/settings/view/change_email/change_email_intro_view.dart';
import '../modules/settings/view/change_email/change_email_success_view.dart';
import '../modules/settings/view/change_email/change_email_verify_otp_view.dart';
import '../modules/settings/view/change_phone_number/change_phone_enter_new_view.dart';
import '../modules/settings/view/change_phone_number/change_phone_intro_view.dart';
import '../modules/settings/view/change_phone_number/change_phone_success_view.dart';
import '../modules/settings/view/change_phone_number/change_phone_verify_current_otp_view.dart';
import '../modules/settings/view/change_phone_number/change_phone_verify_otp_view.dart';
import '../modules/settings/view/widgets/change_detail_back_to_intro.dart';
import '../modules/settings/providers/change_email_form_provider.dart';
import '../modules/settings/providers/change_email_otp_provider.dart';
import '../modules/settings/providers/change_phone_current_otp_provider.dart';
import '../modules/settings/providers/change_phone_form_provider.dart';
import '../modules/settings/providers/change_phone_otp_provider.dart';
import '../modules/settings/services/wallet_address_service.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/notifications/providers/notifications_provider.dart';
import '../modules/splash/splash_view.dart';
import '../providers/auth_provider.dart';
import '../providers/coins_prices_provider.dart';
import '../providers/global_provider.dart';
import '../core/services/swap_quote_stream_service.dart';
import 'middlewares/auth_middleware.dart';
import '../modules/kyc_verification/utils/kyc_verification_entry_source.dart';

part 'app_routes.dart';

/// Root navigator key used by go_router. Exposed so non-router code (e.g.
/// [AppLockProvider]) can push an overlay route onto the same navigator.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Root scaffold messenger key. Exposed so app-wide code (e.g. the Shorebird
/// code-push listener) can show snackbars without a Scaffold in context.
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: appNavigatorKey,
    observers: [DebugRouteObserver()],
    routes: [
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: 'onboarding',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => OnboardingProvider(),
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: Routes.loginOrRegister,
        name: 'loginOrRegister',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => LoginProvider(),
          child: const LoginOrRegisterScreen(),
        ),
        redirect: AuthMiddleware.isUnauthenticated,
      ),
      GoRoute(
        path: Routes.enterOrSetPasscode,
        name: 'enterOrSetPasscode',
        builder: (context, state) {
          final routePayload = state.extra;
          final mode = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraModeKey] as String?
              : null;
          final isSoftLogin = mode == LoginProvider.modeSoftLogin;

          String countryCode;
          String phoneNumber;

          final isChangePasscodeStep =
              mode == LoginProvider.modeChangePasscodeCurrent ||
              mode == LoginProvider.modeChangePasscodeNew ||
              mode == LoginProvider.modeChangePasscodeConfirm;

          if (isSoftLogin || isChangePasscodeStep) {
            final user = context.read<AuthProvider>().state.user!;
            final parts = authPhonePartsForUser(user);
            countryCode = parts.countryCode;
            phoneNumber = parts.mobileNumber;
          } else {
            countryCode = LoginProvider.defaultCountryCode;
            phoneNumber = '';
            if (routePayload is Map<String, dynamic>) {
              final payloadCountryCode =
                  routePayload[LoginProvider.extraCountryCodeKey] as String?;
              final payloadPhoneNumber =
                  routePayload[LoginProvider.extraPhoneNumberKey] as String?;
              if (payloadCountryCode != null && payloadCountryCode.isNotEmpty) {
                countryCode = payloadCountryCode;
              }
              if (payloadPhoneNumber != null) {
                phoneNumber = payloadPhoneNumber;
              }
            }
          }

          final pendingPasscode = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraPendingPasscodeKey] as String?
              : null;
          final currentPasscode = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraCurrentPasscodeKey] as String?
              : null;
          final pendingEmail = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraPendingEmailKey] as String?
              : null;
          final changeEmailToken = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraChangeEmailTokenKey] as String?
              : null;
          final changePhoneToken = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraChangePhoneTokenKey] as String?
              : null;
          final registrationToken = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraRegistrationTokenKey] as String?
              : null;
          final resetToken = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraResetTokenKey] as String?
              : null;
          final otpVerificationToken = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraOtpVerificationTokenKey]
                    as String?
              : null;

          // Use a key that changes when switching to confirm passcode so we get
          // a fresh PasscodeProvider with empty state. Otherwise the same provider
          // (with 6 digits from set passcode) is reused and the first keypress
          // triggers verify and redirects to home.
          final providerKey =
              mode == LoginProvider.modeConfirmPasscode ||
                  mode == LoginProvider.modeChangePasscodeConfirm ||
                  mode == LoginProvider.modeRegisterConfirm
              ? ValueKey(
                  'confirm_${mode}_${currentPasscode ?? ""}_${pendingPasscode ?? ""}_${resetToken ?? ""}',
                )
              : ValueKey('passcode_${mode}_${countryCode}_$phoneNumber');

          return ChangeNotifierProvider(
            key: providerKey,
            create: (_) => PasscodeProvider(
              countryCode: countryCode,
              phoneNumber: phoneNumber,
            ),
            child: EnterOrSetPasscodeScreen(
              isSoftLogin: isSoftLogin,
              mode: mode,
              currentPasscode: currentPasscode,
              pendingPasscode: pendingPasscode,
              resetToken: resetToken,
              pendingEmail: pendingEmail,
              changeEmailToken: changeEmailToken,
              changePhoneToken: changePhoneToken,
              registrationToken: registrationToken,
              otpVerificationToken: otpVerificationToken,
            ),
          );
        },
        redirect: AuthMiddleware.enterOrSetPasscode,
      ),
      GoRoute(
        path: Routes.forgotPasscode,
        name: 'forgotPasscode',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final countryCode =
              extra?[LoginProvider.extraCountryCodeKey] as String? ?? '';
          final phoneNumber =
              extra?[LoginProvider.extraPhoneNumberKey] as String? ?? '';
          final otpExpirySeconds = extra?['otpExpirySeconds'] as int? ?? 60;
          final maskedMobile = extra?['maskedMobile'] as String?;
          final maskedEmail = extra?['maskedEmail'] as String?;
          final verificationType = extra?['verificationType'] as String?;
          return ChangeNotifierProvider(
            create: (_) => ForgotPasscodeProvider(
              phoneNumber: phoneNumber,
              countryCode: countryCode,
              initialCountdown: otpExpirySeconds,
              maskedMobile: maskedMobile,
              maskedEmail: maskedEmail,
              verificationType: verificationType,
            ),
            child: const ForgotPasscodeScreen(),
          );
        },
        redirect: AuthMiddleware.forgotPasscode,
      ),
      GoRoute(
        path: Routes.registerVerification,
        name: 'registerVerification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final countryCode =
              extra?[LoginProvider.extraCountryCodeKey] as String? ?? '';
          final phoneNumber =
              extra?[LoginProvider.extraPhoneNumberKey] as String? ?? '';
          final purpose =
              extra?[LoginProvider.extraVerificationPurposeKey] as String?;
          final showRegistrationProgress =
              purpose != LoginProvider.purposeChangePasscode;
          final isRegistration = extra?['isRegistration'] as bool? ?? false;
          final maskedMobile = extra?['maskedMobile'] as String?;
          final otpExpirySeconds =
              extra?['otpExpirySeconds'] as int? ??
              VerificationProvider.countdownStartSeconds;
          return ChangeNotifierProvider(
            create: (_) => VerificationProvider(
              phoneNumber: phoneNumber,
              countryCode: countryCode,
              isRegistration: isRegistration,
              maskedMobile: maskedMobile,
              initialCountdown: otpExpirySeconds,
              verificationPurpose: purpose,
              changePasscodeCurrent:
                  extra?[LoginProvider.extraCurrentPasscodeKey] as String?,
              changePasscodeNew:
                  extra?[LoginProvider.extraPendingPasscodeKey] as String?,
            ),
            child: VerificationScreen(
              showRegistrationProgress: showRegistrationProgress,
            ),
          );
        },
        redirect: AuthMiddleware.registerVerification,
      ),
      GoRoute(
        path: Routes.loginVerification,
        name: 'loginVerification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final countryCode =
              extra?[LoginProvider.extraCountryCodeKey] as String? ?? '';
          final phoneNumber =
              extra?[LoginProvider.extraPhoneNumberKey] as String? ?? '';
          final maskedMobile = extra?['maskedMobile'] as String?;
          final otpExpirySeconds =
              extra?['otpExpirySeconds'] as int? ??
              LoginVerificationProvider.countdownStartSeconds;
          return ChangeNotifierProvider(
            create: (_) => LoginVerificationProvider(
              countryCode: countryCode,
              phoneNumber: phoneNumber,
              maskedMobile: maskedMobile,
              initialCountdown: otpExpirySeconds,
            ),
            child: const LoginVerificationScreen(),
          );
        },
        redirect: AuthMiddleware.isUnauthenticated,
      ),
      GoRoute(
        path: Routes.changePasscodeSuccess,
        name: 'changePasscodeSuccess',
        builder: (context, state) => const ChangePasscodeSuccessView(),
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.changeEmailIntro,
        name: 'changeEmailIntro',
        builder: (context, state) => const ChangeEmailIntroView(),
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.changeEmailVerifyPhone,
        name: 'changeEmailVerifyPhone',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return ChangeNotifierProvider(
            create: (_) => ChangeEmailPhoneOtpProvider(),
            child: Builder(
              builder: (ctx) {
                final provider = ctx.watch<ChangeEmailPhoneOtpProvider>();
                final phoneSubtitle = provider.maskedPhone.isNotEmpty
                    ? l10n.changeEmailPhoneOtpSent(
                        provider.maskedPhone.ltrPhoneNumber,
                      )
                    : l10n.changeEmailPhoneOtpSent('...');

                return ChangeEmailVerifyOtpView(
                  appBarTitle: l10n.changeEmail,
                  title: l10n.verifyCurrentPhoneNumber,
                  subtitle: phoneSubtitle,
                  onBackPressed: () => popToChangeEmailIntro(ctx),
                  otpLength: ChangeEmailPhoneOtpProvider.otpLength,
                  countdownSeconds: provider.countdownSeconds,
                  canResend: provider.canResend,
                  hasError: provider.hasError,
                  onInitialRequest: provider.requestOtp,
                  onOtpChanged: provider.setOtp,
                  onOtpCompleted: (innerCtx) async {
                    final valid = await provider.verifyOtp();
                    if (!innerCtx.mounted || !valid) return;
                    final token = provider.changeEmailToken;
                    if (token == null || token.isEmpty) return;
                    innerCtx.push(
                      Routes.enterOrSetPasscode,
                      extra: {
                        LoginProvider.extraModeKey:
                            LoginProvider.modeChangeEmailConfirmPasscode,
                        LoginProvider.extraChangeEmailTokenKey: token,
                      },
                    );
                  },
                  onResend: provider.resendOtp,
                );
              },
            ),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.changeEmailEnterNew,
        name: 'changeEmailEnterNew',
        builder: (context, state) {
          final user = context.read<AuthProvider>().state.user!;
          final extra = state.extra as Map<String, dynamic>?;
          final changeEmailToken =
              extra?[LoginProvider.extraChangeEmailTokenKey] as String? ?? '';
          return ChangeNotifierProvider(
            create: (_) => ChangeEmailFormProvider(
              currentEmail: WalletAddressService.getUserEmail(user),
            ),
            child: ChangeEmailEnterNewView(changeEmailToken: changeEmailToken),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.changeEmailVerifyNewEmail,
        name: 'changeEmailVerifyNewEmail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final pendingEmail =
              extra?[LoginProvider.extraPendingEmailKey] as String? ?? '';
          final changeEmailToken =
              extra?[LoginProvider.extraChangeEmailTokenKey] as String? ?? '';
          final otpExpiry =
              extra?[LoginProvider.extraOtpExpirySecondsKey] as int?;
          final l10n = AppLocalizations.of(context)!;
          return ChangeNotifierProvider(
            create: (_) => ChangeEmailNewEmailOtpProvider(
              changeEmailToken: changeEmailToken,
              newEmail: pendingEmail,
              initialOtpExpirySeconds: otpExpiry,
            ),
            child: Builder(
              builder: (ctx) {
                final provider = ctx.watch<ChangeEmailNewEmailOtpProvider>();
                return ChangeEmailVerifyOtpView(
                  appBarTitle: l10n.changeEmail,
                  title: l10n.verifyNewEmailAddress,
                  subtitle: l10n.changeEmailEmailOtpSent(pendingEmail),
                  onBackPressed: () => popToChangeEmailIntro(ctx),
                  otpLength: ChangeEmailNewEmailOtpProvider.otpLength,
                  countdownSeconds: provider.countdownSeconds,
                  canResend: provider.canResend,
                  hasError: provider.hasError,
                  onInitialRequest: provider.requestOtp,
                  onOtpChanged: provider.setOtp,
                  onOtpCompleted: (innerCtx) async {
                    final valid = await provider.verifyOtp();
                    if (!innerCtx.mounted || !valid) return;
                    final confirmedEmail =
                        provider.verifiedEmail?.trim().isNotEmpty == true
                        ? provider.verifiedEmail!.trim()
                        : pendingEmail;
                    await innerCtx
                        .read<AuthProvider>()
                        .updateEmailForCurrentUser(confirmedEmail);
                    if (!innerCtx.mounted) return;
                    innerCtx.go(Routes.changeEmailSuccess);
                  },
                  onResend: provider.resendOtp,
                );
              },
            ),
          );
        },
        redirect: AuthMiddleware.changeEmailVerifyNewEmail,
      ),
      GoRoute(
        path: Routes.changeEmailSuccess,
        name: 'changeEmailSuccess',
        builder: (context, state) => const ChangeEmailSuccessView(),
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.changePhoneIntro,
        name: 'changePhoneIntro',
        builder: (context, state) => const ChangePhoneIntroView(),
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.changePhoneVerifyCurrent,
        name: 'changePhoneVerifyCurrent',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final maskedEmail =
              extra?[LoginProvider.extraMaskedEmailKey] as String? ?? '';
          final otpExpiry =
              extra?[LoginProvider.extraOtpExpirySecondsKey] as int?;
          final user = context.read<AuthProvider>().state.user;
          final fallbackMaskedEmail = user?.email != null
              ? maskedEmailForDisplay(user!.email!)
              : '';
          final effectiveMaskedEmail = maskedEmail.isNotEmpty
              ? maskedEmail
              : fallbackMaskedEmail;
          final l10n = AppLocalizations.of(context)!;
          return ChangeNotifierProvider(
            create: (_) => ChangePhoneCurrentOtpProvider(
              maskedEmail: effectiveMaskedEmail,
              initialOtpExpirySeconds: otpExpiry,
            ),
            child: Builder(
              builder: (ctx) {
                final provider = ctx.watch<ChangePhoneCurrentOtpProvider>();
                final maskedEmailForView = provider.displayMaskedEmail;
                return ChangePhoneVerifyCurrentOtpView(
                  appBarTitle: l10n.changePhoneNumber,
                  title: l10n.verifyYourEmail,
                  subtitle: maskedEmailForView.isNotEmpty
                      ? l10n.twoFactorEmailOtpSent(maskedEmailForView)
                      : l10n.twoFactorEmailOtpSent('...'),
                  onBackPressed: () => popToChangePhoneIntro(ctx),
                  onVerified: (innerCtx) async {
                    final token = innerCtx
                        .read<ChangePhoneCurrentOtpProvider>()
                        .changePhoneToken;
                    if (token == null || token.isEmpty) return;
                    innerCtx.push(
                      Routes.enterOrSetPasscode,
                      extra: {
                        LoginProvider.extraModeKey:
                            LoginProvider.modeChangePhoneConfirmPasscode,
                        LoginProvider.extraChangePhoneTokenKey: token,
                      },
                    );
                  },
                );
              },
            ),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.changePhoneEnterNew,
        name: 'changePhoneEnterNew',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final changePhoneToken =
              extra?[LoginProvider.extraChangePhoneTokenKey] as String? ?? '';
          final user = context.read<AuthProvider>().state.user!;
          return ChangeNotifierProvider(
            create: (_) => ChangePhoneFormProvider(
              changePhoneToken: changePhoneToken,
              currentPhone: user.mobileNumber,
              accountCountryDialCode: user.countryCode.trim().isNotEmpty
                  ? user.countryCode.trim()
                  : LoginProvider.defaultCountryCode,
            ),
            child: const ChangePhoneEnterNewView(),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.changePhoneVerifyNew,
        name: 'changePhoneVerifyNew',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final changePhoneToken =
              extra?[LoginProvider.extraChangePhoneTokenKey] as String? ?? '';
          final countryCode =
              extra?[LoginProvider.extraCountryCodeKey] as String? ?? '';
          final phoneNumber =
              extra?[LoginProvider.extraPhoneNumberKey] as String? ?? '';
          final maskedMobile =
              extra?[LoginProvider.extraMaskedMobileKey] as String? ?? '';
          final otpExpiry =
              extra?[LoginProvider.extraOtpExpirySecondsKey] as int?;
          // Fall back to the typed phone number when the server didn't return
          // a masked value, so the OTP screen still tells the user where the
          // code was sent.
          final displayPhone = maskedMobile.isNotEmpty
              ? maskedMobile
              : '$countryCode $phoneNumber';
          final l10n = AppLocalizations.of(context)!;
          return ChangeNotifierProvider(
            create: (_) => ChangePhoneOtpProvider(
              changePhoneToken: changePhoneToken,
              countryCode: countryCode,
              newMobileNumber: phoneNumber,
              maskedMobile: displayPhone,
              initialOtpExpirySeconds: otpExpiry,
            ),
            child: ChangePhoneVerifyOtpView(
              appBarTitle: l10n.changePhoneNumber,
              title: l10n.verifyNewPhoneNumber,
              subtitle: l10n.changePhoneNewOtpSent(displayPhone.ltrPhoneNumber),
              onBackPressed: () => popToChangePhoneIntro(context),
              onVerified: (ctx) async {
                final l10n = AppLocalizations.of(ctx)!;
                final applied = await ctx
                    .read<AuthProvider>()
                    .completePhoneChangeAndRefreshSession(
                      countryCode: countryCode,
                      phoneNumber: phoneNumber,
                    );
                if (!ctx.mounted) return;
                if (!applied) {
                  SnackbarHelper.showError(ctx, l10n.loginFailed);
                  ctx.go(Routes.loginOrRegister);
                  return;
                }
                ctx.go(Routes.changePhoneSuccess);
              },
            ),
          );
        },
        redirect: (context, state) {
          final authRedirect = AuthMiddleware.isAuthenticated(context, state);
          if (authRedirect != null) return authRedirect;
          return AuthMiddleware.changePhoneVerifyNew(context, state);
        },
      ),
      GoRoute(
        path: Routes.changePhoneSuccess,
        name: 'changePhoneSuccess',
        builder: (context, state) => const ChangePhoneSuccessView(),
        redirect: AuthMiddleware.isAuthenticated,
      ),
      ShellRoute(
        builder: (context, state, child) => DashboardView(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            name: 'home',
            builder: (context, state) =>
                ChangeNotifierProxyProvider<AuthProvider, HomeProvider>(
                  create: (_) => HomeProvider(),
                  update: (_, auth, home) =>
                      (home ?? HomeProvider())
                        ..onAuthChanged(auth.state.isAuthenticated),
                  child: const HomeView(),
                ),
          ),
          GoRoute(
            path: Routes.history,
            name: 'history',
            builder: (context, state) => const HistoryView(),
            redirect: AuthMiddleware.isAuthenticated,
          ),
          GoRoute(
            path: Routes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileView(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: Routes.notifications,
        name: 'notifications',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => NotificationsProvider(),
          child: const NotificationsView(),
        ),
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.accountDetails,
        name: 'accountDetails',
        builder: (context, state) => const AccountDetailsView(),
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.about,
        name: 'about',
        builder: (context, state) => const AboutView(),
      ),
      GoRoute(
        path: Routes.faqs,
        name: 'faqs',
        builder: (context, state) => const FAQsView(),
      ),
      GoRoute(
        path: Routes.termsAndConditions,
        name: 'termsAndConditions',
        builder: (context, state) => const TermsConditionsView(),
      ),
      GoRoute(
        path: Routes.privacyPolicy,
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyView(),
      ),
      GoRoute(
        path: Routes.helpCenter,
        name: 'helpCenter',
        builder: (context, state) => const HelpCenterView(),
        // redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.kycVerification,
        name: 'kycVerification',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => KycVerificationProvider(),
          child: KycVerificationView(
            entrySource: KycVerificationEntrySource.fromExtra(state.extra),
          ),
        ),
      ),
      GoRoute(
        path: Routes.emailEntry,
        name: 'emailEntry',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => EmailVerificationProvider(),
          child: const EmailEntryView(),
        ),
      ),
      GoRoute(
        path: Routes.emailVerifyOtp,
        name: 'emailVerifyOtp',
        builder: (context, state) {
          final provider = state.extra as EmailVerificationProvider;
          return ChangeNotifierProvider.value(
            value: provider,
            child: const EmailOtpView(),
          );
        },
      ),
      GoRoute(
        path: Routes.sendRequest,
        name: 'sendRequest',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) =>
              SendRequestProvider(context.read<AuthProvider>()),
          child: const SendRequestView(),
        ),
      ),
      GoRoute(
        path: Routes.pastRequests,
        name: 'pastRequests',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => HelpCenterProvider(context.read<AuthProvider>()),
          child: const PastRequestsView(),
        ),
      ),
      GoRoute(
        path: Routes.requestDetail,
        name: 'requestDetail',
        builder: (context, state) {
          final requestId = state.extra as String;
          return ChangeNotifierProvider(
            create: (context) => RequestDetailProvider(
              requestId: requestId,
              authProvider: context.read<AuthProvider>(),
            ),
            child: const RequestDetailView(),
          );
        },
      ),
      GoRoute(
        path: Routes.coinDetails,
        name: 'coinDetails',
        builder: (context, state) {
          final CoinModel? coinModel = state.extra as CoinModel?;
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) =>
                    CoinDetailsProvider()
                      ..initWithBalance(coinModel?.amount ?? '0.00'),
              ),
              ChangeNotifierProvider(
                create: (ctx) => HistoryProvider(
                  ctx.read<CoinsPricesProvider>(),
                  initialCoinFilter: coinModel?.symbol,
                ),
              ),
            ],
            child: CoinDetailsView(coinModel: coinModel),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.transactionDetail,
        name: 'transactionDetail',
        builder: (context, state) {
          final extra = state.extra;
          final String id;
          TransactionModel? seed;
          if (extra is TransactionModel) {
            id = extra.id;
            seed = extra;
          } else if (extra is String) {
            id = extra;
          } else {
            id = '';
          }
          return ChangeNotifierProvider(
            create: (_) =>
                TransactionDetailsProvider(transactionId: id, seed: seed),
            child: TransactionDetailsView(),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.sendCoin,
        name: 'sendCoin',
        builder: (context, state) {
          final extra = state.extra is SendCoinExtra
              ? state.extra as SendCoinExtra
              : null;
          return ChangeNotifierProvider(
            create: (_) => SendProvider(
              context.read<AuthProvider>(),
              context.read<CoinsPricesProvider>(),
              context.read<WalletsProvider>(),
              initialCoinSymbol: extra?.initialCoinSymbol,
              initialRecipient: extra?.initialRecipient,
              initialAmount: extra?.initialAmount,
            ),
            child: const SendCoinView(),
          );
        },
      ),
      GoRoute(
        path: Routes.sendReview,
        name: 'sendReview',
        builder: (context, state) {
          final provider = state.extra as SendProvider;
          return ChangeNotifierProvider.value(
            value: provider,
            child: const ReviewSendView(),
          );
        },
      ),
      GoRoute(
        path: Routes.sendVerification,
        name: 'sendVerification',
        builder: (context, state) {
          final provider = state.extra as SendProvider;
          return ChangeNotifierProvider.value(
            value: provider,
            child: const SendVerificationView(),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.sendSuccess,
        name: 'sendSuccess',
        builder: (context, state) {
          final provider = state.extra as SendProvider;
          return ChangeNotifierProvider.value(
            value: provider,
            child: const SendSuccessView(),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.recieveCoins,
        name: 'recieveCoins',
        builder: (context, state) {
          final fromReceive = state.extra == true;
          return ChangeNotifierProvider(
            create: (ctx) => ReciveCoinProvider(
              walletsProvider: ctx.read<WalletsProvider>(),
            ),
            child: ReceiveCoinView(fromReceive: fromReceive),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.receiveCoinsHistory,
        name: 'receiveCoinsHistory',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => ReceiveCoinsHistoryProvider(
            context.read<AuthProvider>(),
            context.read<CoinsPricesProvider>(),
          ),
          child: const ReceiveCoinsHistoryView(),
        ),
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.swapCoin,
        name: 'swapCoin',
        builder: (context, state) {
          final extra = state.extra is SwapCoinExtra
              ? state.extra as SwapCoinExtra
              : null;
          return ChangeNotifierProvider(
            create: (_) => SwapProvider(
              context.read<AuthProvider>(),
              context.read<CoinsPricesProvider>(),
              context.read<WalletsProvider>(),
              context.read<GlobalProvider>(),
              SwapQuoteStreamService(),
              initialFromCoinSymbol: extra?.initialFromCoinSymbol,
            ),
            child: const SwapCoinView(),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.swapReview,
        name: 'swapReview',
        builder: (context, state) {
          final provider = state.extra as SwapProvider;
          return ChangeNotifierProvider.value(
            value: provider,
            child: const ReviewOrderView(),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.swapSuccess,
        name: 'swapSuccess',
        builder: (context, state) {
          final provider = state.extra as SwapProvider;
          return ChangeNotifierProvider.value(
            value: provider,
            child: const SwapSuccessView(),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),

      GoRoute(
        path: Routes.qrCode,
        name: 'qrCode',
        builder: (context, state) {
          final walletNetwork = state.extra as WalletNetworkModel;
          return ChangeNotifierProvider(
            create: (_) => QrCodeProvider(walletNetwork: walletNetwork),
            child: const QrCodeView(),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.qrScanner,
        name: 'qrScanner',
        builder: (context, state) => QrScannerView(extra: state.extra),
        redirect: AuthMiddleware.isAuthenticated,
      ),
    ],
  );
}
