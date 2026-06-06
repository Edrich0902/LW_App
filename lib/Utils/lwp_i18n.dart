import 'package:flutter/material.dart';
import 'package:lw_app/Utils/navigation.dart';
import 'package:lw_app/l10n/app_localizations.dart';

class LwpI18n {
  LwpI18n._();

  static AppLocalizations? get current {
    final context = navigatorKey.currentContext;
    if (context == null) return null;
    return AppLocalizations.of(context);
  }

  static Locale? get locale => navigatorKey.currentContext != null
      ? Localizations.localeOf(navigatorKey.currentContext!)
      : null;
}
