import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/extentions/context_extensions.dart';
import '../../core/theme/theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';

class SoftLoginScreen extends StatefulWidget {
  const SoftLoginScreen({super.key});

  @override
  State<SoftLoginScreen> createState() => _SoftLoginScreenState();
}

class _SoftLoginScreenState extends State<SoftLoginScreen>
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
    if (_hasError && _passcodeController.text.isNotEmpty) {
      setState(() => _hasError = false);
    }
    if (_passcodeController.text.length == 6 && !_isVerifying) {
      _verifyPasscode();
    }
  }

  int _getPasscodeLength() => _passcodeController.text.length;

  void _onNumberPressed(String number) {
    if (_passcodeController.text.length < 6 && !_isVerifying) {
      setState(() => _passcodeController.text += number);
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

    final user = context.read<AuthProvider>().state.user;
    if (user == null) {
      if (mounted) context.go(Routes.login);
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final passcode = _passcodeController.text;
    final isValid = await context.read<AuthProvider>().login(
          user.mobileNumber,
          user.countryCode,
          passcode,
        );

    if (!mounted) return;

    if (isValid) {
      setState(() => _hasError = false);
      context.go(Routes.home);
    } else {
      setState(() {
        _hasError = true;
        _isVerifying = false;
      });
      _shakeController.forward(from: 0.0).then((_) {
        if (mounted) _shakeController.reset();
      });
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) setState(() => _passcodeController.clear());
    }
  }

  void _onLogout() {
    final l10n = context.l10n!;
    final isDark = context.isDarkMode;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2F2F2F) : const Color(0xFFE5E5E5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.readyToLogOut,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            l10n.logoutDialogMessage,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await context.read<AuthProvider>().logout();
                      if (mounted) context.go(Routes.hardLogin);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF453A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      l10n.logout,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDark = context.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Logout button top right - rectangle, no border radius, with background
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isVerifying ? null : _onLogout,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                    // side: const BorderSide(color: AppColors.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(l10n.logout),
                ),
              ),
              const SizedBox(height: 48),
              // Welcome to Omlapay - centered
              Text(
                l10n.welcomeToOmlaPay,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? AppColors.textWhite : AppColors.textBlack,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Enter your passcode - left aligned, large bold
              Text(
                l10n.enterPasscode,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? AppColors.textWhite : AppColors.textBlack,
                    ),
              ),
              const SizedBox(height: 50),
              // Passcode dots with shake
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  double offset = 0;
                  if (_shakeController.value > 0) {
                    final progress = _shakeController.value;
                    if (progress < 0.25) {
                      offset = progress * 4 * 10;
                    } else if (progress < 0.5) {
                      offset = (0.5 - progress) * 4 * 10;
                    } else if (progress < 0.75) {
                      offset = -(progress - 0.5) * 4 * 10;
                    } else {
                      offset = -(1 - progress) * 4 * 10;
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
              SizedBox(
                height: 46,
                child: _hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Text(
                          l10n.incorrectPasscode,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              // Forgot passcode - centered, teal
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Handle forgot passcode
                  },
                  child: Text(
                    l10n.forgotPasscode,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Numeric keypad
              Column(
                children: [
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 80, height: 80),
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
    return SvgPicture.asset(
      isDark
          ? 'assets/icons/clear-number-icon-dark.svg'
          : 'assets/icons/clear-number-icon-light.svg',
      width: 28,
      height: 24,
    );
  }
}
