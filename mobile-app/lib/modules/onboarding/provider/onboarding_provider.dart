import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omlapay_mobile_app/core/services/storage_helper.dart';
import 'package:omlapay_mobile_app/core/constants/constants.dart';
import 'package:omlapay_mobile_app/routes/app_router.dart';

class OnboardingProvider extends ChangeNotifier {
  final PageController pageController = PageController();
  int currentPage = 0;
  Locale? selectedLocale;

  /// Marks onboarding as completed and navigates to appropriate screen
  Future<void> _completeOnboarding(BuildContext context) async {
    // Save onboarding completion status
    await StorageService.setBool(AppConstants.onboardingCompletedKey, true);

    if (context.mounted) {
      context.go(Routes.home);
    }
  }

  void onSkip(BuildContext context) {
    _completeOnboarding(context);
  }

  void onContinue(BuildContext context) {
    if (currentPage < 3) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page completed - mark onboarding as done
      _completeOnboarding(context);
    }
  }

  void onBack(BuildContext context) {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPageChanged(int index) {
    currentPage = index;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
