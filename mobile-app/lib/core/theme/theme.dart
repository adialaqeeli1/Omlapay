import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

part 'colors.dart';

class AppTheme {
  static final String fontFamily =
      GoogleFonts.poppins().fontFamily ?? 'Poppins';

  static const List<String> fontFamilyFallback = ['SaudiRiyal'];

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      brightness: Brightness.light,
      surface: AppColors.lightSurface,
      onSurface: AppColors.onSurfaceBlack,
      error: AppColors.redColor,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.appBarForegroundBlack,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.poppinsTextTheme().titleLarge?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        fontFamilyFallback: fontFamilyFallback,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    iconTheme: const IconThemeData(color: AppColors.iconBlack),
    fontFamily: fontFamily,
    textTheme: GoogleFonts.poppinsTextTheme()
        .apply(fontFamilyFallback: fontFamilyFallback)
        .copyWith(
          bodyLarge: TextStyle(
            color: AppColors.textBlack,
            fontFamilyFallback: fontFamilyFallback,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textBlack,
            fontFamilyFallback: fontFamilyFallback,
          ),
          bodySmall: TextStyle(
            color: AppColors.textBlack,
            fontFamilyFallback: fontFamilyFallback,
          ),
          titleLarge: TextStyle(
            color: AppColors.textBlack,
            fontFamilyFallback: fontFamilyFallback,
          ),
          titleMedium: TextStyle(
            color: AppColors.textBlack,
            fontFamilyFallback: fontFamilyFallback,
          ),
          titleSmall: TextStyle(
            color: AppColors.textBlack,
            fontFamilyFallback: fontFamilyFallback,
          ),
          labelLarge: TextStyle(
            color: AppColors.textBlack,
            fontFamilyFallback: fontFamilyFallback,
          ),
          labelMedium: TextStyle(
            color: AppColors.textBlack,
            fontFamilyFallback: fontFamilyFallback,
          ),
          labelSmall: TextStyle(
            color: AppColors.textBlack,
            fontFamilyFallback: fontFamilyFallback,
          ),
        ),
    dividerTheme: const DividerThemeData(color: AppColors.divider),
    cardColor: AppColors.lightCardColor,
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
      onSurface: AppColors.onSurfaceWhite,
      error: AppColors.redColor,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.appBarForegroundWhite,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.poppinsTextTheme().titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        fontFamilyFallback: fontFamilyFallback,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    iconTheme: const IconThemeData(color: AppColors.iconWhite),
    fontFamily: fontFamily,
    textTheme: GoogleFonts.poppinsTextTheme()
        .apply(fontFamilyFallback: fontFamilyFallback)
        .copyWith(
          bodyLarge: TextStyle(
            color: AppColors.textWhite,
            fontFamilyFallback: fontFamilyFallback,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textWhite,
            fontFamilyFallback: fontFamilyFallback,
          ),
          bodySmall: TextStyle(
            color: AppColors.textWhite,
            fontFamilyFallback: fontFamilyFallback,
          ),
          titleLarge: TextStyle(
            color: AppColors.textWhite,
            fontFamilyFallback: fontFamilyFallback,
          ),
          titleMedium: TextStyle(
            color: AppColors.textWhite,
            fontFamilyFallback: fontFamilyFallback,
          ),
          titleSmall: TextStyle(
            color: AppColors.textWhite,
            fontFamilyFallback: fontFamilyFallback,
          ),
          labelLarge: TextStyle(
            color: AppColors.textWhite,
            fontFamilyFallback: fontFamilyFallback,
          ),
          labelMedium: TextStyle(
            color: AppColors.textWhite,
            fontFamilyFallback: fontFamilyFallback,
          ),
          labelSmall: TextStyle(
            color: AppColors.textWhite,
            fontFamilyFallback: fontFamilyFallback,
          ),
        ),
    dividerTheme: const DividerThemeData(color: AppColors.divider),
    cardColor: AppColors.darkCardColor,
  );
}
