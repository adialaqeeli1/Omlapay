part of '../onboarding_view.dart';

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              title,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.isDarkMode
                    ? AppColors.white
                    : AppColors.textBlack,
                height: 1.2,
              ),
            ),
            Expanded(
              child: Center(
                child: CustomSvgPainterWidget(
                  assetPath: imagePath,
                  height: context.height * 0.35,
                  colorToInvert: context.isDarkMode ? Colors.black : null,
                ),
              ),
            ),
            Text(
              subtitle,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.isDarkMode
                    ? AppColors.white
                    : AppColors.textBlack,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
