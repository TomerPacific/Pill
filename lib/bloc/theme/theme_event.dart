

abstract class ThemeEvent {
  const ThemeEvent();

  bool get isDarkThemeEnabled => false;
}

class ChangeTheme extends ThemeEvent {
  bool darkThemeEnabled = false;

  ChangeTheme({required this.darkThemeEnabled});

  @override
  bool get isDarkThemeEnabled => darkThemeEnabled;
}