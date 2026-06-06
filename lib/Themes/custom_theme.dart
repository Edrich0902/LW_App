import 'package:flutter/material.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

class LightColors {
  static const primary = Color(0xFF11181C);
  static const secondary = Color(0xFF023059);
  static const accent = Color(0xFF023059);
  static const background = Color(0xFFFAFAFA);
  static const supporting = Color(0xFF4D4B4B);
  static const surface = Color(0xFFFFFFFF);
  static const field = Color(0xFFEEEEEE);
  static const muted = Color(0xFF77736B);
  static const outline = Color(0xFFE4E7EA);
}

class DarkColors {
  static const primary = Color(0xFF2E86C1);
  static const secondary = Color(0xFF2E86C1);
  static const accent = Color(0xFF2E86C1);
  static const background = Color(0xFF121212);
  static const tertiary = Color(0xFF1E1E1E);
  static const supporting = Color(0xFF4D4B4B);
  static const surface = Color(0xFF1E1E1E);
  static const field = Color(0xFF2A2A2A);
  static const muted = Color(0xFFB0BEC5);
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
    colorScheme: ColorScheme.fromSeed(
        seedColor: mainColor, brightness: Brightness.light),
    primaryColor: LightColors.secondary,
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
      backgroundColor: LightColors.secondary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LightColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LwpRadii.lg),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: LightColors.secondary,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: LightColors.secondary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LightColors.field,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      labelStyle: const TextStyle(color: LightColors.primary),
      floatingLabelStyle: const TextStyle(color: LightColors.secondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
        borderSide: const BorderSide(color: LightColors.secondary, width: 2.0),
      ),
      isDense: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: LightColors.secondary,
      actionTextColor: Colors.white,
      contentTextStyle: const TextStyle(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
      ),
      elevation: 6.0,
    ),
    drawerTheme: DrawerThemeData(
      elevation: 6.0,
      backgroundColor: LightColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
      ),
    ),
    cardTheme: CardThemeData(
      color: LightColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: LightColors.outline),
        borderRadius: BorderRadius.circular(LwpRadii.lg),
      ),
    ),
    dialogTheme: DialogThemeData(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
      ),
      backgroundColor: LightColors.background,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: LightColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: LightColors.outline),
        borderRadius: BorderRadius.circular(LwpRadii.lg),
      ),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: LightColors.primary),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all<Color>(LightColors.secondary),
      checkColor: WidgetStateProperty.all<Color>(Colors.white),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: LightColors.primary,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: LightColors.primary,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: mainColor,
    colorScheme: ColorScheme.fromSeed(
        seedColor: DarkColors.primary, brightness: Brightness.dark),
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
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LwpRadii.lg),
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
      fillColor: DarkColors.field,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      labelStyle: const TextStyle(color: Colors.white70),
      floatingLabelStyle: const TextStyle(color: DarkColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
        borderSide: const BorderSide(color: DarkColors.secondary, width: 2.0),
      ),
      isDense: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: DarkColors.primary,
      actionTextColor: Colors.white,
      contentTextStyle: const TextStyle(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
      ),
      elevation: 6.0,
    ),
    drawerTheme: DrawerThemeData(
      elevation: 6.0,
      backgroundColor: DarkColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
      ),
    ),
    cardTheme: CardThemeData(
      color: DarkColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
      ),
    ),
    dialogTheme: DialogThemeData(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LwpRadii.lg),
      ),
      backgroundColor: DarkColors.background,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: DarkColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(LwpRadii.lg),
      ),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: Colors.white),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all<Color>(DarkColors.primary),
      checkColor: WidgetStateProperty.all<Color>(Colors.white),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
