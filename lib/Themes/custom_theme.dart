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
    primaryColor: LightColors.primary,
    scaffoldBackgroundColor: LightColors.background,
    backgroundColor: LightColors.background,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      color: LightColors.primary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: LightColors.primary,
        foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            )
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      isDense: true,
      filled: true,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: mainColor,
    primaryColor: DarkColors.primary,
    scaffoldBackgroundColor: DarkColors.background,
    backgroundColor: DarkColors.background,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      color: DarkColors.primary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: DarkColors.primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          )
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      isDense: true,
      filled: true,
    ),
  );
}