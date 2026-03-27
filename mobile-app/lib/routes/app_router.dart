import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'debug_route_observer.dart';
import '../core/extentions/string_extensions.dart';
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
import '../modules/auth/views/change_passcode_success_view.dart';
import '../modules/auth/providers/verification_provider.dart';
import '../modules/coin_details/coin_details_view.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/dashboard/history/history_view.dart';
import '../modules/dashboard/history/transaction_detail_view.dart';
import '../modules/dashboard/home/home_view.dart';
import '../modules/dashboard/profile/about/about_view.dart';
import '../modules/dashboard/profile/about/faqs_view.dart';
import '../modules/dashboard/profile/about/privacy_policy_view.dart';
import '../modules/dashboard/profile/about/terms_conditions_view.dart';
import '../modules/dashboard/profile/help_center/help_center_view.dart';
import '../modules/dashboard/profile/kyc_verification_view.dart';
import '../modules/dashboard/profile/help_center/past_requests_view.dart';
import '../modules/dashboard/profile/help_center/send_request_view.dart';
import '../modules/dashboard/profile/profile_view.dart';
import '../modules/onboarding/onboarding_view.dart';
import 'package:provider/provider.dart';

import '../modules/onboarding/provider/onboarding_provider.dart';
import '../modules/send_receive_swap_coin/receive/provider/receive_coin_provider.dart';
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
import '../modules/wallets/provider/wallets_provider.dart';
import '../modules/wallets/view/wallets_view.dart';
import '../modules/wallets/view/qr_code_view.dart';
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
import '../modules/settings/providers/change_email_form_provider.dart';
import '../modules/settings/providers/change_email_otp_provider.dart';
import '../modules/settings/providers/change_phone_form_provider.dart';
import '../modules/settings/services/wallet_address_service.dart';
import '../modules/notifications/notifications_view.dart';
import '../modules/notifications/notifications_list_provider.dart';
import '../modules/splash/splash_view.dart';
import '../providers/auth_provider.dart';
import '../providers/coins_prices_provider.dart';
import 'middlewares/auth_middleware.dart';

