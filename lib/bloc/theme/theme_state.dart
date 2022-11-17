
abstract class ThemeState {
  const ThemeState();

 bool get isDarkModeEnabled => false;
}

class DarkMode extends ThemeState {
  @override
  bool get isDarkModeEnabled => true;
}

class LightMode extends ThemeState {

  @override
  bool get isDarkModeEnabled => false;
}