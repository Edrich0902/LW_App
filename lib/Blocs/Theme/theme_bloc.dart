import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'user_theme_preference';

  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<InitThemeEvent>(_onInitTheme);
    on<UpdateThemeEvent>(_onUpdateTheme);
  }

  Future<void> _onInitTheme(InitThemeEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeStr = prefs.getString(_themeKey);

    ThemeMode themeMode = ThemeMode.system;
    if (themeStr != null) {
      switch (themeStr) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          themeMode = ThemeMode.system;
          break;
      }
    }
    emit(ThemeState(themeMode));
  }

  Future<void> _onUpdateTheme(UpdateThemeEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    String themeStr = 'system';

    switch (event.themeMode) {
      case ThemeMode.light:
        themeStr = 'light';
        break;
      case ThemeMode.dark:
        themeStr = 'dark';
        break;
      case ThemeMode.system:
      default:
        themeStr = 'system';
        break;
    }

    await prefs.setString(_themeKey, themeStr);
    emit(ThemeState(event.themeMode));
  }
}
