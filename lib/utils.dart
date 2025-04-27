class Utils {
  static bool isNumberGreaterThanZero(String? str) {
    if (str != null) {
      double? number = double.tryParse(str);
      if (number != null) {
        return number > 0;
      }
    }

    return false;
  }
}
