import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class LwpQuillLocalizationsDelegate
    extends LocalizationsDelegate<FlutterQuillLocalizations> {
  const LwpQuillLocalizationsDelegate();

  static const Locale _fallbackLocale = Locale('en');

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'af' ||
        FlutterQuillLocalizations.delegate.isSupported(locale);
  }

  @override
  Future<FlutterQuillLocalizations> load(Locale locale) {
    if (locale.languageCode == 'af') {
      return SynchronousFuture<FlutterQuillLocalizations>(
        lookupFlutterQuillLocalizations(_fallbackLocale),
      );
    }

    return FlutterQuillLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(
      covariant LocalizationsDelegate<FlutterQuillLocalizations> old) {
    return false;
  }
}
