part of '../onboarding_view.dart';

class _ChooseLanguage extends StatelessWidget {
  const _ChooseLanguage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Consumer<LocaleProvider>(
          builder: (context, localeProvider, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n!.beforeYouStart,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      // Text color is handled by Theme, but we can enforce it if needed
                    ),
                  ),
                  Text(
                    context.l10n!.chooseYourLanguage,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      // Text color is handled by Theme, but we can enforce it if needed
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  _buildLanguageOption(
                    context,
                    title: context.l10n!.english,
                    isSelected: localeProvider.locale.languageCode == 'en',
                    onTap: () => localeProvider.setLocale(const Locale('en')),
                  ),
                  const SizedBox(height: 16),
                  _buildLanguageOption(
                    context,
                    title: context.l10n!.arabic,
                    isSelected: localeProvider.locale.languageCode == 'ar',
                    onTap: () => localeProvider.setLocale(const Locale('ar')),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                context.l10n!.languagePreferenceNote,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors
                      .textGrey, // Grey looks good on both modes for subtitle
                  height: 1.4,
                ),
              ),
              const Spacer(),
              CommonButton(
                onPressed: () =>
                    context.read<OnboardingProvider>().onContinue(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Determine colors based on selection and theme
    final borderColor = isSelected
        ? AppColors.primaryColor
        : (context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300);

    // We can use context.textTheme.bodyLarge?.color for text, which switches B/W automatically

    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
