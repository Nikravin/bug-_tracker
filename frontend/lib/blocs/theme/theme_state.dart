import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

class LightThemeState extends ThemeState {
  final ThemeData themeData;

  const LightThemeState(this.themeData);

  @override
  List<Object> get props => [themeData];
}

class DarkThemeState extends ThemeState {
  final ThemeData themeData;

  const DarkThemeState(this.themeData);

  @override
  List<Object> get props => [themeData];
}
