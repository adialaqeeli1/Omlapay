import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'colors.dart';

class AppTheme {
  static final String fontFamily =
      GoogleFonts.poppins().fontFamily ?? 'Poppins';

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      brightness: Brightness.light,
      surface: AppColors.lightSurface,
      onSurface: AppColors.onSurfaceBlack,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.appBarForegroundBlack,
    ),
    iconTheme: const IconThemeData(color: AppColors.iconBlack),
    fontFamily: fontFamily,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: TextStyle(color: AppColors.textBlack),
      bodyMedium: TextStyle(color: AppColors.textBlack),
      bodySmall: TextStyle(color: AppColors.textBlack),
      titleLarge: TextStyle(color: AppColors.textBlack),
      titleMedium: TextStyle(color: AppColors.textBlack),
      titleSmall: TextStyle(color: AppColors.textBlack),
      labelLarge: TextStyle(color: AppColors.textBlack),
      labelMedium: TextStyle(color: AppColors.textBlack),
      labelSmall: TextStyle(color: AppColors.textBlack),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
      onSurface: AppColors.onSurfaceWhite,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.appBarForegroundWhite,
    ),
    iconTheme: const IconThemeData(color: AppColors.iconWhite),
    fontFamily: fontFamily,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: TextStyle(color: AppColors.textWhite),
      bodyMedium: TextStyle(color: AppColors.textWhite),
      bodySmall: TextStyle(color: AppColors.textWhite),
      titleLarge: TextStyle(color: AppColors.textWhite),
      titleMedium: TextStyle(color: AppColors.textWhite),
      titleSmall: TextStyle(color: AppColors.textWhite),
      labelLarge: TextStyle(color: AppColors.textWhite),
      labelMedium: TextStyle(color: AppColors.textWhite),
      labelSmall: TextStyle(color: AppColors.textWhite),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider),
  );
}
