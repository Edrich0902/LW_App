import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Locale/locale_event.dart';
import 'package:lw_app/Blocs/Locale/locale_state.dart';
import 'package:lw_app/Services/Profile/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String _localeKey = 'user_locale_preference';
  static const Locale _defaultLocale = Locale('af');

  final ProfileService _profileService;

  LocaleBloc({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService(),
        super(const LocaleState(_defaultLocale)) {
    on<InitLocaleEvent>(_onInitLocale);
    on<UpdateLocaleEvent>(_onUpdateLocale);
    on<HydrateLocaleFromProfileEvent>(_onHydrateLocaleFromProfile);
  }

  Future<void> _onInitLocale(
    InitLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedLanguageCode = prefs.getString(_localeKey);
    emit(LocaleState(_resolveLocale(storedLanguageCode)));
  }

  Future<void> _onUpdateLocale(
    UpdateLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    final resolvedLocale = _resolveLocale(event.locale.languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, resolvedLocale.languageCode);
    emit(LocaleState(resolvedLocale));

    await _profileService.updatePreferredLanguage(
      languageCode: resolvedLocale.languageCode,
    );
  }

  Future<void> _onHydrateLocaleFromProfile(
    HydrateLocaleFromProfileEvent event,
    Emitter<LocaleState> emit,
  ) async {
    final languageCode = event.languageCode;
    if (!_isSupportedLanguageCode(languageCode)) {
      return;
    }

    final resolvedLocale = Locale(languageCode!);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, resolvedLocale.languageCode);
    emit(LocaleState(resolvedLocale));
  }

  Locale _resolveLocale(String? languageCode) {
    if (_isSupportedLanguageCode(languageCode)) {
      return Locale(languageCode!);
    }

    return _defaultLocale;
  }

  bool _isSupportedLanguageCode(String? languageCode) {
    return languageCode == 'af' || languageCode == 'en';
  }
}
