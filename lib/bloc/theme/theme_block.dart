import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/service/shared_preferences_service.dart';

enum ThemeEvent { toggleDark, toggleLight }

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc(SharedPreferencesService sharedPreferencesService, bool isDarkMode)
      : super(isDarkMode ? ThemeMode.dark : ThemeMode.light) {
    on<ThemeEvent>((event, emit) {
      ThemeMode themeMode =
          event == ThemeEvent.toggleDark ? ThemeMode.dark : ThemeMode.light;
      emit(themeMode);
      sharedPreferencesService
          .saveThemeStatus(themeMode == ThemeMode.dark ? true : false);
    });
  }
}
