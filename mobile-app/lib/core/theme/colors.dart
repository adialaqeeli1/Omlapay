part of 'theme.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF2AA29A);
  static const Color white = Colors.white;

  // Backgrounds & Surfaces
  static const Color lightBackground = Colors.white;
  static const Color darkBackground = Colors.black;
  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Colors.black;

  // On Surfaces (Text/Icons on background)
  static final Color onSurfaceBlack = Colors.grey[900]!;
  static final Color onSurfaceWhite = Colors.grey[300]!;

  // AppBar Foreground
  static final Color appBarForegroundBlack = Colors.grey[800]!;
  static final Color appBarForegroundWhite = Colors.grey[300]!;

  // Icons
  static const Color iconBlack = Color(0xFF000000);
  static const Color iconWhite = Color(0xFFB3B3B3);

  // Text Main
  static const Color textBlack = Color(0xFF111111);
  static const Color textWhite = Color(0xFFF2F2F2);
  static const Color textGrey = Color(0xFF4F4F4F);
  static const Color textLightGrey = Color(0xFF979797);

  // Divider
  static const Color divider = Color(0xFF4F4F4F);

  // Crypto Colors
  static const Color usdtColor = Color(0xFF26A17B);
  static const Color bitcoinColor = Color(0xFFF7931A);
  static const Color greenColor = Color(0xFF00C566);
  static const Color redColor = Color(0xFFFF4D4F);

  //Card Colors
  static const Color darkCardColor = Color(0xFF141414);
  static const Color lightCardColor = Color(0xFFF2F2F2);

  /// Send flow (light): white field with visible stroke per design (~#666666).
  static const Color sendFormFieldBorderLight = Color(0xFF666666);

  /// Swap flow (light): field fill per design (~#EFEFEF).
  static const Color swapFieldFillLight = Color(0xFFEFEFEF);
  static const Color balanceCardGradientStart = Color(0x991C1C1E);
  static const Color balanceCardGradientEnd = Color(0x991A605B);
  static const Color iconBackground = Color(0xFF2C2C2C);
  static const Color tealColor = Color(0xFF26A69A);

  // Success Card Gradient
  static const Color successGradientStart = Color(0xFF1C1C1E);
  static const Color successGradientEnd = Color(0xFF1A605B);

  /// Logout button background from Figma: #2AA29A with ~12% opacity
  static const Color logoutButtonBackground = Color(0x1F2AA29A);

  /// Destructive action (Logout confirm) - reddish-pink/coral
  static const Color logoutDestructiveColor = Color(0xFFE57373);

  /// KYC verification banner accent (Figma #D80027).
  static const Color kycBannerAccent = Color(0xFFD80027);

  /// KYC banner fill, light mode: #D80027 @ alpha 0x1F (Figma #D800271F).
  static const Color kycVerificationBannerBackgroundLight = Color(0x1FD80027);

  /// KYC banner fill, dark mode: #D80027 @ alpha 0x80 (Figma #D8002780).
  static const Color kycVerificationBannerBackgroundDark = Color(0x80D80027);
}
