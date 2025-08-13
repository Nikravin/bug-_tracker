import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeToggleRequested extends ThemeEvent {}

class ThemeSetLightRequested extends ThemeEvent {}

class ThemeSetDarkRequested extends ThemeEvent {}
