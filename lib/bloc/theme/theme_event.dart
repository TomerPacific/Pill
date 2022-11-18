import 'package:pill/service/shared_preferences_service.dart';

abstract class ThemeEvent {
  const ThemeEvent();

  bool get isDarkThemeEnabled => false;
}

class ChangeTheme extends ThemeEvent {
  bool darkThemeEnabled = false;

  ChangeTheme({required this.darkThemeEnabled}) {
    SharedPreferencesService().saveThemeStatus(darkThemeEnabled);
  }

  @override
  bool get isDarkThemeEnabled => darkThemeEnabled;
}