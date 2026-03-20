import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import 'common_back_button.dart';

class ChangeDetailSuccessView extends StatelessWidget {
  const ChangeDetailSuccessView({
    super.key,
    required this.appBarTitle,
    required this.message,
    required this.backHomeLabel,
    required this.onBackHome,
  });

  final String appBarTitle;
  final String message;
  final String backHomeLabel;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onBackHome();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: CommonBackButton(onPressed: onBackHome),
          title: Text(
            appBarTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _SuccessBadge(),
                        const SizedBox(height: 32),
                        Text(
                          message,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: onBackHome,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: theme.brightness == Brightness.dark
                        ? AppColors.iconBackground
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    backHomeLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 132,
      height: 128,
      child: CustomPaint(painter: _SuccessBadgePainter()),
    );
  }
}

class _SuccessBadgePainter extends CustomPainter {
  const _SuccessBadgePainter();

  static const Size _viewBox = Size(132, 128);
  static const Color _teal40 = Color(0x662AA29A);
  static const Color _green = Color(0xFF09E253);
  static const Color _teal = Color(0xFF2AA29A);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / _viewBox.width).clamp(0.0, double.infinity);
    canvas.save();
    canvas.scale(scale, scale);

    final fillPaint = Paint()..color = _teal40;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = _green
      ..strokeWidth = 1;

    // Base circle
    canvas.drawCircle(const Offset(68.457, 64.5938), 55.9688, fillPaint);
    canvas.drawCircle(const Offset(68.457, 64.5938), 55.9688, strokePaint);

    // Bottom-right segmented ring (inside stroke effect)
    final lowerArcPath = Path()
      ..moveTo(131.426, 64.5938)
      ..lineTo(131.426, 64.5938)
      ..cubicTo(131.426, 72.9315, 129.77, 81.1863, 126.554, 88.879)
      ..cubicTo(123.339, 96.5717, 118.627, 103.549, 112.694, 109.407)
      ..cubicTo(106.76, 115.264, 99.7219, 119.885, 91.9882, 123.001)
      ..cubicTo(84.2544, 126.116, 75.9789, 127.665, 67.6419, 127.557)
      ..cubicTo(59.3048, 127.449, 51.0722, 125.687, 43.4217, 122.372)
      ..cubicTo(35.7713, 119.057, 28.8553, 114.255, 23.0752, 108.246)
      ..cubicTo(17.2951, 102.237, 12.766, 95.1402, 9.75054, 87.3668)
      ..cubicTo(6.73514, 79.5934, 5.29353, 71.2985, 5.50939, 62.9636)
      ..lineTo(6.89165, 62.9994)
      ..cubicTo(6.68053, 71.1513, 8.09048, 79.264, 11.0397, 86.8667)
      ..cubicTo(13.9889, 94.4694, 18.4186, 101.411, 24.0718, 107.288)
      ..cubicTo(29.7249, 113.165, 36.489, 117.861, 43.9715, 121.103)
      ..cubicTo(51.4539, 124.345, 59.5058, 126.069, 67.6598, 126.175)
      ..cubicTo(75.8138, 126.28, 83.9075, 124.765, 91.4714, 121.718)
      ..cubicTo(99.0353, 118.671, 105.919, 114.151, 111.722, 108.423)
      ..cubicTo(117.526, 102.694, 122.133, 95.8695, 125.279, 88.3457)
      ..cubicTo(128.424, 80.8219, 130.043, 72.7484, 130.043, 64.5938)
      ..lineTo(131.426, 64.5938)
      ..close();
    canvas.drawPath(lowerArcPath, fillPaint);
    canvas.save();
    canvas.clipPath(lowerArcPath);
    canvas.drawPath(
      lowerArcPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = _green
        ..strokeWidth = 2,
    );
    canvas.restore();

    // Check mark
    final checkPath = Path()
      ..moveTo(58.2779, 87.75)
      ..lineTo(38.8008, 68.0047)
      ..lineTo(43.0349, 63.7123)
      ..lineTo(58.2779, 79.1651)
      ..lineTo(94.6916, 42.25)
      ..lineTo(98.9258, 46.5425)
      ..lineTo(58.2779, 87.75)
      ..close();
    canvas.drawPath(
      checkPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = _green,
    );
    canvas.drawPath(
      checkPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _teal,
    );

    // Left sparkle
    final leftSparkle = Path()
      ..moveTo(8.73828, 42.6562)
      ..cubicTo(6.56053, 42.0048, 5.78575, 41.1987, 5.08203, 39)
      ..cubicTo(4.48988, 40.9931, 3.7499, 41.8345, 1.42578, 42.6562)
      ..cubicTo(3.78088, 43.5899, 4.51211, 44.4206, 5.08203, 46.3125)
      ..cubicTo(5.78461, 44.3598, 6.58767, 43.54, 8.73828, 42.6562)
      ..close();
    canvas.drawPath(leftSparkle, strokePaint);

    // Top-right sparkle
    final rightSparkle = Path()
      ..moveTo(119.738, 16.6562)
      ..cubicTo(117.561, 16.0048, 116.786, 15.1987, 116.082, 13)
      ..cubicTo(115.49, 14.9931, 114.75, 15.8345, 112.426, 16.6562)
      ..cubicTo(114.781, 17.5899, 115.512, 18.4206, 116.082, 20.3125)
      ..cubicTo(116.785, 18.3598, 117.588, 17.54, 119.738, 16.6562)
      ..close();
    canvas.drawPath(rightSparkle, strokePaint);

    // Top-left segmented ring (inside stroke effect)
    final topArcPath = Path()
      ..moveTo(14.0631, 26.2351)
      ..cubicTo(20.3483, 17.4843, 28.7736, 10.4925, 38.5333, 5.92864)
      ..cubicTo(48.2929, 1.36473, 59.0603, -0.61868, 69.8056, 0.168139)
      ..lineTo(69.7046, 1.54717)
      ..cubicTo(59.1953, 0.77763, 48.6643, 2.71748, 39.119, 7.18118)
      ..cubicTo(29.5737, 11.6449, 21.3333, 18.4831, 15.1862, 27.0417)
      ..lineTo(14.0631, 26.2351)
      ..close();
    canvas.drawPath(topArcPath, fillPaint);
    canvas.save();
    canvas.clipPath(topArcPath);
    canvas.drawPath(
      topArcPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = _green
        ..strokeWidth = 2,
    );
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SuccessBadgePainter oldDelegate) => false;
}
