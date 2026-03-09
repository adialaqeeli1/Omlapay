import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/extentions/context_extensions.dart';
import '../../core/theme/theme.dart';
import '../../routes/app_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_back_button.dart';

class EnterPasscodeScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const EnterPasscodeScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<EnterPasscodeScreen> createState() => _EnterPasscodeScreenState();
}

class _EnterPasscodeScreenState extends State<EnterPasscodeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _passcodeController = TextEditingController();
  late AnimationController _shakeController;
  bool _hasError = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _passcodeController.addListener(_onPasscodeChanged);
  }

  @override
  void dispose() {
    _passcodeController.removeListener(_onPasscodeChanged);
    _passcodeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onPasscodeChanged() {
    // Clear error when user starts typing again
    if (_hasError && _passcodeController.text.isNotEmpty) {
      setState(() {
        _hasError = false;
      });
    }

    // Auto-verify when 6 digits are entered
    if (_passcodeController.text.length == 6 && !_isVerifying) {
      _verifyPasscode();
    }
  }

  int _getPasscodeLength() {
    return _passcodeController.text.length;
  }

  void _onNumberPressed(String number) {
    if (_passcodeController.text.length < 6 && !_isVerifying) {
      setState(() {
        _passcodeController.text += number;
      });
    }
  }

  void _onBackspacePressed() {
    if (_passcodeController.text.isNotEmpty && !_isVerifying) {
      setState(() {
        _passcodeController.text = _passcodeController.text.substring(
          0,
          _passcodeController.text.length - 1,
        );
      });
    }
  }

  Future<void> _verifyPasscode() async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    // Small delay to show the last digit before verification
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final passcode = _passcodeController.text;

    // Perform login via provider which returns status
    final isValid = await context.read<AuthProvider>().login(
      widget.phoneNumber,
      widget.countryCode,
      passcode,
    );

    if (!mounted) return;

    if (isValid) {
      setState(() {
        _hasError = false;
      });
      context.go(Routes.home);
    } else {
      // Show error and shake animation
      setState(() {
        _hasError = true;
        _isVerifying = false;
      });
      _shakeController.forward(from: 0.0).then((_) {
        if (mounted) {
          _shakeController.reset();
        }
      });
      // Clear passcode after animation
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() {
          _passcodeController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDark = context.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: CommonBackButton(
          onPressed: () {
            final GoRouter router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              router.go(Routes.home);
            }
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
        ).add(const EdgeInsets.only(top: kToolbarHeight + 16)),
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Welcome text
            Text(
              l10n.welcomeToOmlaPay,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textWhite : AppColors.textBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Title - Enter passcode
            Text(
              l10n.enterPasscode,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textWhite : AppColors.textBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            // Passcode dots indicator with shake animation
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                // Create shake animation: left-right-left pattern
                double offset = 0;
                if (_shakeController.value > 0) {
                  final progress = _shakeController.value;
                  // Shake pattern: 0 -> 1 -> 0 -> -1 -> 0
                  if (progress < 0.25) {
                    offset = progress * 4 * 10; // 0 to 10
                  } else if (progress < 0.5) {
                    offset = (0.5 - progress) * 4 * 10; // 10 to 0
                  } else if (progress < 0.75) {
                    offset = -(progress - 0.5) * 4 * 10; // 0 to -10
                  } else {
                    offset = -(1 - progress) * 4 * 10; // -10 to 0
                  }
                }
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final isFilled = index < _getPasscodeLength();
                      return Container(
                        margin: EdgeInsets.only(right: index < 5 ? 12 : 0),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled && !_hasError
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: _hasError
                                ? Colors.red
                                : (isFilled
                                      ? AppColors.primaryColor
                                      : (isDark
                                            ? Colors.grey[600]!
                                            : Colors.grey[400]!)),
                            width: _hasError ? 2 : 1,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
            // Error message
            SizedBox(
              height:
                  46, // Increased to accommodate text (16 top padding + 14 font size + 16 bottom padding)
              child: _hasError
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: Text(
                        l10n.incorrectPasscode,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            // Forgot passcode link
            TextButton(
              onPressed: () {
                // TODO: Handle forgot passcode
              },
              child: Text(
                l10n.forgotPasscode,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Numeric keypad
            Column(
              children: [
                // Rows 1-3: Numbers 1-9
                for (int row = 0; row < 3; row++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int col = 1; col <= 3; col++)
                          _KeypadButton(
                            label: '${row * 3 + col}',
                            onPressed: () =>
                                _onNumberPressed('${row * 3 + col}'),
                            isDark: isDark,
                          ),
                      ],
                    ),
                  ),
                // Row 4: Empty, 0, Backspace
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 80, height: 80), // Empty space
                      _KeypadButton(
                        label: '0',
                        onPressed: () => _onNumberPressed('0'),
                        isDark: isDark,
                      ),
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Center(
                          child: GestureDetector(
                            onTap: _onBackspacePressed,
                            child: _ClearIcon(isDark: isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isDark;

  const _KeypadButton({
    required this.label,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textWhite : AppColors.textBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClearIcon extends StatelessWidget {
  final bool isDark;

  const _ClearIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    // The SVG now has only the X sign (circle removed)
    // In dark mode: X should be white
    // In light mode: X should be black
    return SvgPicture.asset(
      isDark
          ? 'assets/icons/clear-number-icon-dark.svg'
          : 'assets/icons/clear-number-icon-light.svg',
      width: 28,
      height: 24,
    );
  }
}
