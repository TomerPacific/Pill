
import 'package:pill/service/shared_preferences_service.dart';

abstract class ThemeState {
  const ThemeState();

 bool get isDarkModeEnabled => false;
}

class InitialTheme extends ThemeState {
  @override
  bool get isDarkModeEnabled => SharedPreferencesService().getThemeStatus();
}

class DarkMode extends ThemeState {
  @override
  bool get isDarkModeEnabled => true;
}

class LightMode extends ThemeState {

  @override
  bool get isDarkModeEnabled => false;
}