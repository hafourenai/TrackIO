import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorConstants.primaryTeal,
        brightness: Brightness.light,
        primary: ColorConstants.primaryTeal,
        secondary: ColorConstants.secondaryTeal,
        surface: ColorConstants.surfaceLight,
      ),
      scaffoldBackgroundColor: ColorConstants.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorConstants.backgroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: ColorConstants.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorConstants.primaryTeal,
        brightness: Brightness.dark,
        primary: ColorConstants.secondaryTeal,
        secondary: ColorConstants.primaryTeal,
        surface: ColorConstants.surfaceDark,
      ),
      scaffoldBackgroundColor: ColorConstants.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorConstants.backgroundDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: ColorConstants.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
