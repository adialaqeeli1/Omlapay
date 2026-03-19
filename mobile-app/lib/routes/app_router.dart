import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import '../modules/auth/providers/verification_provider.dart';
import '../modules/coin_details/view/coin_details_view.dart';
import '../modules/coin_details/providers/coin_details_provider.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/dashboard/history/history_view.dart';
import '../modules/dashboard/history/transaction_detail_view.dart';
import '../modules/dashboard/home/home_view.dart';
import '../modules/dashboard/home/provider/home_provider.dart';
import '../modules/dashboard/home/services/coins_service.dart';
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
import '../modules/settings/settings_view.dart';
import '../modules/settings/view/account_details_view.dart';
import '../modules/notifications/notifications_view.dart';
import '../modules/notifications/notifications_list_provider.dart';
import '../modules/splash/splash_view.dart';
import '../providers/auth_provider.dart';
import '../providers/global_provider.dart';
import 'middlewares/auth_middleware.dart';

part 'app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
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

          if (isSoftLogin) {
            final user = context.read<AuthProvider>().state.user!;
            countryCode = user.countryCode;
            phoneNumber = user.mobileNumber;
          } else {
            countryCode = LoginProvider.countryCode;
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

          // Use a key that changes when switching to confirm passcode so we get
          // a fresh PasscodeProvider with empty state. Otherwise the same provider
          // (with 6 digits from set passcode) is reused and the first keypress
          // triggers verify and redirects to home.
          final providerKey = mode == LoginProvider.modeConfirmPasscode
              ? ValueKey('confirm_${pendingPasscode ?? ""}')
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
          return ChangeNotifierProvider(
            create: (_) => ForgotPasscodeProvider(
              phoneNumber: phoneNumber,
              countryCode: countryCode,
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
          return ChangeNotifierProvider(
            create: (_) => VerificationProvider(
              phoneNumber: phoneNumber,
              countryCode: countryCode,
            ),
            child: const VerificationScreen(),
          );
        },
        redirect: AuthMiddleware.registerVerification,
      ),
      ShellRoute(
        builder: (context, state, child) => DashboardView(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            name: 'home',
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) =>
                  HomeProvider(context.read<GlobalProvider>(), CoinsService()),
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
          create: (_) => NotificationsListProvider(),
          child: const NotificationsView(),
        ),
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
          return ChangeNotifierProvider(
            create: (_) => CoinDetailsProvider(),
            child: CoinDetailsView(coinModel: coinModel),
          );
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
          create: (_) => SendProvider(context.read<AuthProvider>()),
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
      ),
      GoRoute(
        path: Routes.receiveCoin,
        name: 'receiveCoin',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => ReceiveCoinProvider(),
          child: const ReceiveCoinView(),
        ),
      ),
      GoRoute(
        path: Routes.swapCoin,
        name: 'swapCoin',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => SwapProvider(),
          child: const SwapCoinView(),
        ),
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
      ),
      GoRoute(
        path: Routes.qrCode,
        name: 'qrCode',
        builder: (context, state) {
          final wallet = state.extra as WalletModel;
          return QrCodeView(wallet: wallet);
        },
      ),
    ],
  );
}
