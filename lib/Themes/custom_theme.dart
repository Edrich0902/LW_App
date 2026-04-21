import 'package:flutter/material.dart';

class LightColors {
  static const primary = Color(0xFF22628c);
  static const secondary = Color(0xFFde4030);
  static const accent = Color(0xFF996619);
  static const background = Color(0xFFFAFAFA);
}

class DarkColors {
  static const primary = Color(0xFF22628c);
  static const secondary = Color(0xFFde4030);
  static const accent = Color(0xFF996619);
  static const background = Color(0xFF11181d);
  static const tertiary = Color(0xFF222f38);
}

MaterialColor mainColor = const MaterialColor(0xFF22628c, <int, Color>{
  50: Color(0xFF22628c),
  100: Color(0xFF22628c),
  200: Color(0xFF22628c),
  300: Color(0xFF22628c),
  400: Color(0xFF22628c),
  500: Color(0xFF22628c),
  600: Color(0xFF22628c),
  700: Color(0xFF22628c),
  800: Color(0xFF22628c),
  900: Color(0xFF22628c),
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
        color: Colors.white,
      ),
      actionsIconTheme: IconThemeData(
        color: Colors.white,
      ),
      foregroundColor: Colors.white,
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0)
        ),
      ),
      backgroundColor: LightColors.primary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: LightColors.primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(LightColors.primary),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        )),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      isDense: true,
      filled: true,
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
      color: LightColors.background,
      elevation: 4.0,
      shadowColor: DarkColors.background,
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
    colorScheme: ColorScheme.fromSeed(seedColor: mainColor, brightness: Brightness.dark),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24.0),
            bottomRight: Radius.circular(24.0)
        ),
      ),
      backgroundColor: DarkColors.primary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: DarkColors.primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(DarkColors.primary),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        )),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      isDense: true,
      filled: true,
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
      backgroundColor: DarkColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
    ),
    cardTheme: CardThemeData(
      color: DarkColors.tertiary,
      elevation: 4.0,
      shadowColor: DarkColors.background,
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
      checkColor: WidgetStateProperty.all<Color>(Colors.white),
    ),
  );
}
