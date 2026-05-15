import 'package:flutter/material.dart';

class LightColors {
  static const primary = Color(0xFF11181C);
  static const secondary = Color(0xFFF2C94C);
  static const accent = Color(0xFFF2C94C);
  static const background = Color(0xFFFAFAFA);
}

class DarkColors {
  static const primary = Color(0xFFF2C94C);
  static const secondary = Color(0xFFF2C94C);
  static const accent = Color(0xFFF2C94C);
  static const background = Color(0xFF121212);
  static const tertiary = Color(0xFF1E1E1E);
}

MaterialColor mainColor = const MaterialColor(0xFF11181C, <int, Color>{
  50: Color(0xFF11181C),
  100: Color(0xFF11181C),
  200: Color(0xFF11181C),
  300: Color(0xFF11181C),
  400: Color(0xFF11181C),
  500: Color(0xFF11181C),
  600: Color(0xFF11181C),
  700: Color(0xFF11181C),
  800: Color(0xFF11181C),
  900: Color(0xFF11181C),
});

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    primarySwatch: mainColor,
    colorScheme: ColorScheme.fromSeed(seedColor: mainColor, brightness: Brightness.light),
    primaryColor: LightColors.primary,
    scaffoldBackgroundColor: LightColors.background,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
        color: LightColors.primary,
      ),
      actionsIconTheme: IconThemeData(
        color: LightColors.primary,
      ),
      foregroundColor: LightColors.primary,
      centerTitle: true,
      elevation: 0,
      backgroundColor: LightColors.background,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: LightColors.primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LightColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: LightColors.primary,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: LightColors.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFEEEEEE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      labelStyle: const TextStyle(color: LightColors.primary),
      floatingLabelStyle: const TextStyle(color: LightColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
        borderSide: const BorderSide(color: LightColors.secondary, width: 2.0),
      ),
      isDense: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: LightColors.primary,
      actionTextColor: Colors.white,
      contentTextStyle: const TextStyle(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 6.0,
    ),
    drawerTheme: DrawerThemeData(
      elevation: 6.0,
      backgroundColor: LightColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4.0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
    ),
    dialogTheme: DialogThemeData(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      backgroundColor: LightColors.background,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all<Color>(LightColors.primary),
      checkColor: WidgetStateProperty.all<Color>(Colors.white),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: mainColor,
    colorScheme: ColorScheme.fromSeed(seedColor: DarkColors.primary, brightness: Brightness.dark),
    primaryColor: DarkColors.primary,
    scaffoldBackgroundColor: DarkColors.background,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      actionsIconTheme: IconThemeData(
        color: Colors.white,
      ),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      backgroundColor: DarkColors.background,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: DarkColors.primary,
      foregroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkColors.primary,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DarkColors.primary,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: DarkColors.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      labelStyle: const TextStyle(color: Colors.white70),
      floatingLabelStyle: const TextStyle(color: DarkColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
        borderSide: const BorderSide(color: DarkColors.secondary, width: 2.0),
      ),
      isDense: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: DarkColors.primary,
      actionTextColor: Colors.black,
      contentTextStyle: const TextStyle(
        color: Colors.black,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 6.0,
    ),
    drawerTheme: DrawerThemeData(
      elevation: 6.0,
      backgroundColor: DarkColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
    ),
    cardTheme: CardThemeData(
      color: DarkColors.tertiary,
      elevation: 4.0,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
    ),
    dialogTheme: DialogThemeData(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      backgroundColor: DarkColors.background,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all<Color>(DarkColors.primary),
      checkColor: WidgetStateProperty.all<Color>(Colors.black),
    ),
  );
}
