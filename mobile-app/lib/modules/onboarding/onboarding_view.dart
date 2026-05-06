import 'package:flutter/material.dart';
import '../../core/extentions/context_extensions.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/theme.dart';
import '../../providers/locale_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/common_back_button.dart';
import 'provider/onboarding_provider.dart';

import '../../widgets/common_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/custom_svg_painter.dart';

part './screens/choose_language.dart';
part 'screens/onboarding_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: provider.currentPage == 0
                ? null
                : CommonBackButton(
                    onPressed: () =>
                        context.read<OnboardingProvider>().onBack(context),
                  ),
            actions: provider.currentPage == 0
                ? null
                : [
                    TextButton(
                      onPressed: () =>
                          context.read<OnboardingProvider>().onSkip(context),
                      child: Text(
                        context.l10n!.skip,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode
                              ? AppColors.white
                              : AppColors.darkSurface,
                        ),
                      ),
                    ),
                  ],
          ),
          body: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: provider.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: provider.onPageChanged,
                  children: [
                    _ChooseLanguage(),
                    _OnboardingPage(
                      title: context.l10n!.welcomeToOmlaPay,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.welcomeToOmlaPayNote,
                      imagePath: 'assets/icons/astronaut_riding_dog.svg',
                    ),
                    _OnboardingPage(
                      title: context.l10n!.fundsSafeSecure,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.advancedSecurityNote,
                      imagePath: 'assets/icons/White-List-Person.svg',
                    ),
                    _OnboardingPage(
                      title: AppLocalizations.of(
                        context,
                      )!.lowFeesMultipleCurrencies,
                      subtitle: context.l10n!.saveMoneyNote,
                      imagePath: 'assets/icons/Stack-Of-Cryptocoins.svg',
                    ),
                  ],
                ),
              ),
              if (provider.currentPage != 0)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    bottom: 24.0,
                  ),
                  child: Row(
                    children: [
                      Consumer<OnboardingProvider>(
                        builder: (context, provider, child) {
                          // Logic: Page 0 is Language. Pages 1, 2, 3 are content.
                          // We want 3 dots for pages 1, 2, 3.
                          // Current page index for dots: provider.currentPage - 1.
                          final int currentDotIndex = provider.currentPage - 1;

                          return Row(
                            children: List.generate(3, (index) {
                              final bool isActive = index == currentDotIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsetsDirectional.only(
                                  end: 8,
                                ),
                                height: 8,
                                width: isActive ? 32 : 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primaryColor
                                      : Colors.grey.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context
                            .read<OnboardingProvider>()
                            .onContinue(context),
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              context.textDirection == TextDirection.rtl
                                  ? 'assets/icons/arrow_back.svg'
                                  : 'assets/icons/arrow_forward.svg',
                              width: 24,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
