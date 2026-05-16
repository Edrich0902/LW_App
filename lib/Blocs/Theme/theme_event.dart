import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class InitThemeEvent extends ThemeEvent {
  const InitThemeEvent();
}

class UpdateThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  const UpdateThemeEvent(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}
