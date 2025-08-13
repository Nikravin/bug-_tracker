import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ui/theme/theme_data.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_preference';

  ThemeBloc() : super(LightThemeState(lightTheme)) {
on<ThemeToggleRequested>(_onToggleTheme);
on<ThemeSetLightRequested>(_onSetLightTheme);
on<ThemeSetDarkRequested>(_onSetDarkTheme);
    _loadTheme();
  }

void _onToggleTheme(ThemeToggleRequested event, Emitter<ThemeState> emit) async {
    if (state is LightThemeState) {
      emit(DarkThemeState(darkTheme));
      await _saveTheme(false);
    } else {
      emit(LightThemeState(lightTheme));
      await _saveTheme(true);
    }
  }

void _onSetLightTheme(ThemeSetLightRequested event, Emitter<ThemeState> emit) async {
    emit(LightThemeState(lightTheme));
    await _saveTheme(true);
  }

void _onSetDarkTheme(ThemeSetDarkRequested event, Emitter<ThemeState> emit) async {
    emit(DarkThemeState(darkTheme));
    await _saveTheme(false);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isLight = prefs.getBool(_themeKey) ?? true;
    if (isLight) {
      add(ThemeSetLightRequested());
    } else {
      add(ThemeSetDarkRequested());
    }
  }

  Future<void> _saveTheme(bool isLight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isLight);
  }
}
