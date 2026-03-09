import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/extentions/context_extensions.dart';
import '../../core/theme/theme.dart';
import '../../routes/app_router.dart';
import '../../widgets/common_back_button.dart';
import '../auth/services/user_service.dart';

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 9 digits
    final limitedDigits = digitsOnly.length > 9
        ? digitsOnly.substring(0, 9)
        : digitsOnly;

    // Format as 000 000 0000
    String formatted;
    if (limitedDigits.isEmpty) {
      formatted = '';
    } else if (limitedDigits.length <= 3) {
      formatted = limitedDigits;
    } else if (limitedDigits.length <= 6) {
      formatted =
          '${limitedDigits.substring(0, 3)} ${limitedDigits.substring(3)}';
    } else {
      formatted =
          '${limitedDigits.substring(0, 3)} ${limitedDigits.substring(3, 6)} ${limitedDigits.substring(6)}';
    }

    // Calculate cursor position
    int cursorPosition = formatted.length;
    if (newValue.selection.baseOffset < newValue.text.length) {
      // If cursor was in the middle, try to maintain relative position
      final oldDigits = oldValue.text.replaceAll(RegExp(r'[^\d]'), '');
      final newDigits = limitedDigits;
      if (newDigits.length > oldDigits.length) {
        // Character was added
        cursorPosition = formatted.length;
      } else if (newDigits.length < oldDigits.length) {
        // Character was removed
        cursorPosition = formatted.length;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class HardLoginScreen extends StatefulWidget {
  const HardLoginScreen({super.key});

  @override
  State<HardLoginScreen> createState() => _HardLoginScreenState();
}

class _HardLoginScreenState extends State<HardLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _userNotFoundError = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  int _getPhoneDigitsCount() {
    return _phoneController.text.replaceAll(RegExp(r'[^\d]'), '').length;
  }

  String _getPhoneNumber() {
    return _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
  }

  bool _isPhoneValid() {
    return _getPhoneDigitsCount() == 9;
  }

  bool _hasPhoneError() {
    final digitsCount = _getPhoneDigitsCount();
    return digitsCount > 0 && digitsCount < 9;
  }

  void _checkUserAndNavigate() {
    final phoneNumber = _getPhoneNumber();
    final countryCode = '+966'; // Fixed country code as per the UI

    final user = UserService.findUserByPhone(phoneNumber, countryCode);

    if (user == null) {
      setState(() {
        _userNotFoundError = true;
      });
    } else {
      setState(() {
        _userNotFoundError = false;
      });
      context.push(
        Routes.enterPasscode,
        extra: {'phoneNumber': phoneNumber, 'countryCode': countryCode},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDark = context.isDarkMode;

    return Scaffold(
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
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Progress indicator
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Title
                        Builder(
                          builder: (context) {
                            final fullText = l10n.welcomeBackToOmlapay;
                            final isArabic =
                                Localizations.localeOf(context).languageCode ==
                                'ar';

                            // Split text: English "Welcome Back to Omlapay!" -> ["Welcome Back to", "Omlapay!"]
                            // Arabic "مرحبًا بعودتك إلى أوملاباي!" -> ["مرحبًا بعودتك إلى", "أوملاباي!"]
                            final parts = isArabic
                                ? fullText.split('أوملاباي')
                                : fullText.split('Omlapay');

                            final firstPart = parts.isNotEmpty
                                ? parts[0].trim()
                                : '';
                            final secondPart = parts.length > 1
                                ? (isArabic ? 'أوملاباي' : 'Omlapay') +
                                      parts[1].trim()
                                : '';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (firstPart.isNotEmpty)
                                  Text(
                                    firstPart,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppColors.textWhite
                                              : AppColors.textBlack,
                                        ),
                                    maxLines: null,
                                    softWrap: true,
                                  ),
                                if (secondPart.isNotEmpty)
                                  Text(
                                    secondPart,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppColors.textWhite
                                              : AppColors.textBlack,
                                        ),
                                    maxLines: null,
                                    softWrap: true,
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          l10n.pleaseEnterYourNumberAndPasscodeToLogin,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.textLightGrey
                                    : AppColors.textGrey,
                                fontSize: 18,
                              ),
                          maxLines: null,
                          softWrap: true,
                        ),
                        const SizedBox(height: 50),
                        // Country code and phone number row
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Country code selector (non-clickable for now)
                                Container(
                                  height: 56,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[900]
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/saudi-arabia-logo.svg',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '+966',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? AppColors.textWhite
                                              : AppColors.textBlack,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Phone number input
                                Expanded(
                                  child: TextField(
                                    onTapOutside: (event) =>
                                        FocusScope.of(context).unfocus(),
                                    controller: _phoneController,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(9),
                                      _PhoneNumberFormatter(),
                                    ],
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.textWhite
                                          : AppColors.textBlack,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: l10n.phoneNumber,
                                      labelStyle: TextStyle(
                                        color: isDark
                                            ? AppColors.textLightGrey
                                            : AppColors.textGrey,
                                        fontSize: 16,
                                      ),
                                      hintText: '000 000 000',
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? AppColors.textLightGrey
                                            : AppColors.textGrey,
                                        fontSize: 16,
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey[900]
                                          : AppColors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color:
                                              (_hasPhoneError() ||
                                                  _userNotFoundError)
                                              ? Colors.red
                                              : (isDark
                                                    ? Colors.grey[800]!
                                                    : Colors.grey[300]!),
                                          width:
                                              (_hasPhoneError() ||
                                                  _userNotFoundError)
                                              ? 2
                                              : 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color:
                                              (_hasPhoneError() ||
                                                  _userNotFoundError)
                                              ? Colors.red
                                              : (isDark
                                                    ? Colors.grey[800]!
                                                    : Colors.grey[300]!),
                                          width:
                                              (_hasPhoneError() ||
                                                  _userNotFoundError)
                                              ? 2
                                              : 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color:
                                              (_hasPhoneError() ||
                                                  _userNotFoundError)
                                              ? Colors.red
                                              : AppColors.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                            // Always reserve space for error message to prevent layout shift
                            SizedBox(
                              height:
                                  28, // Fixed height: 8px padding top + 12px font size + 8px padding bottom
                              child: _hasPhoneError()
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                        left: 16.0,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          l10n.phoneNumberMustBe9Digits,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    )
                                  : _userNotFoundError
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          l10n.userNotFound,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isPhoneValid()
                                ? () {
                                    _checkUserAndNavigate();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primaryColor
                                  .withOpacity(0.5),
                              disabledForegroundColor: Colors.white.withOpacity(
                                0.7,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              l10n.continueAction,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Forgot passcode link
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Sign up link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: Handle sign up
                            },
                            child: Text(
                              l10n.dontHaveAccountSignUp,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textBlack,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        // Continue as guest link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              context.go(Routes.home);
                            },
                            child: Text(
                              l10n.continueAsGuest,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textBlack,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer with terms and privacy - pushed to bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      maxLines: null,
                      softWrap: true,
                      text: TextSpan(
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textLightGrey
                              : AppColors.textGrey,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: l10n.byCreatingAnAccountIAgreeToMushafars,
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                          const TextSpan(text: '\n'),
                          TextSpan(
                            text: l10n.termsOfService,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO: Handle terms of service
                              },
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(text: l10n.andWord),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: l10n.privacyPolicy,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO: Handle privacy policy
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