part 'app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
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
          final pendingEmail = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraPendingEmailKey] as String?
              : null;
          final registrationToken = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraRegistrationTokenKey] as String?
              : null;
          final resetToken = routePayload is Map<String, dynamic>
              ? routePayload[LoginProvider.extraResetTokenKey] as String?
              : null;

          // Use a key that changes when switching to confirm passcode so we get
          // a fresh PasscodeProvider with empty state. Otherwise the same provider
          // (with 6 digits from set passcode) is reused and the first keypress
          // triggers verify and redirects to home.
          final providerKey =
              mode == LoginProvider.modeConfirmPasscode ||
                  mode == LoginProvider.modeChangePasscodeConfirm
              ? ValueKey(
                  'confirm_${mode}_${pendingPasscode ?? ""}_${resetToken ?? ""}',
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
              pendingPasscode: pendingPasscode,
              resetToken: resetToken,
              pendingEmail: pendingEmail,
              registrationToken: registrationToken,
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
          return ChangeNotifierProvider(
            create: (_) => ForgotPasscodeProvider(
              phoneNumber: phoneNumber,
              countryCode: countryCode,
              initialCountdown: otpExpirySeconds,
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
            ),
            child: VerificationScreen(
              showRegistrationProgress: showRegistrationProgress,
            ),
          );
        },
        redirect: AuthMiddleware.registerVerification,
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
          final user = context.read<AuthProvider>().state.user!;
          final l10n = AppLocalizations.of(context)!;
          return ChangeNotifierProvider(
            create: (_) => ChangeEmailOtpProvider(
              target: '${user.countryCode}${user.mobileNumber}',
            ),
            child: ChangeEmailVerifyOtpView(
              appBarTitle: l10n.changeEmail,
              title: l10n.verifyCurrentPhoneNumber,
              subtitle: l10n.changeEmailPhoneOtpSent(
                maskedPhoneForDisplay(user.countryCode, user.mobileNumber),
              ),
              onVerified: (ctx) async {
                ctx.push(Routes.changeEmailEnterNew);
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
          return ChangeNotifierProvider(
            create: (_) => ChangeEmailFormProvider(
              currentEmail: WalletAddressService.getUserEmail(user),
            ),
            child: const ChangeEmailEnterNewView(),
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
          final l10n = AppLocalizations.of(context)!;
          return ChangeNotifierProvider(
            create: (_) => ChangeEmailOtpProvider(target: pendingEmail),
            child: ChangeEmailVerifyOtpView(
              appBarTitle: l10n.changeEmail,
              title: l10n.verifyNewEmailAddress,
              subtitle: l10n.changeEmailEmailOtpSent(pendingEmail),
              onVerified: (ctx) async {
                final user = ctx.read<AuthProvider>().state.user!;
                ctx.go(
                  Routes.enterOrSetPasscode,
                  extra: {
                    LoginProvider.extraModeKey:
                        LoginProvider.modeChangeEmailConfirmPasscode,
                    LoginProvider.extraCountryCodeKey: user.countryCode,
                    LoginProvider.extraPhoneNumberKey: user.mobileNumber,
                    LoginProvider.extraPendingEmailKey: pendingEmail,
                  },
                );
              },
            ),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
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
          final user = context.read<AuthProvider>().state.user!;
          final l10n = AppLocalizations.of(context)!;
          return ChangeNotifierProvider(
            create: (_) => ChangeEmailOtpProvider(
              target: '${user.countryCode}${user.mobileNumber}',
            ),
            child: ChangeEmailVerifyOtpView(
              appBarTitle: l10n.changePhoneNumber,
              title: l10n.verifyCurrentPhoneNumber,
              subtitle: l10n.changePhoneCurrentOtpSent(
                maskedPhoneForDisplay(user.countryCode, user.mobileNumber),
              ),
              onVerified: (ctx) async {
                ctx.push(Routes.changePhoneEnterNew);
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
          final user = context.read<AuthProvider>().state.user!;
          return ChangeNotifierProvider(
            create: (_) => ChangePhoneFormProvider(
              countryCode: user.countryCode,
              currentPhone: user.mobileNumber,
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
          final countryCode =
              extra?[LoginProvider.extraCountryCodeKey] as String? ?? '';
          final phoneNumber =
              extra?[LoginProvider.extraPhoneNumberKey] as String? ?? '';
          final l10n = AppLocalizations.of(context)!;
          final fullPhone = '$countryCode$phoneNumber';
          return ChangeNotifierProvider(
            create: (_) => ChangeEmailOtpProvider(target: fullPhone),
            child: ChangeEmailVerifyOtpView(
              appBarTitle: l10n.changePhoneNumber,
              title: l10n.verifyNewPhoneNumber,
              subtitle: l10n.changePhoneNewOtpSent(fullPhone),
              onVerified: (ctx) async {
                final applied = await ctx
                    .read<AuthProvider>()
                    .updatePhoneForCurrentUser(
                      countryCode: countryCode,
                      phoneNumber: phoneNumber,
                    );
                if (!ctx.mounted || !applied) return;
                ctx.go(Routes.changePhoneSuccess);
              },
            ),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
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
            builder: (context, state) => const HomeView(),
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
          create: (_) =>
              NotificationsListProvider(AppLocalizations.of(context)!),
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
      ),
      GoRoute(
        path: Routes.kycVerification,
        name: 'kycVerification',
        builder: (context, state) => const KycVerificationView(),
      ),
      GoRoute(
        path: Routes.sendRequest,
        name: 'sendRequest',
        builder: (context, state) => const SendRequestView(),
      ),
      GoRoute(
        path: Routes.pastRequests,
        name: 'pastRequests',
        builder: (context, state) => const PastRequestsView(),
      ),
      GoRoute(
        path: Routes.coinDetails,
        name: 'coinDetails',
        builder: (context, state) {
          final CoinModel? coinModel = state.extra as CoinModel?;
          return CoinDetailsView(coinModel: coinModel);
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.transactionDetail,
        name: 'transactionDetail',
        builder: (context, state) {
          final TransactionModel? transaction =
              state.extra as TransactionModel?;
          return TransactionDetailView(transaction: transaction!);
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.sendCoin,
        name: 'sendCoin',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => SendProvider(
            context.read<AuthProvider>(),
            context.read<CoinsPricesProvider>(),
          ),
          child: const SendCoinView(),
        ),
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
        builder: (context, state) => const SendVerificationView(),
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
        path: Routes.receiveCoin,
        name: 'receiveCoin',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => ReceiveCoinProvider(),
          child: const ReceiveCoinView(),
        ),
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.swapCoin,
        name: 'swapCoin',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => SwapProvider(
            context.read<AuthProvider>(),
            context.read<CoinsPricesProvider>(),
          ),
          child: const SwapCoinView(),
        ),
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
        path: Routes.transactionDetails,
        name: 'transactionDetails',
        builder: (context, state) {
          final transaction = state.extra as TransactionModel;
          // return TransactionDetailsView(transaction: transaction);
          return ChangeNotifierProvider(
            create: (_) => TransactionDetailsProvider(transaction: transaction),
            child: TransactionDetailsView(),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.wallets,
        name: 'wallets',
        builder: (context, state) {
          final fromReceive = state.extra == true;
          return ChangeNotifierProvider(
            create: (_) => WalletsProvider(),
            child: WalletsView(fromReceive: fromReceive),
          );
        },
        redirect: AuthMiddleware.isAuthenticated,
      ),
      GoRoute(
        path: Routes.qrCode,
        name: 'qrCode',
        builder: (context, state) {
          final wallet = state.extra as WalletModel;
          return QrCodeView(wallet: wallet);
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
