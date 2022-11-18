
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/theme/theme_event.dart';
import 'package:pill/bloc/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(): super(InitialTheme()) {
    on<ChangeTheme>(_onThemeChange);
  }

  void _onThemeChange(ChangeTheme event, Emitter<ThemeState> emitter) {
    if (event.isDarkThemeEnabled) {
      emitter(DarkMode());
    } else {
      emitter(LightMode());
    }
  }
}