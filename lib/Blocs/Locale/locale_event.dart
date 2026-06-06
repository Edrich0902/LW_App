import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

class InitLocaleEvent extends LocaleEvent {
  const InitLocaleEvent();
}

class UpdateLocaleEvent extends LocaleEvent {
  final Locale locale;

  const UpdateLocaleEvent(this.locale);

  @override
  List<Object?> get props => [locale];
}

class HydrateLocaleFromProfileEvent extends LocaleEvent {
  final String? languageCode;

  const HydrateLocaleFromProfileEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}
